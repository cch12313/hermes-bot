# hermes-bot 進度與決策紀錄

> 背景來源：`docs/Gemini-AI個人助理-20261004-2233.md`（與 Gemini 的討論紀錄，2026/10/1–10/2）。
> `docs/` 僅存在本機、不進版控；本文件刻意省略主機路徑、金鑰名稱等環境細節，需要時請查該檔或 VPS 上的設定。

## 專案定位

- 本 repo 的範圍：**Go Telegram Bot**，負責即時回報進度並寫入 Obsidian vault。
- 自行從頭實作，**不採用** Gemini 提供的程式碼，只參考它的架構概念。
- 核心原則：**以個人助手為主**，每個設計都要在「節省成本」與「實際成效」之間權衡。產品化（多租戶、計費）目前不在範圍內。

## 背景與痛點

- Hermes（VPS 自架的 Agent）每次回報都跑一次完整呼叫，成本高（7 天約 NT$165），所以只能一天回報一次。
- Heptabase 沒有 API，待辦要手動搬，因此已改用 Obsidian。

## 整體架構（已定）

| 元件 | 職責 |
|---|---|
| Hermes（VPS, docker-compose, `claude-sonnet-5`） | 每日 07:00 晨間排程：讀目標、待辦、日曆，產出 Daily Note；對練模式（規則寫在 SOUL.md） |
| Go Telegram Bot（本 repo） | 即時回報：用輕量模型把自然語言轉成結構化資料，在 Daily Note 打勾 `- [x]`，附上 💡 復盤與 🏷 標籤（例如 `#needs_review`） |
| Obsidian vault | GitHub Private Repo。電腦端用 Obsidian Git 同步，VPS 端掛載進 Hermes 容器的可寫目錄 |

回饋閉環：隔天晨間排程掃描 `#needs_review`，自動排入加強練習。

## 已完成

- Hermes 模型改為 `claude-sonnet-5`，SOUL.md 改寫為 Staff Engineer 導師角色。
- 從 Heptabase 改用 Obsidian + GitHub Private Repo，VPS 端用 vault 專用的獨立 deploy key（與 Hermes 備份 repo 的 key 分開）。
- VPS 上 vault 的權限與 push 已打通；Hermes 資料備份 repo 已排除 vault 目錄，避免巢狀 repo。
- 晨間 cron 已設定，時間從 08:00 改為 **07:00**。

## 待辦（待討論如何執行）

### Bot 設計
- [ ] 選定輕量模型（候選：Gemini 2.5 Flash-Lite、GPT-6-Luna、Haiku 4.5），依成本與成效評估。
- [ ] 任務比對策略：避免單純用字串包含判斷，造成勾錯任務。
- [ ] 找不到今日 Daily Note 時的處理方式。
- [ ] Telegram User ID 白名單。
- [ ] Git 同步流程：先 pull 再寫入；push 失敗要回報給使用者，不能吞掉錯誤。
- [ ] Bot 與 Hermes 同時寫 vault 時的並發與衝突處理。
- [ ] Bot 與 Hermes 是否共用同一個 Telegram bot token，以及兩者的分工。
- [ ] 部署方式，以及容器內 SSH key、known_hosts、git 設定與掛載路徑。

### 既有環境的風險
- [ ] VPS 上 vault 目錄的檔案權限：檢視目前設定，改為最小權限（細節見本機 docs）。
- [ ] 容器內 git over SSH 的主機驗證設定：檢視並改為固定 known_hosts（細節見本機 docs）。
- [ ] 新版 SOUL.md 變長，每次呼叫的 input token 增加；需確認成本影響，以及 Prompt Caching 是否生效。

### 之後再說
- [ ] Google Calendar 串接（目前用 iCloud，有需要再開放）。
- [ ] Sparring 對練的互動流程（按鈕、session 狀態機、`/end` 沉澱成 ADR）。

## 決策紀錄

- **2026-10-05**：本 repo 定位為 Go Telegram Bot，自行重新實作，不沿用 Gemini 的程式碼；設計原則為個人助手優先、兼顧成本與成效。
