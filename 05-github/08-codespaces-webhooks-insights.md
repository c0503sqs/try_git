# Codespaces、Webhooks、Insights

## 能学到什么

- 用 devcontainer 定义开发环境
- 用 `gh codespace` 管理云端开发机
- 配置 Webhook 接收仓库事件
- 用 Insights 看仓库活跃度和流量

## Codespaces

Codespaces 是托管在云端的开发环境，本质是一台预配置的容器 + VS Code（网页或本地客户端）。

### devcontainer.json

放在 `.devcontainer/devcontainer.json`：

```json
{
  "name": "node-dev",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "postCreateCommand": "npm ci",
  "forwardPorts": [3000],
  "customizations": {
    "vscode": {
      "extensions": ["dbaeumer.vscode-eslint", "esbenp.prettier-vscode"]
    }
  }
}
```

| 字段 | 作用 |
| --- | --- |
| `image` | 基础镜像 |
| `features` | 追加工具（GitHub CLI、Docker 等） |
| `postCreateCommand` | 创建后自动执行 |
| `forwardPorts` | 自动转发端口 |
| `customizations.vscode.extensions` | 预装扩展 |

有了这个文件，任何人打开 Codespace 都得到一致环境，不需要写「安装步骤」文档。

### 常用命令

```bash
gh codespace create --repo owner/repo
gh codespace list
gh codespace code            # 用本地 VS Code 打开
gh codespace ssh             # SSH 进去
gh codespace ports           # 查看端口
gh codespace stop
gh codespace delete
gh codespace rebuild         # 改了 devcontainer 后重建
```

### 生命周期与计费

| 状态 | 计费 |
| --- | --- |
| 运行中 | 按机器规格计费 |
| 停止 | 只收存储费 |
| 删除 | 停止计费 |

默认空闲 30 分钟后自动停止，可在个人设置里调整。**忘记停会一直计费**，养成 `gh codespace stop` 的习惯。

### 密钥

Codespaces 的 secrets 在个人设置里配置，按仓库授权。不要写进 `devcontainer.json`。

## Webhooks

Webhook 让 GitHub 在事件发生时向你指定的 URL 发 HTTP POST。

### 配置

仓库 → Settings → Webhooks → Add webhook：

| 字段 | 说明 |
| --- | --- |
| Payload URL | 接收地址，必须 HTTPS |
| Content type | `application/json` 或 `application/x-www-form-urlencoded` |
| Secret | 用于签名校验 |
| Events | 选择事件，或 `*` 全部 |

### 事件示例

`push` 事件的 payload（节选）：

```json
{
  "ref": "refs/heads/main",
  "before": "bcf6ece...",
  "after": "9190fb4...",
  "repository": {"full_name": "owner/repo"},
  "pushes": 1,
  "commits": [
    {"id": "9190fb4...", "message": "feat: 添加 fig", "author": {"name": "Other Dev"}}
  ]
}
```

常见事件：`push`、`pull_request`、`issues`、`release`、`workflow_run`、`check_run`。

### 签名校验

如果配置了 Secret，请求头会带：

```text
X-Hub-Signature-256: sha256=<hmac>
```

服务端用同样的 Secret 对**原始请求体**计算 HMAC-SHA256，比对一致才处理。不要用解析后的 JSON 重新序列化再算，字段顺序可能变。

### 调试

网页的 Recent Deliveries 可以看到每次请求的请求头、payload、响应，并支持 Redeliver。

```bash
gh api repos/{owner}/{repo}/hooks
gh api repos/{owner}/{repo}/hooks/<id>/deliveries
```

本地开发时可以用 `gh webhook forward`（需要 `webhook` scope）把事件转发到 localhost：

```bash
gh webhook forward --repo owner/repo --events=push --url=http://localhost:3000/webhook
```

### 失败重试

GitHub 会在失败后重试一段时间。持续失败会标记为 unhealthy，并可能自动禁用。

## Insights

仓库 → Insights 下的几个页面：

| 页面 | 看什么 |
| --- | --- |
| Pulse | 最近一周的提交、PR、issue、贡献者 |
| Contributors | 按人统计提交和增删行 |
| Community | README、LICENSE、CONTRIBUTING 等健康度 |
| Traffic | 克隆数、访问量、热门路径、来源 |
| Commits | 按周的提交频率 |
| Code frequency | 增删行的长期趋势 |
| Dependency graph | 依赖和漏洞 |
| Network | 分支和 fork 的关系图 |
| Forks | fork 列表 |

### Traffic

| 指标 | 含义 |
| --- | --- |
| Views | 页面访问量（去重） |
| Unique visitors | 独立访客 |
| Clones | 克隆次数 |
| Unique cloners | 独立克隆者 |
| Referring sites | 来源站点 |
| Popular content | 访问最多的路径 |

**Traffic 只保留 14 天**，需要长期数据要自己定时抓：

```bash
gh api repos/{owner}/{repo}/traffic/views
gh api repos/{owner}/{repo}/traffic/clones
```

### Contributors 的统计口径

只统计**默认分支**上的提交，且按 GitHub 账号去重。没绑定邮箱的提交不会算到某个人头上。

## 注意事项

1. **Codespaces 忘记停会持续计费**，设置里可以调短空闲超时。
2. **devcontainer 改动要 rebuild 才生效**，`gh codespace rebuild` 会清空容器内未提交的东西。
3. **Webhook 必须能从公网访问**，localhost 用 `gh webhook forward` 或内网穿透。
4. **Webhook 要幂等**。网络重试可能重复投递同一事件，处理逻辑要能去重。
5. **签名校验用原始 body**，框架里要拿到 raw bytes。
6. **Traffic 数据只保留 14 天**，重要指标要自己归档。
7. **Insights 的贡献统计不等于工作量**，提交数容易被格式化、批量提交放大。

## 练习

1. 给一个测试仓库加 `.devcontainer/devcontainer.json`，用 `gh codespace create` 启动并 `gh codespace ssh` 进去。
2. 用 `gh codespace list` 确认状态，最后 `gh codespace stop` 并 `delete`。
3. 用 `gh webhook forward` 把一次 push 事件转发到本地服务，观察 payload。
4. 用 `gh api repos/{owner}/{repo}/traffic/views` 查看访问数据（需要写权限）。

---

上一篇：[Rulesets 与权限](07-rulesets-and-permissions.md) · 下一篇：[bisect：二分定位坏提交](../06-advanced/01-bisect.md)
