#!/usr/bin/env python3
"""check_vendored_drift.py — is our vendored prompt-engineering behind upstream?

This repo vendors ``skills/prompt-engineering/`` — copied once from upstream
(see its PROVENANCE.md) and then **owned locally**. We edit it freely; there is
no enforced sync and no manifest.

This script is a single on-demand probe: fetch the upstream skill and diff it
against our copy, so you can tell whether **fresher content exists** before you
rely on the (fast-moving, model-specific) guides. Run it when you care; ignore
it otherwise. It never runs automatically and the framework does not depend on
it.

Needs git + network. Skips gracefully if offline.

Usage:
    python3 scripts/check_vendored_drift.py
Windows: use ``python`` or ``py -3``.

Exit code: 0 if our copy matches upstream HEAD (or offline/no-git); 1 if they
differ (fresher upstream content exists — review and copy in manually if wanted).
"""

import hashlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SKILL = "prompt-engineering"
LOCAL_DIR = REPO / "skills" / SKILL
UPSTREAM_URL = "https://github.com/CodeAlive-AI/ai-driven-development.git"
UPSTREAM_PATH = f"skills/{SKILL}"
# Files present locally that did not come from upstream — never compared.
LOCAL_ONLY = {"LICENSE", "PROVENANCE.md"}


def say(msg=""):
    print(msg)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def local_files():
    out = {}
    for p in sorted(LOCAL_DIR.rglob("*")):
        if p.is_file() and p.relative_to(LOCAL_DIR).as_posix() not in LOCAL_ONLY:
            out[p.relative_to(LOCAL_DIR).as_posix()] = sha256_file(p)
    return out


def run_git(args, **kw):
    return subprocess.run(["git", *args], capture_output=True, text=True, **kw)


def fetch_upstream_head():
    """Sparse-clone upstream at HEAD; return (head_sha, {rel: sha256}) or (None, None)."""
    tmp = Path(tempfile.mkdtemp(prefix="vendored-drift-"))
    try:
        if run_git(["clone", "--quiet", "--no-checkout", "--filter=blob:none",
                    "--sparse", UPSTREAM_URL, str(tmp)]).returncode != 0:
            return None, None
        if run_git(["-C", str(tmp), "sparse-checkout", "set", "--no-cone",
                    UPSTREAM_PATH]).returncode != 0:
            return None, None
        if run_git(["-C", str(tmp), "checkout", "--quiet"]).returncode != 0:
            return None, None
        head = run_git(["-C", str(tmp), "rev-parse", "HEAD"]).stdout.strip()
        base = tmp / UPSTREAM_PATH
        if not base.is_dir():
            return head, {}
        files = {}
        for p in base.rglob("*"):
            if p.is_file():
                files[p.relative_to(base).as_posix()] = sha256_file(p)
        return head, files
    except Exception:
        return None, None
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    if shutil.which("git") is None:
        say("! git not found — install git, or skip (this probe is optional).")
        return 0

    say(f"Vendored skill : {SKILL}")
    say(f"Upstream       : {UPSTREAM_URL}  (path: {UPSTREAM_PATH})")
    say("")

    head, upstream = fetch_upstream_head()
    if head is None:
        say("! could not reach upstream (offline / network / clone failed).")
        say("  Nothing to compare. This probe is optional — the framework is unaffected.")
        return 0

    say(f"Upstream HEAD  : {head[:12]}")
    say("")

    ours = local_files()

    changed = sorted(r for r in upstream if r in ours and upstream[r] != ours[r])
    only_up = sorted(set(upstream) - set(ours))
    only_us = sorted(set(ours) - set(upstream))

    if not changed and not only_up and not only_us:
        say(f"UP TO DATE — our copy matches upstream HEAD ({len(ours)} file(s)).")
        return 0

    say(f"DRIFT — upstream has changed since this skill was vendored.")
    if changed:
        say(f"  changed ({len(changed)}):")
        for r in changed:
            say(f"    {r}")
    if only_up:
        say(f"  added upstream ({len(only_up)}):")
        for r in only_up:
            say(f"    {r}")
    if only_us:
        say(f"  only local ({len(only_us)}) — likely our own edits:")
        for r in only_us:
            say(f"    {r}")
    say("")
    say("This is informational. We own this copy. If you want the fresher content,")
    say("copy it in manually and update the source note in skills/prompt-engineering/PROVENANCE.md:")
    say(f"  {UPSTREAM_URL.removesuffix('.git')}/tree/{head[:12]}/{UPSTREAM_PATH}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
