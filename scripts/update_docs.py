#!/usr/bin/env python3
"""Fills the <!-- auto:NAME --> blocks in README.md and docs/ from an evidence folder.

  python3 scripts/update_docs.py --evidence .evidence [--ci-proof URL] [--run-url URL]

Images must already be copied to docs/images/. Blocks with nothing to show keep a note.
"""
import argparse
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
IMAGES = ROOT / "docs" / "images"
NOT_YET = "_Not generated yet. Run `bash maple-wallet-lab.sh evidence`._"


def fill(path, name, content):
    file = ROOT / path
    text = file.read_text(encoding="utf-8")
    pattern = re.compile(rf"(<!-- auto:{name} -->\n)(.*?)(\n<!-- /auto:{name} -->)", re.S)
    if not pattern.search(text):
        print(f"skip: no auto:{name} block in {path}")
        return
    file.write_text(pattern.sub(lambda m: m.group(1) + (content or NOT_YET) + m.group(3), text), encoding="utf-8")
    print(f"filled auto:{name} in {path}")


def gallery(items, prefix):
    present = [(f, caption) for f, caption in items if (IMAGES / f).exists()]
    if not present:
        return None
    header = "| " + " | ".join(caption for _, caption in present) + " |"
    rule = "|" + "---|" * len(present)
    row = "| " + " | ".join(f'<img src="{prefix}images/{f}" width="220" alt="{caption}">' for f, caption in present) + " |"
    return "\n".join([header, rule, row])


def gif(name, alt, prefix, width=320):
    return f'<img src="{prefix}images/{name}" width="{width}" alt="{alt}">' if (IMAGES / name).exists() else None


def read(path):
    return path.read_text(encoding="utf-8").strip() if path.exists() else None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--evidence", required=True)
    parser.add_argument("--ci-proof", default="")
    parser.add_argument("--run-url", default="")
    args = parser.parse_args()
    evidence = pathlib.Path(args.evidence)

    fill("docs/day-1.md", "screens-day1", gallery([
        ("light-02-accounts.png", "Accounts, light"),
        ("dark-02-accounts.png", "Accounts, dark"),
        ("light-03-account-detail.png", "Account detail"),
    ], ""))
    fill("docs/day-2.md", "recording-offline", gif("offline.gif", "Offline: cached balances with a banner", ""))
    fill("docs/day-3.md", "recording-sso", gif("sso-refresh.gif", "Sign in, silent token refresh, sign out", ""))
    fill("docs/day-4.md", "screens-day4", gallery([
        ("ax5-02-accounts.png", "Accounts at AX5 text"),
        ("ax5-04-transfer.png", "Transfer at AX5 text"),
        ("dark-03-account-detail.png", "Detail, Dark Mode"),
        ("ipad-03-account-detail.png", "iPad split view"),
    ], ""))
    fill("docs/day-4.md", "recording-main", gif("demo.gif", "Sign in, open an account, send a transfer", ""))
    fill("README.md", "demo", gif("demo.gif", "Maple Wallet demo", "docs/", 280))

    audit = read(evidence / "a11y-audit.md")
    fill("docs/accessibility.md", "a11y-audit", audit)

    coverage = read(evidence / "coverage.md")
    fill("README.md", "coverage", coverage)
    fill("docs/day-5.md", "coverage", coverage)

    proof = None
    if args.ci_proof:
        proof = (f"[This throwaway pull request]({args.ci_proof}) added a deliberately failing test. "
                 "CI went red and GitHub blocked the merge, so the PR was closed unmerged.")
    fill("docs/day-5.md", "ci-proof", proof)

    trace_names = sorted(p.name for p in (evidence / "traces").glob("*.trace")) if (evidence / "traces").exists() else []
    traces = None
    if trace_names:
        where = f" in the [Evidence workflow run]({args.run_url}) (artifact `evidence`)" if args.run_url else ""
        traces = ("Recorded automatically on a Simulator" + where + ": "
                  + ", ".join(f"`{n}`" for n in trace_names)
                  + ". Open them on a Mac with Instruments.")
    fill("docs/day-5.md", "traces", traces)


if __name__ == "__main__":
    main()
