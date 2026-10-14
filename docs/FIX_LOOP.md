# Fix loop for CI model review

The ai-review workflow (.github/workflows/ai-review.yml) posts findings as PR comments.
Loop until the reviewer is quiet. Max 3 rounds.

1. Fetch comments: gh pr view <n> --comments, or gh api repos/OWNER/REPO/issues/<n>/comments.
2. Triage each finding: fix it, or reply with the reason you disagree. Never edit a test to pass.
3. Run the local gates: flutter analyze, flutter test --coverage, tool/coverage_check.sh.
4. Push is a HUMAN step in this kit. Commit and push yourself, then wait for the workflow to finish.
5. Re-read the new comments. Stop when no new comments appear, or after round 3.
6. After round 3, stop and hand the open items to the human with the comment links.

Agents do not stage, commit, or push. The loop only edits files and reads comments.
