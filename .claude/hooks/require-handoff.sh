#!/usr/bin/env bash
# PreToolUse(Bash) hook：git push 前，要求即將推送的 commits 有更新 context/progress.md 的交接內容。
cmd=$(jq -r '.tool_input.command // ""')

# 只處理 git push（含 git -C <dir> push）
printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push' || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# 沒有 upstream 或沒有待推送的 commit 時不攔
git rev-parse -q --verify '@{u}' >/dev/null 2>&1 || exit 0
[ "$(git rev-list --count '@{u}..HEAD')" -gt 0 ] || exit 0

if git diff --name-only '@{u}' HEAD -- context/progress.md | grep -q .; then
  exit 0
fi

jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
  permissionDecisionReason: "即將推送的 commits 沒有更新 context/progress.md。請先把本次要交接的事項（完成了什麼、下一步、blockers）寫入 context/progress.md 的「交接」段落並 commit，再 push。"}}'
