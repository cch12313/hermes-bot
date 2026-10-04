# hermes-bot

Go Telegram Bot，屬於個人 AI 助理系統 Nexus。開始工作前先讀 `context/progress.md`。

## Obsidian 同步（每次 push 前）

本 repo 對應 vault 資料夾 `~/Documents/obsidian/Alvin/projects/Nexus/`。每次 `git push` 前（commit 完成、HEAD 已確定之後）：

1. 依本次推送的 commits（`git log @{u}..HEAD`），更新受影響的筆記：

   | 變更內容 | 要更新的筆記 |
   |---|---|
   | 進度、下一步、待辦 | `Nexus.md` 的 `## Status`、`## Current Todo`（整段覆蓋，反映現況） |
   | 新決策 | `Nexus.md` 的 `## Key Decisions Log`（追加一行結論，不含理由） |
   | 階段、待辦分組 | `Product/Roadmap.md` |
   | 定位、原則、範圍 | `Product/Product Vision.md` |
   | 元件、資料流 | `Architecture/System Overview.md` |
   | Hermes、SOUL.md | `Architecture/Hermes Agent.md` |
   | Bot 設計或實作 | `Architecture/Telegram Bot.md` |
   | vault 同步、寫入、並發 | `Architecture/Vault Sync.md` |
   | VPS、SSH、權限 | `Operations/VPS Environment.md` |
   | 安全規則 | `Operations/Security Rules.md` |

   有改的筆記同時更新 frontmatter 的 `updated`。新增分類或筆記時，同步更新 `Nexus.md` 的筆記地圖。
2. 在 `Sync Log.md` 的 `## Log` 追加一行：`- YYYY-MM-DD <HEAD 7 碼短 hash>：<一句話摘要>；更新：<筆記清單>`。沒有筆記需要改時也要追加，更新寫「無」。

`.claude/hooks/require-handoff.sh` 會檢查 `Sync Log.md` 是否含即將推送的 HEAD hash，沒有就擋下 push。

寫入規則：
- 遵守 vault 的 `~/Documents/obsidian/Alvin/CLAUDE.md`（英文檔名、bare date、tag 先查 `Tags.md`）。
- 只有 `Nexus.md` 用 `type: project`；其他筆記用 `type: project-doc`，不加 `status`，避免出現在 Projects MOC。
- 完整決策理由留在 `context/progress.md`，vault 只放結論。
- 本 repo 是公開的，vault 是私人的；兩邊都不寫金鑰、token、主機路徑。
- 還沒定案的想法不寫進上述筆記，改寫進 `~/Documents/obsidian/Alvin/inbox/<簡短標題>.md`，內文帶 `[[Nexus]]`。
