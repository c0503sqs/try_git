# 安全：Dependabot、Code scanning、Secret scanning

## 能学到什么

- 三类安全功能各自防什么
- 用 `dependabot.yml` 自动升级依赖
- 启用 CodeQL 代码扫描
- 开启 secret scanning 与 push protection
- 用 `gh api` 查看告警

## 三件事，三种防线

| 功能 | 防什么 | 触发方式 |
| --- | --- | --- |
| Dependabot | 依赖的已知漏洞、过期版本 | 依赖图 + 安全公告 |
| Code scanning（CodeQL） | 自己代码里的漏洞模式 | 静态分析 |
| Secret scanning | 误提交的 token、密钥 | 模式匹配 + 推送拦截 |

三者互补，不是二选一。

## Dependabot

### Alerts（告警）

仓库 → Security → Dependabot alerts。GitHub 根据依赖图和 GitHub Advisory Database 匹配已知漏洞。

查看：

```bash
gh api repos/{owner}/{repo}/dependabot/alerts \
  --jq '.[] | "\(.security_advisory.severity) \(.dependency.package.name) \(.state)"'
```

### Security updates（安全更新）

开启后，Dependabot 自动开 PR 把有漏洞的依赖升到安全版本。在 Security → Dependabot 里一键启用。

### Version updates（版本更新）

按 `.github/dependabot.yml` 定期检查新版本：

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    groups:
      dev-dependencies:
        dependency-type: "development"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

| 字段 | 作用 |
| --- | --- |
| `package-ecosystem` | `npm`、`pip`、`gomod`、`github-actions` 等 |
| `directory` | 依赖文件所在目录 |
| `schedule.interval` | `daily`、`weekly`、`monthly` |
| `open-pull-requests-limit` | 同时打开的 PR 上限 |
| `groups` | 把多个依赖合并到一个 PR |
| `ignore` | 排除某些依赖或版本 |

`groups` 很重要：不分组时，一次升级可能开几十个 PR。

## Code scanning

### 默认配置

仓库 → Security → Code scanning → Set up CodeQL → Default。GitHub 自动生成并运行 CodeQL 分析，不需要写 workflow。

适合大多数项目，尤其是不想维护 workflow 的团队。

### 高级配置

需要自定义查询、语言或构建步骤时，用 advanced：

```yaml
name: codeql

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 3 * * 1'

permissions:
  security-events: write
  contents: read
  actions: read

jobs:
  analyze:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        language: [javascript-typescript]
    steps:
      - uses: actions/checkout@v7
      - uses: github/codeql-action/init@v4
        with:
          languages: ${{ matrix.language }}
      - uses: github/codeql-action/autobuild@v4
      - uses: github/codeql-action/analyze@v4
```

需要编译的语言把 `autobuild` 换成实际的构建命令，再在 `analyze` 前执行。

查看告警：

```bash
gh api repos/{owner}/{repo}/code-scanning/alerts \
  --jq '.[] | "\(.rule.severity) \(.rule.id) \(.state)"'
```

## Secret scanning

GitHub 会扫描仓库历史里符合已知格式的密钥：AWS key、GitHub token、私钥、Stripe key 等。

### Push protection

开启后，包含密钥的推送会被**直接拒绝**，在提交进入仓库前拦截：

```text
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote: ——
remote: —— Secret detected: GitHub Personal Access Token
remote: ——
remote: Push cannot contain secrets
```

处理：

1. 从提交里移除密钥
2. **作废并轮换密钥**（它已经可能泄漏）
3. 用 `git filter-repo` 或 BFG 清理历史（如果已经推送）
4. 重新推送

### 绕过

有权限的人可以在提示里选择「bypass」，但会记录审计日志。**能绕过不代表应该绕过。**

查看告警：

```bash
gh api repos/{owner}/{repo}/secret-scanning/alerts \
  --jq '.[] | "\(.secret_type) \(.state)"'
```

## SECURITY.md

告诉别人怎么报告漏洞，放在仓库根或 `.github/`：

```markdown
# 安全策略

## 报告漏洞

请不要公开提交 issue。发送邮件到 security@example.com，
或用 GitHub 的 Private vulnerability reporting。

我们会在 3 个工作日内回复。

## 支持版本

| 版本 | 支持 |
| --- | --- |
| 2.x | ✅ |
| 1.x | ❌ |
```

仓库 → Security → Advisories 可以开启 **Private vulnerability reporting**，让报告者私下提交。

## 依赖图与 SBOM

仓库 → Insights → Dependency graph 展示所有依赖。可以导出 SBOM（Software Bill of Materials），格式为 SPDX 或 CycloneDX，适合合规场景。

## 权限与可用性

| 功能 | 公开仓库 | 私有仓库 |
| --- | --- | --- |
| Dependabot alerts | 免费 | 免费 |
| Code scanning | 免费 | 取决于套餐 |
| Secret scanning | 免费 | 取决于套餐（GitHub Advanced Security） |
| Push protection | 免费（公开仓库） | 需 GHAS |

## 注意事项

1. **发现密钥后第一件事是轮换**，不是删提交。密钥一旦推送就可能被抓取。
2. **清理历史用 `git filter-repo`**，`git rebase` 删不干净。操作前备份，并通知所有协作者重新 clone。
3. **Dependabot PR 也要 review**。自动升级可能引入破坏性变更，CI 通过不等于业务正确。
4. **`groups` 不配会 PR 爆炸**，尤其是前端项目。
5. **CodeQL 需要编译的语言要配好构建命令**，否则分析的是不完整代码。
6. **Push protection 只在开启后生效**，历史提交不会被追溯拦截，只会产生告警。
7. **不要把 `.env` 提交进仓库**，即使后面删了，历史里还在。用 `.gitignore` 和示例文件。

## 练习

1. 在一个测试仓库开启 Dependabot alerts 和 security updates，看一次自动 PR。
2. 添加 `dependabot.yml`，把 npm 和 github-actions 的检查都设成每周。
3. 开启 Code scanning 的默认配置，查看一次分析结果。
4. 开启 push protection，尝试推送一个假的 token，观察被拒绝的提示。

---

上一篇：[Releases 与 Pages](04-releases-and-pages.md) · 下一篇：[模板与 CODEOWNERS](06-templates-and-codeowners.md)
