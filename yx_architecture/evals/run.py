#!/usr/bin/env python3
"""Run the eval cases with all four skills loaded at once.

`claude plugin eval` loads exactly one plugin into the sandbox, and a plugin may
only reference files inside its own directory. The three package skills live in
the packages, so this script assembles a throwaway bundle - this plugin plus the
three package skills - and points the eval runner at it. Results are copied back
into evals/results/.

Every argument is passed through, so the usual flags work:

    python3 evals/run.py --case scope-vs-module --runs 1 --ablation none
    python3 evals/run.py --threshold 0.8 -j 4
"""

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PLUGIN = Path(__file__).resolve().parent.parent
OPENSOURCE = PLUGIN.parent

PACKAGE_SKILLS = [
    OPENSOURCE / "yx_scope/packages/yx_scope/skills/yx-scope-fundamentals",
    OPENSOURCE / "yx_state/packages/yx_state/skills/yx-state-fundamentals",
    OPENSOURCE / "yx_navigation/packages/yx_navigation/skills/yx-navigation-fundamentals",
]


# https://agentskills.io/specification#skill-md-format
DESCRIPTION_LIMIT = 1024


def description_length(skill_md: Path) -> int:
    """Length of the folded `description` value, without parsing YAML.

    Every description here is either one line or a `>` block, so joining the
    indented lines with a space reproduces what a YAML parser would produce.
    """
    lines = skill_md.read_text().splitlines()
    if not lines or lines[0].strip() != "---":
        return 0

    parts: list[str] = []
    collecting = False
    for line in lines[1:]:
        if line.strip() == "---":
            break
        if line.startswith("description:"):
            collecting = True
            head = line.split(":", 1)[1].strip()
            if head not in (">", "|", ">-", "|-", ""):
                parts.append(head)
            continue
        if collecting:
            if line[:1].isspace():
                parts.append(line.strip())
            else:
                break
    return len(" ".join(parts))


def check_descriptions(bundle: Path) -> None:
    """The description drives triggering, and the spec caps it at 1024 chars.

    Nothing in Claude Code enforces this, so an over-long description only
    surfaces where a stricter validator runs - by then it has already shipped.
    """
    too_long = [
        (skill_md, length)
        for skill_md in sorted(bundle.rglob("SKILL.md"))
        if (length := description_length(skill_md)) > DESCRIPTION_LIMIT
    ]
    if too_long:
        for skill_md, length in too_long:
            print(
                f"{skill_md.parent.name}: description is {length} characters, "
                f"the spec allows {DESCRIPTION_LIMIT}",
                file=sys.stderr,
            )
        sys.exit("description too long, see https://agentskills.io/specification")


def build_bundle(destination: Path) -> None:
    shutil.copytree(
        PLUGIN,
        destination,
        ignore=shutil.ignore_patterns("results", ".eval-runs", ".git", "__pycache__"),
    )
    for skill in PACKAGE_SKILLS:
        if not skill.is_dir():
            sys.exit(f"missing package skill: {skill}")
        shutil.copytree(skill, destination / "skills" / skill.name)
    check_descriptions(destination)


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="yx-arch-evals-") as tmp:
        bundle = Path(tmp) / "yx_architecture"
        build_bundle(bundle)

        # The bundle is a fresh directory on every run, so the trust prompt would
        # fire every time. It is assembled here, from this repository, by this
        # script - nothing else ends up in it.
        args = list(sys.argv[1:])
        if "--trust-plugin" not in args:
            args.append("--trust-plugin")

        completed = subprocess.run(
            ["claude", "plugin", "eval", str(bundle), *args],
            cwd=bundle,
        )

        produced = bundle / "evals" / "results"
        if produced.is_dir():
            target = PLUGIN / "evals" / "results"
            target.mkdir(parents=True, exist_ok=True)
            for item in produced.iterdir():
                destination = target / item.name
                if destination.exists():
                    shutil.rmtree(destination) if destination.is_dir() else destination.unlink()
                shutil.move(str(item), str(destination))
            print(f"results: {target}")

        return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
