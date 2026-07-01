#!/usr/bin/env python3
"""brain_compile.py — Project Brain compiler (committed per-repo, stdlib only).

Reconciles design §4.4 (compile generator) and §12 (durability mechanism must
travel committed-in-repo). Self-locates its repo root from __file__ so it is
worktree-safe and needs no environment variables.

Subcommands:
  inject            SessionStart hook: read hook JSON on stdin, print
                    {"hookSpecificOutput": {..., "additionalContext": "<baseline>"}}.
  checkpoint        PreCompact hook: read hook JSON on stdin, write
                    _dispatch/CHECKPOINT.md (git state + transcript tail), exit 0.
  clear-checkpoint  Remove _dispatch/CHECKPOINT.md (task done).
  rollup            Print dashboard JSON to stdout.

Every subcommand accepts a hidden --root to override the derived repo root (tests).
"""
import argparse
import datetime
import difflib
import fcntl
import fnmatch
import json
import os
import re
import subprocess
import sys
import tempfile
import time

# Repo root: this file lives at <root>/.claude/hooks/brain_compile.py
DERIVED_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

__version__ = "3.1.0"

TIER_EMOJI = {
    "locked": "🔒", "deferred": "⏸", "presumed": "🟡",
    "open": "❓", "needs-research": "🔬", "superseded": "🗑",
}
UNCONFIRMED = {"presumed", "open", "needs-research"}  # the pending set (L0 lead)
WRITE_VERBS = {"capture", "dispose", "state"}
DEDUP_RATIO = 0.85  # difflib similarity above which two same-area titles are "the same"
CHECKPOINT_STALE_HOURS = 48
STALE_AFTER_DAYS = 21  # age >= this many days is flagged ⚠ stale (inclusive)
PARK_AFTER_DAYS = STALE_AFTER_DAYS  # pending older than this collapses to "parked" (tunable later)
# Progressive disclosure / §11 token budget: cap how many full locked bodies
# (L1) get injected when a broad cwd glob matches many decisions. Overflow is
# summarized in one line pointing back to DECISIONS.md.
L1_MAX_BODIES = 8

# --- Shared legibility layer (single source of truth for both emitters) -------
TIER_PHRASE = {
    "presumed": "you leaned this way but didn't confirm",
    "open": "still open",
    "needs-research": "needs research",
    "locked": "settled",
    "deferred": "parked",
    "superseded": "dropped",
}

# Operator-facing consequence + reversibility for each reconcile choice.
CHOICE_HELP = {
    "lock": "settled; agents won't reopen (reversible)",
    "defer": "ask me again next session (reversible)",
    "kill": "remove from the cockpit for good (reversible via git history)",
}


def tier_phrase(tier):
    return TIER_PHRASE.get(tier, tier or "unknown")


def age_phrase(age_days):
    """Plain-English age. Undatable or future-dated (negative) → 'age unknown'."""
    if age_days is None or age_days < 0:
        return "age unknown"
    if age_days == 0:
        return "today"
    if age_days == 1:
        return "yesterday"
    if age_days < 14:
        return "%d days ago" % age_days
    if age_days < 60:
        return "%d weeks ago" % (age_days // 7)
    return "%d months ago" % (age_days // 30)


# H3 (`###`) is reserved for decision-entry headers — do NOT use H3 for
# sub-headings inside a decision body (it would start a spurious entry).
_ENTRY_RE = re.compile(r"^###\s+(?P<id>.+?)(?:\s+—\s+(?P<title>.+?))?\s*$")
_FM_RE = re.compile(r"^<!--\s*(?P<body>.*?)\s*-->\s*$")


def read_text(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return ""


def parse_frontmatter(comment_body):
    """'tier: locked · area: auth · files: a, b · source: pr' -> dict."""
    fields = {}
    for part in comment_body.split("·"):
        if ":" in part:
            key, _, val = part.partition(":")
            fields[key.strip()] = val.strip()
    return fields


def parse_decisions(text):
    """Parse '### <ID> — <title>' + frontmatter comment + body until next heading."""
    lines = text.splitlines()
    entries = []
    i = 0
    while i < len(lines):
        m = _ENTRY_RE.match(lines[i])
        if not m:
            i += 1
            continue
        entry = {
            "id": m.group("id").strip(), "title": (m.group("title") or "").strip(),
            "tier": None, "area": "", "files": "",
            "decided": "", "validated": "", "issue": "", "source": "",
            "line": i + 1,  # 1-based heading line — anchors DECISIONS.md:<line> source refs
        }
        j = i + 1
        if j < len(lines):
            fm = _FM_RE.match(lines[j].strip())
            if fm:
                fields = parse_frontmatter(fm.group("body"))
                for k in ("tier", "area", "files", "decided", "validated", "issue", "source"):
                    if k in fields:
                        entry[k] = fields[k]
                j += 1
        body = []
        while j < len(lines) and not lines[j].startswith("### ") and not lines[j].startswith("## "):
            body.append(lines[j])
            j += 1
        entry["body"] = "\n".join(body).strip()
        entries.append(entry)
        i = j
    return entries


def state_section(text, header):
    """Return the lines under the first '## <header>...' until the next '## '.

    Note: only '## ' (H2) acts as a section boundary here, so any '### ' (H3)
    sub-headings are intentionally captured as section content — unlike
    parse_decisions, where '### ' is a stop sentinel that starts a new entry.
    """
    header = header.lower()
    out, capturing = [], False
    for line in text.splitlines():
        if line.startswith("## "):
            capturing = line[3:].strip().lower().startswith(header)
            continue
        if capturing:
            out.append(line)
    return "\n".join(out).strip()


TIER_NAMES = {  # H2 header text per tier (the descriptive suffix is optional in files)
    "locked": "🔒 Locked",
    "deferred": "⏸ Deferred",
    "presumed": "🟡 Presumed",
    "open": "❓ Open",
    "needs-research": "🔬 Needs-Research",
    "superseded": "🗑 Superseded",
}
TIER_ORDER = ["locked", "deferred", "presumed", "open", "needs-research", "superseded"]


def _next_id(decisions, prefix):
    """Next free PREFIX-N (max existing + 1; 1 if none)."""
    pat = re.compile(re.escape(prefix) + r"-(\d+)$")
    nums = [int(m.group(1)) for d in decisions for m in [pat.match(d["id"])] if m]
    return "%s-%d" % (prefix, (max(nums) + 1) if nums else 1)


def _section_bounds(lines, emoji):
    """(start, end) line indices of the '## <emoji> ...' section body, or None.
    start = index of the H2 header line; end = index of the next '## ' (or EOF)."""
    start = None
    for i, ln in enumerate(lines):
        if ln.startswith("## ") and emoji in ln:
            start = i
            break
    if start is None:
        return None
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("## "):
            end = j
            break
    return (start, end)


def _ensure_section(text, tier):
    """Guarantee a '## <tier>' section exists; create it in canonical order if absent.
    (Pilots seeded before the ⏸ Deferred tier lack it; spec §4.1.)"""
    lines = text.splitlines()
    if _section_bounds(lines, TIER_EMOJI[tier]) is not None:
        return text
    my = TIER_ORDER.index(tier)
    insert_at = len(lines)                       # default: append at EOF
    for later in TIER_ORDER[my + 1:]:            # else: before the first higher-order tier
        b = _section_bounds(lines, TIER_EMOJI[later])
        if b is not None:
            insert_at = b[0]
            break
    header = "## " + TIER_NAMES[tier]
    if insert_at == len(lines):
        lines += ["", header]
    else:
        lines[insert_at:insert_at] = [header, ""]
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def _insert_entry(text, tier, entry_block):
    """Insert entry_block at the end of the tier's section (creating it if absent)."""
    had_nl = text.endswith("\n")
    text = _ensure_section(text, tier)
    lines = text.splitlines()
    start, end = _section_bounds(lines, TIER_EMOJI[tier])
    insert_at = end
    while insert_at - 1 > start and lines[insert_at - 1].strip() == "":
        insert_at -= 1
    block_lines = ["", *entry_block.splitlines()]
    lines[insert_at:insert_at] = block_lines
    return "\n".join(lines) + ("\n" if had_nl else "")


def _insert_index_row(text, id, title, tier, area, validated):
    """Append a row to the '## Index' markdown table (after the last existing row)."""
    lines = text.splitlines()
    bounds = _section_bounds(lines, "Index")
    if bounds is None:
        raise ValueError("no Index section")
    start, end = bounds
    last_row = start
    for k in range(start + 1, end):
        if lines[k].lstrip().startswith("|"):
            last_row = k
    row = "| %s | %s | %s | %s | %s |" % (id, title, TIER_EMOJI[tier], area, validated)
    lines[last_row + 1:last_row + 1] = [row]
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def _set_index_validated(text, decision_id, validated):
    """Update the Validated cell of a decision's Index row (keeps index <-> body in sync)."""
    lines = text.splitlines()
    bounds = _section_bounds(lines, "Index")
    if bounds is None:
        return text
    start, end = bounds
    for i in range(start + 1, end):
        ln = lines[i]
        if not ln.lstrip().startswith("|"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if cells and cells[0] == decision_id and len(cells) >= 5:
            cells[4] = validated
            lines[i] = "| " + " | ".join(cells) + " |"
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def _entry_block_lines(lines, decision_id):
    """(start, end) line span of the '### <id> — …' entry up to the next '### '/'## '."""
    start = None
    for i, ln in enumerate(lines):
        m = _ENTRY_RE.match(ln)
        if m and m.group("id").strip() == decision_id:
            start = i
            break
    if start is None:
        return None
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("### ") or lines[j].startswith("## "):
            end = j
            break
    return (start, end)


def _rewrite_frontmatter_tier(block_lines, to_tier, validated=None, note=None):
    """Return block_lines with the frontmatter tier (and optionally validated) updated,
    and an optional disposition note appended to the body."""
    out = []
    for ln in block_lines:
        fm = _FM_RE.match(ln.strip())
        if fm:
            fields = parse_frontmatter(fm.group("body"))
            fields["tier"] = to_tier
            if validated:
                fields["validated"] = validated
            # Fields not in `order` are intentionally not re-emitted; extend `order` if the frontmatter schema grows.
            order = ["tier", "area", "files", "decided", "validated", "issue", "source"]
            rendered = " · ".join("%s: %s" % (k, fields[k]) for k in order if k in fields)
            out.append("<!-- %s -->" % rendered)
        else:
            out.append(ln)
    if note:
        out.append("_Disposition: %s_" % note)
    return out


def _move_entry(text, decision_id, to_tier, validated=None, note=None):
    """Cut the entry block from its current tier section and append it (with rewritten
    frontmatter) to the target tier section (creating it if absent)."""
    lines = text.splitlines()
    span = _entry_block_lines(lines, decision_id)
    if span is None:
        raise ValueError("entry %r not found" % decision_id)
    s, e = span
    block = lines[s:e]
    while block and block[-1].strip() == "":
        block.pop()
    block = _rewrite_frontmatter_tier(block, to_tier, validated=validated, note=note)
    del lines[s:e]
    if s < len(lines) and lines[s].startswith("## ") and s > 0 and lines[s - 1].strip() != "":
        lines.insert(s, "")
    new_text = "\n".join(lines) + ("\n" if text.endswith("\n") else "")
    return _insert_entry(new_text, to_tier, "\n".join(block))


def glob_match(files_field, rel_path):
    """True if rel_path is inside any glob in the comma-separated files field.

    A trailing '/**' matches the directory itself and anything under it.
    """
    if not files_field or not rel_path:
        return False
    rel = rel_path.strip("/")
    for raw in files_field.split(","):
        pat = raw.strip().rstrip("/")
        if not pat:
            continue
        base = pat[:-3].rstrip("/") if pat.endswith("/**") else pat
        if rel == base or rel.startswith(base + "/"):
            return True
        if fnmatch.fnmatch(rel, pat) or fnmatch.fnmatch(rel + "/x", pat):
            return True
    return False


def _now():
    return datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)


def checkpoint_is_stale(text, now=None):
    """True if the checkpoint's 'written: <ISO>' stamp is older than the limit."""
    now = now or _now()
    m = re.search(r"written:\s*([0-9T:\-]+)", text)
    if not m:
        return False  # no stamp -> treat as fresh (do not silently drop)
    try:
        written = datetime.datetime.fromisoformat(m.group(1))
    except ValueError:
        return False
    try:
        return (now - written) > datetime.timedelta(hours=CHECKPOINT_STALE_HOURS)
    except (TypeError, OverflowError):  # e.g. tz-aware vs naive mismatch
        return False


def _decision_age_days(entry, today):
    """Days since the entry was last validated (fallback: decided). None if undatable."""
    for key in ("validated", "decided"):
        raw = (entry.get(key) or "").strip()
        try:
            return (today - datetime.date.fromisoformat(raw)).days
        except (ValueError, TypeError):
            continue
    return None


def partition_pending(decisions, today):
    """Split pending (UNCONFIRMED) decisions into (active, parked).

    active = datable and age in [0, PARK_AFTER_DAYS) → newest-first (likely current work).
    parked = age >= PARK_AFTER_DAYS or undatable/future → stalest-first, undatable sunk last.
    """
    active, parked = [], []
    for d in decisions:
        if d["tier"] not in UNCONFIRMED:
            continue
        age = _decision_age_days(d, today)
        if age is not None and 0 <= age < PARK_AFTER_DAYS:
            active.append(d)
        else:
            parked.append(d)
    active.sort(key=lambda d: _decision_age_days(d, today))  # ascending age = newest first

    def _stale_key(d):
        age = _decision_age_days(d, today)
        return (0, -age) if (age is not None and age >= 0) else (1, 0)
    parked.sort(key=_stale_key)
    return active, parked


def build_inject_context(root, cwd, source, checkpoint_text=None, today=None):
    today = today or datetime.date.today()
    decisions = parse_decisions(read_text(os.path.join(root, "DECISIONS.md")))
    state = read_text(os.path.join(root, "STATE.md"))
    soul = read_text(os.path.join(root, "SOUL.md"))

    include_checkpoint = bool(checkpoint_text and checkpoint_text.strip()
                              and not checkpoint_is_stale(checkpoint_text))

    parts = ["# Project Brain (auto-loaded — do not re-derive what is stated here)"]
    if source == "compact":
        tail = ("durable baseline below; in-flight state is in the checkpoint at the end."
                if include_checkpoint else "durable baseline below.")
        parts.append("> _Resumed after compaction — " + tail + "_")

    now = state_section(state, "Now")
    nxt = state_section(state, "Next")
    blk = state_section(state, "Blockers")
    if now:
        parts.append("## Where we are (STATE.md → Now)\n" + now)
    if nxt:
        parts.append("### Next (ordered)\n" + nxt)
    if blk:
        parts.append("### Blockers / waiting-on\n" + blk)

    # Decisions cockpit — active (recent) lead; parked (legacy) collapse to a count.
    active, parked = partition_pending(decisions, today)
    repo_slug = derive_repo_slug(root) if active else None
    if active or parked:
        hdr = "## Decisions — %d worth your attention now." % len(active)
        if parked:
            hdr += " %d older one%s parked (not shown)." % (len(parked), "" if len(parked) == 1 else "s")
        lead = [hdr]
        for d in active:
            why = [ln for ln in (d.get("body") or "").splitlines() if ln.strip()]
            why_line = why[0].strip() if why else tier_phrase(d["tier"])
            refs = resolve_source(d, repo_slug)
            lead.append("▸ **%s**  (%s · %s) · %s"
                        % (d["title"], d["area"], age_phrase(_decision_age_days(d, today)), d["id"]))
            lead.append("  %s" % why_line)
            if refs:
                lead.append("  source: %s" % " · ".join(refs))
            lead.append("  → lock = %s · defer = %s · kill = %s"
                        % (CHOICE_HELP["lock"], CHOICE_HELP["defer"], CHOICE_HELP["kill"]))
        if parked:
            examples = ", ".join(d["id"] for d in parked[:3])
            more = "" if len(parked) <= 3 else ", …"
            lead.append('▸ %d older decision%s parked — say "review parked" to clear in one pass. (e.g. %s%s)'
                        % (len(parked), "" if len(parked) == 1 else "s", examples, more))
        parts.append("\n".join(lead))

    # Settled tiers collapse to one plain-language line each.
    n_locked = sum(1 for d in decisions if d["tier"] == "locked")
    if n_locked:
        parts.append("## %d settled decisions — do not reopen. "
                     "Relevant ones inject per-area below; full list in DECISIONS.md." % n_locked)
    n_deferred = sum(1 for d in decisions if d["tier"] == "deferred")
    if n_deferred:
        parts.append("## %d parked (deferred) — consciously set aside, not active." % n_deferred)

    # L1 — full locked bodies scoped to cwd subdir (capped)
    rel = os.path.relpath(cwd, root)
    if rel not in (".", ""):
        scoped = [d for d in decisions if d["tier"] == "locked" and glob_match(d["files"], rel)]
        for d in scoped[:L1_MAX_BODIES]:
            parts.append("### 🔒 %s — %s\n%s" % (d["id"], d["title"], d["body"]))
        if len(scoped) > L1_MAX_BODIES:
            parts.append("> _+%d more locked decision(s) match this area — full text in DECISIONS.md._"
                         % (len(scoped) - L1_MAX_BODIES))

    if soul:
        parts.append("## Design contract\nSOUL.md holds the locked design principles — "
                     "read it before any UI/UX/user-facing work.")

    if include_checkpoint:
        parts.append("## ⏪ Continuation checkpoint (in-flight state from before the last compaction)\n"
                     + checkpoint_text.strip())

    return "\n\n".join(parts)


def _git(root, *args):
    try:
        return subprocess.run(["git", "-C", root, *args],
                              capture_output=True, text=True, timeout=5).stdout.strip()
    except Exception:
        return ""


# owner/repo from an SSH remote:  git@<host>:owner/repo[.git]
_SSH_REMOTE_RE = re.compile(r"^git@(?P<host>[^:]+):(?P<slug>[^/]+/.+?)(?:\.git)?$")
# owner/repo from an http(s)/ssh URL:  scheme://[user@]<host>[:port]/owner/repo[.git]
_URL_REMOTE_RE = re.compile(
    r"^(?:https?|ssh)://(?:[^@/]+@)?(?P<host>[^/:]+)(?::\d+)?/(?P<slug>[^/]+/.+?)(?:\.git)?$")


def _host_is_github(host):
    """Workspace SSH aliases (github.com-personal, github.com-adobe-work) normalize to github.com."""
    return host == "github.com" or host.startswith("github.com-")


def derive_repo_slug(root):
    """'owner/repo' for a GitHub origin (incl. SSH-alias hosts); None otherwise.
    Derived once per inject/rollup — never per decision."""
    url = (_git(root, "remote", "get-url", "origin") or "").strip()
    if not url:
        return None
    for rx in (_SSH_REMOTE_RE, _URL_REMOTE_RE):
        m = rx.match(url)
        if m and _host_is_github(m.group("host")):
            return m.group("slug")
    return None


def resolve_source(entry, repo_slug):
    """Ordered source refs for a decision (most specific first). Never raises, never a broken URL."""
    refs = []
    issue = (entry.get("issue") or "").strip().lstrip("#")
    if issue:
        if repo_slug:
            refs.append("https://github.com/%s/issues/%s" % (repo_slug, issue))
        else:
            refs.append("issue #%s" % issue)
    line = entry.get("line")
    if line:
        refs.append("DECISIONS.md:%d" % line)
    files = (entry.get("files") or "").strip()
    if files:
        refs.append("governs %s" % files)
    return refs


def _atomic_write(path, text):
    """Write text to path atomically (temp in same dir, then os.replace)."""
    d = os.path.dirname(os.path.abspath(path))
    fd, tmp = tempfile.mkstemp(dir=d, prefix=".brain-", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(text)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.remove(tmp)


def _lock_path(root):
    return os.path.join(root, "_dispatch", ".locks", "brain.lock")


def acquire_lock(root, timeout=10.0, poll=0.1):
    """Kernel-managed advisory lock (fcntl.flock) on a per-repo lock file. The OS releases
    it automatically if the holder dies, so there is no stale-lock reclaim to race on.
    Returns the open fd (the lock token); pass it to release_lock."""
    path = _lock_path(root)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fd = os.open(path, os.O_CREAT | os.O_RDWR, 0o644)
    deadline = time.monotonic() + timeout
    while True:
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            return fd
        except OSError:
            if time.monotonic() >= deadline:
                os.close(fd)
                raise TimeoutError("brain lock held: %s" % path)
            time.sleep(poll)


def release_lock(fd):
    """Release a lock acquired via acquire_lock (pass the fd it returned)."""
    try:
        fcntl.flock(fd, fcntl.LOCK_UN)
    except OSError:
        pass
    try:
        os.close(fd)
    except OSError:
        pass


def _git_commit(root, paths, message):
    """Stage + commit ONLY `paths` on the current branch. Returns True/False, never raises.

    Path-scoped (`commit -- <paths>`) so the operator's other staged/dirty files are
    untouched. A git failure OR a pre-commit-hook rejection degrades to write-without-
    commit + a stderr note — it must never break an interactive skill."""
    try:
        r_add = subprocess.run(["git", "-C", root, "add", "--", *paths],
                               capture_output=True, text=True, timeout=30)
        if r_add.returncode != 0:
            sys.stderr.write("brain stage failed: %s\n" % (r_add.stderr or r_add.stdout).strip())
            return False
        r = subprocess.run(["git", "-C", root, "commit", "-m", message, "--", *paths],
                           capture_output=True, text=True, timeout=30)
        if r.returncode == 0:
            return True
        # commit rejected (e.g. pre-commit hook) — unstage so our write isn't swept
        # into the operator's next commit. The file stays modified in the worktree.
        subprocess.run(["git", "-C", root, "reset", "-q", "HEAD", "--", *paths],
                       capture_output=True, text=True, timeout=30)
        sys.stderr.write("brain commit skipped: %s\n" % ((r.stderr or r.stdout).strip()))
        return False
    except Exception as exc:
        sys.stderr.write("brain commit error: %s\n" % exc)
        return False


def _transcript_tail(transcript_path, max_msgs=6, max_chars=1200):
    """Extract the last few user/assistant text snippets from a JSONL transcript."""
    if not transcript_path or not os.path.isfile(transcript_path):
        return ""
    try:
        with open(transcript_path, encoding="utf-8") as f:
            lines = f.readlines()
    except OSError:
        return ""
    snippets = []
    for line in lines[-40:]:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except ValueError:
            continue
        role = obj.get("type") or obj.get("role")
        if role not in ("user", "assistant"):
            continue
        msg = obj.get("message") or {}  # `"message": null` -> {} (not None)
        content = msg.get("content", obj.get("content", ""))
        text = ""
        if isinstance(content, str):
            text = content
        elif isinstance(content, list):
            text = " ".join(p.get("text", "") for p in content
                             if isinstance(p, dict) and p.get("type") == "text")
        text = text.strip()
        if text:
            snippets.append("- **%s:** %s" % (role, text[:300]))
    tail = "\n".join(snippets[-max_msgs:])
    return tail[:max_chars]


def build_checkpoint(root, transcript_path, trigger):
    branch = _git(root, "rev-parse", "--abbrev-ref", "HEAD") or "(unknown)"
    head = _git(root, "log", "-1", "--oneline") or "(no commits)"
    porcelain = _git(root, "status", "--porcelain")
    changed = [ln for ln in porcelain.splitlines() if ln.strip()]
    stamp = _now().isoformat(timespec="seconds")
    lines = [
        "# Continuation checkpoint — %s" % os.path.basename(root),
        "<!-- written: %s by PreCompact (trigger: %s) -->" % (stamp, trigger),
        "",
        "## Git",
        "- branch: `%s`" % branch,
        "- HEAD: %s" % head,
        "- uncommitted: %d file(s)" % len(changed),
    ]
    if changed:
        lines += ["```", *changed[:30], "```"]
    tail = _transcript_tail(transcript_path)
    if tail:
        lines += ["", "## Recent exchange (transcript tail)", tail]
    lines += [
        "", "## Pointers",
        "- This is the *ephemeral* in-flight swap. The durable version is STATE.md → \"In flight\".",
        "- Auto-cleared when stale (>%dh) or on `clear-checkpoint`." % CHECKPOINT_STALE_HOURS,
    ]
    return "\n".join(lines)


def build_rollup(root, today=None):
    today = today or datetime.date.today()
    decisions = parse_decisions(read_text(os.path.join(root, "DECISIONS.md")))
    state = read_text(os.path.join(root, "STATE.md"))
    repo_slug = derive_repo_slug(root)
    counts = {}
    for d in decisions:
        if d["tier"]:
            counts[d["tier"]] = counts.get(d["tier"], 0) + 1

    def _item(d):
        age = _decision_age_days(d, today)
        return {
            "id": d["id"], "title": d["title"], "tier": d["tier"], "area": d["area"],
            "ageDays": age, "agePhrase": age_phrase(age),
            "sources": resolve_source(d, repo_slug), "line": d.get("line"),
        }

    active, parked = partition_pending(decisions, today)
    # Back-compat alias: the pre-3.1 'unconfirmed' shape (= active + parked, minimal fields).
    unconfirmed = [{"id": d["id"], "title": d["title"], "tier": d["tier"], "area": d["area"]}
                   for d in (active + parked)]
    index = [{"id": d["id"], "title": d["title"], "tier": d["tier"],
              "area": d["area"], "validated": d["validated"]}
             for d in decisions if d["tier"] and d["tier"] != "superseded"]
    return {
        "version": 1,
        "generatedAt": _now().isoformat(timespec="seconds") + "Z",
        "decisions": {
            "counts": counts,
            "active": [_item(d) for d in active],
            "parked": {"count": len(parked), "items": [_item(d) for d in parked]},
            "unconfirmed": unconfirmed,
            "index": index,
        },
        "choiceHelp": CHOICE_HELP,
        "state": {
            "now": state_section(state, "Now")[:800],
            "next": state_section(state, "Next")[:800],
            "blockers": state_section(state, "Blockers")[:800],
        },
    }


def _norm_title(t):
    return re.sub(r"[^a-z0-9]+", " ", (t or "").lower()).strip()


def _find_duplicate(decisions, area, title):
    nt = _norm_title(title)
    if not nt:
        return None
    for d in decisions:
        if d["tier"] not in UNCONFIRMED:   # only dedup against pending entries — never mutate locked/deferred/superseded
            continue
        if d["area"] != area:
            continue
        dt = _norm_title(d["title"])
        if not dt:
            continue
        if dt == nt or difflib.SequenceMatcher(None, dt, nt).ratio() >= DEDUP_RATIO:
            return d
    return None


def _format_entry(entry_id, title, tier, area, files, decided, validated, issue, source, why):
    order = [("tier", tier), ("area", area), ("files", files),
             ("decided", decided), ("validated", validated),
             ("issue", issue), ("source", source)]
    fm = " · ".join("%s: %s" % (k, v) for k, v in order if v)
    return "### %s — %s\n<!-- %s -->\n%s" % (entry_id, title, fm, why.strip())


def _remove_index_row(text, decision_id):
    lines = text.splitlines()
    bounds = _section_bounds(lines, "Index")
    if bounds is None:
        return text
    start, end = bounds
    keep = []
    for i, ln in enumerate(lines):
        if start < i < end and ln.lstrip().startswith("|"):
            cells = [c.strip() for c in ln.strip().strip("|").split("|")]
            if cells and cells[0] == decision_id:
                continue
        keep.append(ln)
    return "\n".join(keep) + ("\n" if text.endswith("\n") else "")


def _set_index_tier(text, decision_id, to_tier):
    lines = text.splitlines()
    bounds = _section_bounds(lines, "Index")
    if bounds is None:
        return text
    start, end = bounds
    for i in range(start + 1, end):
        ln = lines[i]
        if not ln.lstrip().startswith("|"):
            continue
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if cells and cells[0] == decision_id and len(cells) >= 3:
            cells[2] = TIER_EMOJI[to_tier]
            lines[i] = "| " + " | ".join(cells) + " |"
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def _parse_signals_text(text):
    out = []
    for line in (text or "").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except ValueError:
            continue
        if isinstance(obj, dict):     # ignore non-object JSON (strings, arrays, numbers)
            out.append(obj)
    return out


def _read_signals(root):
    return _parse_signals_text(read_text(os.path.join(root, "_dispatch", "state-signals.jsonl")))


def _read_state_input(path, label):
    """Read a --now-file/--next-file. Empty path = not provided (OK). A provided but
    unreadable path is an error (raise) — the sole STATE writer must not silently lose content."""
    if not path:
        return ""
    if not os.path.isfile(path):
        raise FileNotFoundError("state --%s-file not readable: %s" % (label, path))
    return read_text(path).strip()


def _extract_posture_block(root):
    """Carry-through for the hand-seeded '## … Project Status' block (#118).

    state --write regenerates STATE.md from a fixed scaffold; without this the
    posture cache the posture system seeds at the top would be dropped on every
    handoff. Return the existing block verbatim (header line through the line
    before the next '## '), or '' if absent — so a project with no posture block
    behaves exactly as before.

    Identified by the '## … Project Status' HEADER TEXT — the same contract the
    rest of the posture tooling uses (posture.sh `^## .*Project Status`,
    project-state-generator), NOT the compass emoji — so a block with or without
    the 🧭 icon is preserved consistently.
    """
    lines = read_text(os.path.join(root, "STATE.md")).splitlines()
    bounds = _section_bounds(lines, "Project Status")
    if bounds is None:
        return ""
    start, end = bounds
    block = lines[start:end]
    while block and block[-1].strip() == "":
        block.pop()
    return "\n".join(block)


def build_state_scaffold(root, signals=None):
    shipped = _git(root, "log", "-8", "--pretty=- %s")
    branch = _git(root, "rev-parse", "--abbrev-ref", "HEAD") or "(unknown)"
    if signals is None:
        signals = _read_signals(root)
    sig_shipped = [s["text"] for s in signals if s.get("kind") == "shipped" and s.get("text")]
    sig_block = [s["text"] for s in signals if s.get("kind") == "blocker" and s.get("text")]
    sig_next = [s["text"] for s in signals if s.get("kind") == "next" and s.get("text")]
    today = datetime.date.today().isoformat()
    parts = [
        "# State — %s   (updated: %s)" % (os.path.basename(root), today),
        "",
    ]
    posture = _extract_posture_block(root)   # carry the hand-seeded posture cache (#118)
    if posture:
        parts += [posture, ""]
    parts += [
        "## Now",
        "<!-- FILL: one ground-truth paragraph (handoff supplies via --now-file) -->",
        "",
        "## Shipped (recent)",
        shipped or "- (no recent commits)",
    ]
    if sig_shipped:
        parts += ["- " + t for t in sig_shipped]
    parts += [
        "",
        "## In flight",
        "- branch `%s`" % branch,
        "",
        "## Next (ordered)",
        "<!-- FILL: ordered list (handoff supplies via --next-file) -->",
    ]
    if sig_next:
        parts += ["%d. %s" % (i + 1, t) for i, t in enumerate(sig_next)]
    parts += [
        "",
        "## Blockers / waiting-on",
    ]
    parts += (["- " + t for t in sig_block] if sig_block else ["- (none)"])
    parts += [
        "",
        "## Pointers",
        "- Design locks: SOUL.md · How to build: CLAUDE.md · Decisions: DECISIONS.md",
    ]
    return "\n".join(parts) + "\n"


def cmd_state(args):
    if not args.write:
        print(build_state_scaffold(args.root))
        return 0
    now = _read_state_input(args.now_file, "now")     # FIX 5: validate before the lock
    nxt = _read_state_input(args.next_file, "next")
    path = os.path.join(args.root, "STATE.md")
    sig_path = os.path.join(args.root, "_dispatch", "state-signals.jsonl")
    lock = acquire_lock(args.root)
    try:
        consumed = read_text(sig_path)                # FIX 1: exact text we will render
        scaffold = build_state_scaffold(args.root, signals=_parse_signals_text(consumed))
        text = scaffold
        if now:
            text = text.replace(
                "<!-- FILL: one ground-truth paragraph (handoff supplies via --now-file) -->", now)
        if nxt:
            text = text.replace(
                "<!-- FILL: ordered list (handoff supplies via --next-file) -->", nxt)
        _atomic_write(path, text)
        # FIX 1: drain ONLY what we consumed; keep anything appended during processing
        if os.path.exists(sig_path):
            current = read_text(sig_path)
            remaining = current[len(consumed):] if current.startswith(consumed) else ""
            _atomic_write(sig_path, remaining)
    finally:
        release_lock(lock)
    if not args.no_commit:
        _git_commit(args.root, ["STATE.md"],
                    "chore(brain): update STATE (%s)" % datetime.date.today().isoformat())
    print("wrote STATE.md")
    return 0


def cmd_dispose(args):
    path = os.path.join(args.root, "DECISIONS.md")
    lock = acquire_lock(args.root)
    try:
        text = read_text(path)
        if not text:
            sys.stderr.write("dispose: no DECISIONS.md at %s\n" % args.root)
            return 1
        decisions = parse_decisions(text)
        target = next((d for d in decisions if d["id"] == args.id), None)
        if target is None:
            sys.stderr.write("dispose: id %r not found\n" % args.id)
            return 1
        if args.to == "locked":
            if not (args.operator or target["source"] in ("code", "pr")):
                sys.stderr.write("dispose: --to locked requires --operator "
                                 "(or source code/pr); source is %r\n" % target["source"])
                return 2
        validated = (datetime.date.today().isoformat()
                     if args.validated == "today" else (args.validated or None))
        note = args.note
        if args.to == "superseded" and args.by:
            note = "superseded by %s" % args.by
            if args.note:
                note += "; " + args.note
        new_text = _move_entry(text, args.id, to_tier=args.to,
                               validated=validated, note=note)
        if args.to == "superseded":
            new_text = _remove_index_row(new_text, args.id)
        else:
            new_text = _set_index_tier(new_text, args.id, args.to)
            if validated:
                new_text = _set_index_validated(new_text, args.id, validated)
        _atomic_write(path, new_text)
    finally:
        release_lock(lock)
    if not args.no_commit:
        _git_commit(args.root, ["DECISIONS.md"],
                    "chore(brain): dispose %s→%s" % (args.id, args.to))
    print("disposed %s -> %s" % (args.id, args.to))
    return 0


def cmd_capture(args):
    if args.tier not in UNCONFIRMED:
        sys.stderr.write("firewall: capture may only write %s (got %r)\n"
                         % ("/".join(sorted(UNCONFIRMED)), args.tier))
        return 2
    if args.source == "operator":
        sys.stderr.write("capture: source must be a skill name, never 'operator'\n")
        return 2
    path = os.path.join(args.root, "DECISIONS.md")
    lock = acquire_lock(args.root)
    try:
        text = read_text(path)
        if not text:
            sys.stderr.write("capture: no DECISIONS.md at %s\n" % args.root)
            return 1
        decisions = parse_decisions(text)
        today = datetime.date.today().isoformat()
        dup = _find_duplicate(decisions, args.area, args.title)
        if dup:
            # re-observed: bump validated + note; entry floats to section end (cockpit sorts by date, not position)
            new_text = _move_entry(text, dup["id"], to_tier=dup["tier"], validated=today,
                                   note="re-observed %s (%s)" % (today, args.source))
            new_text = _set_index_validated(new_text, dup["id"], today)
            result, new_id = "updated %s" % dup["id"], dup["id"]
        else:
            new_id = _next_id(decisions, args.id_prefix)
            block = _format_entry(new_id, args.title, args.tier, args.area, args.files,
                                  today, today, args.issue, args.source, args.why)
            new_text = _insert_entry(text, args.tier, block)
            new_text = _insert_index_row(new_text, id=new_id, title=args.title,
                                         tier=args.tier, area=args.area, validated=today)
            result = "created %s" % new_id
        _atomic_write(path, new_text)
    finally:
        release_lock(lock)
    if not args.no_commit:
        _git_commit(args.root, ["DECISIONS.md"], "chore(brain): capture %s" % new_id)
    print(result)
    return 0


# --- CLI ---------------------------------------------------------------------

def _stdin_json():
    try:
        raw = sys.stdin.read()
        return json.loads(raw) if raw.strip() else {}
    except (ValueError, OSError):
        return {}


def cmd_inject(args):
    hook = _stdin_json()
    cwd = hook.get("cwd") or args.root
    source = hook.get("source", "startup")
    checkpoint_text = read_text(os.path.join(args.root, "_dispatch", "CHECKPOINT.md"))
    # Auto-clear a stale checkpoint so it never haunts future sessions.
    if checkpoint_text and checkpoint_is_stale(checkpoint_text):
        try:
            os.remove(os.path.join(args.root, "_dispatch", "CHECKPOINT.md"))
        except OSError:
            pass
        checkpoint_text = ""
    ctx = build_inject_context(args.root, cwd, source, checkpoint_text=checkpoint_text)
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "SessionStart", "additionalContext": ctx}}))
    return 0


def cmd_checkpoint(args):
    hook = _stdin_json()
    transcript = hook.get("transcript_path", "")
    trigger = hook.get("trigger", "auto")
    text = build_checkpoint(args.root, transcript, trigger)
    cp_dir = os.path.join(args.root, "_dispatch")
    os.makedirs(cp_dir, exist_ok=True)
    with open(os.path.join(cp_dir, "CHECKPOINT.md"), "w", encoding="utf-8") as f:
        f.write(text + "\n")
    return 0  # allow native compaction to proceed


def cmd_clear_checkpoint(args):
    cp = os.path.join(args.root, "_dispatch", "CHECKPOINT.md")
    try:
        os.remove(cp)
    except OSError:
        pass
    return 0


def cmd_rollup(args):
    print(json.dumps(build_rollup(args.root), indent=2, ensure_ascii=False))
    return 0


def cmd_capabilities(args):
    print(json.dumps({
        "version": __version__,
        "verbs": ["inject", "checkpoint", "clear-checkpoint", "rollup",
                  "capture", "dispose", "state", "capabilities"],
    }))
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description="Project Brain compiler")
    sub = parser.add_subparsers(dest="cmd", required=True)
    for name, fn in (("inject", cmd_inject), ("checkpoint", cmd_checkpoint),
                     ("clear-checkpoint", cmd_clear_checkpoint), ("rollup", cmd_rollup),
                     ("capabilities", cmd_capabilities)):
        p = sub.add_parser(name)
        p.add_argument("--root", default=DERIVED_ROOT)
        p.set_defaults(func=fn)
    cap = sub.add_parser("capture")
    cap.add_argument("--root", default=DERIVED_ROOT)
    cap.add_argument("--id-prefix", required=True, dest="id_prefix")
    cap.add_argument("--area", required=True)
    cap.add_argument("--tier", required=True)
    cap.add_argument("--title", required=True)
    cap.add_argument("--why", required=True)
    cap.add_argument("--files", default="")
    cap.add_argument("--issue", default="")
    cap.add_argument("--source", required=True)
    cap.add_argument("--no-commit", action="store_true", dest="no_commit")
    cap.set_defaults(func=cmd_capture)
    dis = sub.add_parser("dispose")
    dis.add_argument("--root", default=DERIVED_ROOT)
    dis.add_argument("--id", required=True)
    dis.add_argument("--to", required=True,
                     choices=["locked", "deferred", "presumed", "open",
                              "needs-research", "superseded"])
    dis.add_argument("--validated", default="")
    dis.add_argument("--by", default="")
    dis.add_argument("--note", default="")
    dis.add_argument("--operator", action="store_true")
    dis.add_argument("--no-commit", action="store_true", dest="no_commit")
    dis.set_defaults(func=cmd_dispose)
    st = sub.add_parser("state")
    st.add_argument("--root", default=DERIVED_ROOT)
    st.add_argument("--write", action="store_true")
    st.add_argument("--now-file", default="", dest="now_file")
    st.add_argument("--next-file", default="", dest="next_file")
    st.add_argument("--no-commit", action="store_true", dest="no_commit")
    st.set_defaults(func=cmd_state)
    args = parser.parse_args(argv)
    try:
        return args.func(args)
    except Exception as exc:  # a hook/read verb must never break the session
        sys.stderr.write("brain_compile %s: %s\n" % (args.cmd, exc))
        if args.cmd == "inject":  # still emit valid (empty) hook JSON
            print(json.dumps({"hookSpecificOutput": {
                "hookEventName": "SessionStart", "additionalContext": ""}}))
        return 1 if args.cmd in WRITE_VERBS else 0  # failed WRITE must NOT report success


if __name__ == "__main__":
    sys.exit(main())
