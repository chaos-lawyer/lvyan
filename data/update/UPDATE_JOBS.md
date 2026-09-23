# 自动更新任务配置

`update_jobs.json` 是自动更新功能的唯一策略入口。Schema 只需永久注册一次
`auto_update_processor`，以后调整现有任务无需修改 Schema 或通用更新管理器。

## 通用字段

- `poll_interval_seconds`：Rime 活跃期间的轮询间隔，最低 60 秒。
- `enabled`：是否启用任务。
- `handler`：对应 `lua/update_handlers/<名称>.lua`。
- `max_daily_attempts`：每天最多发起的网络请求数，手动触发也受此限制。
- `retry_interval_seconds`：同一任务两次网络请求的最短间隔，多实例和重启也受此限制。
- `timeout_seconds`：单次下载超时，限制在 1–30 秒。

## 当前任务

- `lpr`：`url` 可更换 CFETS 数据地址。
- `holidays`：`start_month`、`start_day` 控制次年数据检测窗口；
  `url_template` 使用 `{year}` 作为目标年份占位符；`require_papers` 要求数据包含公告来源。

## 扩展任务

同类策略只需修改 JSON。新数据格式需要新增一个 handler，但无需修改 Schema、
`auto_update_processor.lua` 或 `update_manager.lua`。handler 提供：

- `should_check(job) -> needed, target`
- `force_target(job) -> target`（可选）
- `build_request(job, target) -> { url, tmp_path }`
- `check_and_apply(job) -> applied, consumed`

管理器统一负责配置加载、8 小时轮询、每日次数、异步下载、状态文件和日志。
