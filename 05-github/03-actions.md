# Actions：自动化工作流

## 能学到什么

- 看懂一个 workflow 文件的结构
- 用触发条件、矩阵、缓存、产物写一条可用的 CI
- 知道 `GITHUB_TOKEN` 的权限模型
- 避免常见的权限和安全坑

## 工作流放在哪

```text
.github/workflows/ci.yml
```

一个仓库可以有多个 workflow，每个文件一个。GitHub 只认这个目录。

## 最小结构

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: 22
      - run: npm ci
      - run: npm test
```

逐层理解：

| 层级 | 作用 |
| --- | --- |
| `name` | 显示在 Actions 页面 |
| `on` | 什么时候触发 |
| `permissions` | 给 `GITHUB_TOKEN` 多大权限 |
| `jobs.<id>` | 一个任务，默认并行 |
| `runs-on` | 用哪种 runner |
| `steps` | 顺序执行的步骤 |

## 触发条件

```yaml
on:
  push:
    branches: [main]
    paths: ['src/**']
  pull_request:
    types: [opened, synchronize, reopened]
  workflow_dispatch:        # 允许 gh workflow run 手动触发
  schedule:
    - cron: '0 2 * * 1'     # 每周一 02:00 UTC
  release:
    types: [published]
```

| 触发器 | 场景 |
| --- | --- |
| `push` | 推送到指定分支 |
| `pull_request` | PR 打开/更新 |
| `workflow_dispatch` | 手动，可带 inputs |
| `schedule` | 定时，注意是 UTC |
| `release` | 发布 Release |
| `workflow_call` | 被其他 workflow 调用 |

## 步骤

```yaml
steps:
  - name: 检出代码
    uses: actions/checkout@v7

  - name: 安装依赖
    run: npm ci

  - name: 跑测试
    run: npm test
    env:
      NODE_ENV: test
```

- `uses` 引用一个 action（`owner/repo@ref`）
- `run` 执行 shell 命令
- `with` 传给 action 的参数
- `env` 设置环境变量
- `if` 条件执行，例如 `if: github.ref == 'refs/heads/main'`

## 矩阵

一次跑多组参数：

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest]
        node: [20, 22]
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: ${{ matrix.node }}
      - run: npm test
```

共 2 × 2 = 4 个 job。`fail-fast: false` 让一个失败时其他继续跑完，方便一次看到所有问题。

## 缓存

```yaml
- uses: actions/cache@v6
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

`key` 命中就跳过下载，`restore-keys` 做部分匹配兜底。

## 产物

```yaml
- uses: actions/upload-artifact@v7
  with:
    name: coverage
    path: coverage/
    retention-days: 7

- uses: actions/download-artifact@v8
  with:
    name: coverage
```

产物默认在运行结束后保留一段时间（可配置），用 `gh run download` 取。

## 密钥与环境变量

```yaml
env:
  GLOBAL: value

jobs:
  deploy:
    environment: production
    steps:
      - run: ./deploy.sh
        env:
          API_KEY: ${{ secrets.API_KEY }}
```

| 来源 | 用途 |
| --- | --- |
| `secrets.*` | 仓库/组织/环境密钥，日志里自动打码 |
| `env.*` | workflow / job / step 级变量 |
| `github.*` | 上下文：仓库、分支、事件信息 |
| `runner.*` | runner 信息 |

**不要把密钥写进 YAML**，即使是私有仓库。写进 Settings → Secrets and variables → Actions。

## 权限模型

```yaml
permissions:
  contents: read
  issues: write
  pull-requests: write
```

不写时，`GITHUB_TOKEN` 默认权限取决于仓库设置，通常是「读所有、写部分」。**显式声明最小权限**：

```yaml
permissions:
  contents: read
```

需要评论 PR 时再单独加 `pull-requests: write`。

## 本项目的示例工作流

`.github/workflows/ci.yml` 可以检查文档里的相对链接是否存在：

```yaml
name: docs-check

on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: 检查 README 中的相对 Markdown 链接
        run: |
          set -euo pipefail
          grep -oE '\]\([^)#]+\.md\)' README.md \
            | sed 's/](//; s/)$//' \
            | while read -r path; do
                if [ ! -f "$path" ]; then
                  echo "MISSING: $path"
                  exit 1
                fi
              done
```

链到别的章节锚点（`#xxx`）会被正则排除，只查文件是否存在。

## 调试

```bash
gh run list --workflow ci.yml
gh run view <id> --log-failed
gh run rerun <id> --failed
gh workflow run ci.yml -f dry_run=true
```

在 workflow 里临时加 `ACTIONS_STEP_DEBUG`（Settings → Secrets → Actions）可以看到更详细的日志。

## 注意事项

1. **推送 workflow 文件需要 `workflow` scope**，否则会被拒。见 [gh 登录与权限](../00-setup/02-gh-auth.md)。
2. **fork 提交的 PR 拿不到 secrets**，这是安全设计。需要密钥的流程用 `pull_request_target` 时要格外小心，它会以基础仓库权限运行，可能被恶意 PR 利用。
3. **`schedule` 用 UTC**，且仓库 60 天无活动时定时任务会被暂停。
4. **缓存不能跨分支随意共享**，`key` 设计要区分分支或用 `restore-keys` 兜底。
5. **artifact 和 cache 都会占存储**，设置 `retention-days` 和清理策略。
6. **action 版本用 tag（如 `@v7`）**，不要用 `@main`，上游改动会直接影响你的构建。
7. **日志里不要打印 secrets**，即使打码也可能通过变形泄漏（如 base64）。

## 练习

1. 添加一个 `workflow_dispatch` 触发器，用 `gh workflow run` 手动触发。
2. 用矩阵跑两个 Node 版本，观察 Actions 页面上的 job 列表。
3. 加一步 `upload-artifact`，用 `gh run download` 取回文件。
4. 故意让链接检查失败，用 `gh run view --log-failed` 找到具体缺哪个文件。

---

上一篇：[Projects 与 Milestones](02-projects-and-milestones.md) · 下一篇：[Releases 与 Pages](04-releases-and-pages.md)
