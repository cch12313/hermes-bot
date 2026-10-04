#!/usr/bin/env bash
# PreToolUse(Bash) hook：攔截 git push，push 前有兩道檢查（僅在有待推送 commits 時進行）：
#   1. 即將推送的 commits 必須修改 context/progress.md（交接內容）。
#   2. Obsidian 的 Nexus 筆記必須已同步：
#      $HOME/Documents/obsidian/Alvin/projects/Nexus/Sync Log.md 需含 HEAD 的 7 碼短 hash。
#      該檔案不存在（這台機器沒有 vault）則略過此檢查。
# 任一檢查未通過就輸出 deny JSON 並結束（只會輸出一個 JSON）。
cmd=$(jq -r '.tool_input.command // ""')

# 只處理 git push（含 git -C <dir> push）
printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push' || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# 沒有 upstream 或沒有待推送的 commit 時不攔
git rev-parse -q --verify '@{u}' >/dev/null 2>&1 || exit 0
[ "$(git rev-list --count '@{u}..HEAD')" -gt 0 ] || exit 0

# 檢查 1：progress.md 是否在待推送的 commits 中被修改
if ! git diff --name-only '@{u}' HEAD -- context/progress.md | grep -q .; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: "即將推送的 commits 沒有更新 context/progress.md。請先把本次要交接的事項（完成了什麼、下一步、blockers）寫入 context/progress.md 的「交接」段落並 commit，再 push。"}}'
  exit 0
fi

# 檢查 2：Obsidian Nexus 的 Sync Log 是否已記錄 HEAD
sync_log="$HOME/Documents/obsidian/Alvin/projects/Nexus/Sync Log.md"
[ -f "$sync_log" ] || exit 0

head_hash=$(git rev-parse --short=7 HEAD)
if ! grep -qF -- "$head_hash" "$sync_log"; then
  jq -n --arg h "$head_hash" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: ("Obsidian 的 Nexus 筆記尚未同步本次 push（Sync Log 找不到 HEAD " + $h + "）。請依 CLAUDE.md 的「Obsidian 同步」段落更新 ~/Documents/obsidian/Alvin/projects/Nexus/ 的對應筆記，並在 Sync Log.md 追加一行含 " + $h + " 的紀錄，再 push。")}}'
  exit 0
fi

exit 0
