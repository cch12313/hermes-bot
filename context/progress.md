# hermes-bot 進度與決策紀錄

> 背景來源：`docs/Gemini-AI個人助理-20261004-2233.md`（與 Gemini 的討論紀錄，2026/10/1–10/2）。
> `docs/` 僅存在本機、不進版控；本文件刻意省略主機路徑、金鑰名稱等環境細節，需要時請查該檔或 VPS 上的設定。

## 交接（每次 push 前更新）

> 由 `.claude/hooks/require-handoff.sh` 強制：即將推送的 commits 沒有更新本檔就無法 push；Obsidian 的 Nexus `Sync Log.md` 沒有 HEAD hash 也無法 push（流程見 `CLAUDE.md`）。

**最後更新**：2026-10-05

- **剛完成**：建立 Obsidian 專案資料夾 `~/Documents/obsidian/Alvin/projects/Nexus/`（產品、架構、維運分類），並新增 push 前的同步規則（`CLAUDE.md`）與 hook 檢查。前一項：git 安全規則已寫入 SOUL.md。
- **下一步**：進入 Bot 設計，從「選定輕量模型」開始。
- **待觀察**：
  - 在 Telegram 問 Hermes「push 遇到 `Host key verification failed` 會怎麼做」，確認它回答停下回報（新規則是否生效）。
  - 下一次 07:00 排程與每日備份是否正常 push（SOUL.md 的變更應隨備份 repo 推上去）、vault 是否出現非 Hermes 使用者擁有的新檔案。
- **Blockers**：無。

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
- [ ] Bot 寫入 vault 時必須使用與 Hermes 容器相同的執行使用者（UID），否則會再次出現檔案擁有者不一致與 git `dubious ownership`。
- [ ] Bot 與 Hermes 同時寫 vault 時的並發與衝突處理。
- [ ] Bot 與 Hermes 是否共用同一個 Telegram bot token，以及兩者的分工。
- [ ] 部署方式，以及容器內 SSH key、known_hosts、git 設定與掛載路徑（沿用下方「VPS git 環境現況」的原則）。

### 既有環境的風險
- [x] VPS 上 vault 目錄的檔案權限：已改為 Hermes 執行使用者擁有、目錄 755／檔案 644（2026-10-05）。
- [x] 容器內 git over SSH 的主機驗證：已移除所有關閉主機驗證的設定，改用已核對指紋的固定 known_hosts（2026-10-05）。
- [x] 在 SOUL.md 加入 git 安全規則：不得讀取或複製私鑰；不得修改 SSH config、known_hosts、`core.sshCommand`（也不設 `GIT_SSH_COMMAND`），不得用關閉主機驗證繞過錯誤；不得對 vault、備份 repo、`.ssh/` 使用 sudo／chown／chmod；git 認證、主機驗證或權限錯誤時停下回報（2026-10-05）。
- [ ] 觀察下一次 07:00 排程與每日備份：確認 vault 無非 Hermes 使用者擁有的新檔案，兩個 repo 都能正常 push。
- [ ] 新版 SOUL.md 變長，每次呼叫的 input token 增加；需確認成本影響，以及 Prompt Caching 是否生效。

### 之後再說
- [ ] Google Calendar 串接（目前用 iCloud，有需要再開放）。
- [ ] Sparring 對練的互動流程（按鈕、session 狀態機、`/end` 沉澱成 ADR）。

## VPS git 環境現況（2026-10-05 整理）

- Hermes 容器內以非 root 的專用使用者執行，所有 git 操作都在容器內以該使用者進行，不在 host 上用 root 操作 vault 或備份 repo。
- 兩個 repo 各用一把 deploy key，透過 SSH config 的 Host 別名區分；不使用全域或 repo 層級的 `core.sshCommand` 強制指定 key（它會蓋過 Host 別名，導致用錯 key）。
- 各 Host 設定 `IdentitiesOnly yes`，只提供指定的 key。
- 主機驗證使用已對照 GitHub 官方指紋的 known_hosts，不使用 `StrictHostKeyChecking no`。
- 細節（路徑、金鑰名稱、診斷過程）見本機 docs，不寫入本公開 repo。

## 決策紀錄

- **2026-10-05**：本 repo 定位為 Go Telegram Bot，自行重新實作，不沿用 Gemini 的程式碼；設計原則為個人助手優先、兼顧成本與成效。
- **2026-10-05**：完成 VPS git 環境修正（vault 權限、主機驗證、移除強制指定 key 的設定、清除舊的 git 目錄與重複金鑰）。因無法排除 Hermes 備份用 deploy key 曾被 Agent 讀入對話，已輪替該 key。
- **2026-10-05**：git 安全規則只寫入 SOUL.md（每次呼叫都會載入），不另存 Hermes 記憶，避免重複與額外 token；另加入禁止對 vault／備份 repo／`.ssh/` 使用 sudo、chown、chmod，以防再次出現檔案擁有者錯亂。
- **2026-10-05**：產品與架構文件放在 Obsidian `projects/Nexus/`（Product／Architecture／Operations 子資料夾），只有 `Nexus.md` 用 `type: project`，其餘用 `type: project-doc` 以免進入 Projects MOC。每次 push 前依 `CLAUDE.md` 同步並在 `Sync Log.md` 記下 HEAD hash，由 hook 檢查。此資料夾結構是 vault「projects 純扁平」規則的例外，經使用者指定。
