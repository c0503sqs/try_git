# gh run 与 workflow

## 能学到什么

- 查看、触发、取消、重跑 GitHub Actions
- 用 `--log-failed` 快速定位失败步骤
- 知道 `workflow_dispatch` 和 `workflow` scope 的关系
- 用 `--json` / `--jq` 做自动化

## 两个命令族

| 命令 | 管理对象 |
| --- | --- |
| `gh workflow` | 工作流定义（`.github/workflows/*.yml`） |
| `gh run` | 某一次具体运行 |

工作流是「模板」，运行是「实例」。

## 查看工作流

```bash
gh workflow list
```

```text
CI	active	12345678
Release	draft	87654321
```

查看某个工作流：

```bash
gh workflow view ci.yml
gh workflow view ci.yml --web
gh workflow view 12345678
```

启用 / 禁用：

```bash
gh workflow disable ci.yml
gh workflow enable ci.yml
```

## 手动触发

```bash
gh workflow run ci.yml
gh workflow run ci.yml --ref main
gh workflow run ci.yml -f environment=staging -f dry_run=true
```

前提：workflow 文件里定义了 `workflow_dispatch`：

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 部署环境
        required: true
        default: staging
      dry_run:
        type: boolean
        default: false
```

没有这个触发器时，`gh workflow run` 会报「workflow does not have workflow_dispatch trigger」。

触发后命令立刻返回，运行是异步的。用 `gh run list` 找它。

## 查看运行

```bash
gh run list
gh run list --limit 10
gh run list --workflow ci.yml
gh run list --branch main
gh run list --status failure
gh run list --json databaseId,status,conclusion,headBranch \
  --jq '.[] | "\(.databaseId) \(.status) \(.conclusion) \(.headBranch)"'
```

状态字段：

| 字段 | 取值 |
| --- | --- |
| `status` | `queued`、`in_progress`、`completed` |
| `conclusion` | `success`、`failure`、`cancelled`、`skipped`、`timed_out`、`action_required` |

查看单次运行：

```bash
gh run view 123456789
gh run view 123456789 --log
gh run view 123456789 --log-failed
gh run view 123456789 --web
gh run view 123456789 --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
```

`--log-failed` 只输出失败步骤的日志，排查时最有用。完整日志可能几十万行，先看失败部分。

实时跟踪：

```bash
gh run watch 123456789
gh run watch 123456789 --exit-status   # 失败时以非零码退出，适合脚本
```

## 重跑、取消、下载

```bash
gh run rerun 123456789
gh run rerun 123456789 --failed        # 只重跑失败的 job
gh run cancel 123456789
gh run download 123456789              # 下载所有 artifacts
gh run download 123456789 -n coverage  # 下载指定 artifact
```

## 典型排查流程

```bash
# 1. 找最近失败的运行
gh run list --status failure --limit 5

# 2. 看失败日志
gh run view <id> --log-failed

# 3. 修代码，推送

# 4. 等新运行
gh run watch <new-id> --exit-status
```

## 权限

| 操作 | 需要 |
| --- | --- |
| 查看 workflow / run | `repo`（公开仓库可匿名） |
| 手动触发 | 对仓库有写权限 |
| 重跑、取消 | 写权限 |
| 推送 `.github/workflows/*` | token 需 `workflow` scope |

本机当前 token 没有 `workflow` scope，推 workflow 文件会被拒：

```text
refusing to allow a Personal Access Token to create or update workflow
`.github/workflows/ci.yml` without `workflow` scope
```

补齐：

```bash
gh auth refresh -s workflow
```

## 常见失败原因

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| run 一直 `queued` | runner 不足、并发限制、账单问题 | 看仓库 Actions 设置 |
| `workflow_dispatch` 报错 | 文件里没定义该触发器 | 加 `on: workflow_dispatch` |
| 日志里 `Permission denied` | `GITHUB_TOKEN` 权限不足 | 在 workflow 里写 `permissions:` |
| 手动触发没有输入框 | inputs 没定义 | 在 `workflow_dispatch.inputs` 下声明 |
| 重跑仍然失败 | 代码或配置没变 | 先修再 `rerun` |

## 注意事项

1. **`gh run list` 默认 20 条**，加 `--limit` 或 `--created` 过滤。
2. **run id 和 workflow id 不是一回事**。`gh run view` 用 run id（`databaseId`），`gh workflow view` 用文件名或 workflow id。
3. **日志有时效**。GitHub 会清理旧运行的日志，重要失败要及时保存。
4. **`gh run watch` 会阻塞终端**，CI 时间长时另开一个终端。
5. **`--log-failed` 在没有失败时不输出**，先确认结论是 `failure`。
6. **`workflow` scope 只影响推送 workflow 文件**，不改代码的提交不需要它。

## 练习

1. 在测试仓库里添加一个带 `workflow_dispatch` 的 workflow，用 `gh workflow list` 和 `gh workflow view` 查看。
2. 用 `gh workflow run` 手动触发，再用 `gh run list` 找到它。
3. 故意让一个步骤失败，用 `gh run view <id> --log-failed` 定位。
4. 用 `gh run rerun <id> --failed` 重跑，再用 `gh run watch --exit-status` 等待结果。

---

上一篇：[gh pr](03-pr.md) · 下一篇：[gh release](05-release.md)
