# Rulesets 与权限

## 能学到什么

- 用 Rulesets 保护分支和 tag
- 分清仓库角色和组织角色
- 知道「谁能合并」「谁能绕过规则」
- 用最小权限原则配置协作

## Branch protection 与 Rulesets

| | Branch protection（经典） | Rulesets（新） |
| --- | --- | --- |
| 配置入口 | Settings → Branches | Settings → Rules → Rulesets |
| 作用对象 | 分支 | 分支、tag、push |
| 多规则叠加 | 不便 | 支持，按优先级 |
| 绕过列表 | 有限 | 可配置 |
| 组织级 | 支持 | 支持，可下发到多个仓库 |

新项目用 Rulesets。经典保护仍然可用，已有仓库不必急着迁移。

## 常用规则

```text
目标：refs/heads/main
  ✓ Restrict deletions            禁止删除分支
  ✓ Block force pushes            禁止强推
  ✓ Require a pull request        必须走 PR
      Required approvals: 1
      Dismiss stale approvals    新提交后旧批准失效
      Require review from Code Owners
      Require conversation resolution
  ✓ Require status checks         必须通过 CI
      build
      test
  ✓ Require signed commits        必须签名
  ✓ Require linear history        禁止合并提交（只允许 squash/rebase）
```

### 状态检查

`Require status checks` 里填的是 **job 名称**，不是 workflow 名称。名称必须和 YAML 里的 `jobs.<id>` 或 `name:` 一致。

如果填错，PR 会一直显示「Expected — Waiting for status to be reported」。

### 绕过列表（Bypass list）

可以指定某些角色、团队或应用绕过规则：

| 选项 | 含义 |
| --- | --- |
| Organization admin | 组织管理员 |
| Repository admin | 仓库管理员 |
| Maintain | 维护者 |
| 特定团队/应用 | 精确授权 |

**绕过会记录在审计日志里**。生产仓库的绕过列表应该尽量短。

## Tag 规则

Rulesets 也可以保护 tag：

```text
目标：refs/tags/v*
  ✓ Restrict creations     只有指定人/应用能创建
  ✓ Restrict updates       禁止移动已发布的 tag
  ✓ Restrict deletions     禁止删除
```

配合发布流程，可以防止误删或覆盖版本 tag。

## 仓库角色

| 角色 | 读代码 | 提 issue | 推代码 | 改设置 | 删仓库 |
| --- | --- | --- | --- | --- | --- |
| Read | ✅ | ✅ | ❌ | ❌ | ❌ |
| Triage | ✅ | ✅ | ❌ | 部分（管理 issue/PR） | ❌ |
| Write | ✅ | ✅ | ✅ | ❌ | ❌ |
| Maintain | ✅ | ✅ | ✅ | 部分 | ❌ |
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ |

- **Triage** 适合社区管理者：能分类、指派、关闭 issue，但不能改代码。
- **Write** 是普通开发者。
- **Maintain** 用于管理仓库但不需要动敏感设置。
- **Admin** 能改一切，尽量少给。

## 组织与团队

组织里的权限通常通过团队授予：

```text
org
├── team: backend      → 仓库 A: Write
├── team: frontend     → 仓库 A: Write
└── team: release      → 仓库 A: Maintain
```

团队的权限会叠加到成员身上。成员的个人权限和团队权限取**并集**。

## GITHUB_TOKEN 的权限

Actions 里的 `GITHUB_TOKEN` 是另一套权限，由 workflow 的 `permissions` 控制：

```yaml
permissions:
  contents: read
  issues: write
  pull-requests: write
  security-events: write
```

| 权限 | 常见用途 |
| --- | --- |
| `contents` | 读写代码、发 Release |
| `issues` | 评论/关闭 issue |
| `pull-requests` | 评论/合并 PR |
| `actions` | 管理 workflow |
| `security-events` | 上传 CodeQL 结果 |
| `id-token` | OIDC 身份，部署云资源 |

默认权限取决于仓库设置。**显式写最小集合**，尤其是 `contents: write` 不要随手给。

## 一个务实的配置

个人项目：

```text
main:
  ✓ Require a pull request（0 approvals，自己也能走流程）
  ✓ Require status checks（build、test）
  ✓ Block force pushes
```

团队项目：

```text
main:
  ✓ Require a pull request
      Required approvals: 1
      Require review from Code Owners
      Dismiss stale approvals
  ✓ Require status checks（build、test、lint）
  ✓ Require conversation resolution
  ✓ Block force pushes
  ✓ Restrict deletions
```

开源项目还要考虑外部贡献者：外部 fork 的 PR 不能拿 secrets，CI 要用 `pull_request` 而不是 `pull_request_target`。

## 查看当前规则

```bash
gh api repos/{owner}/{repo}/rulesets
gh api repos/{owner}/{repo}/rulesets/<id>
gh api repos/{owner}/{repo}/branches/main/protection
```

## 注意事项

1. **Required status checks 的名称要和 job 一致**，改名后规则会失效。
2. **「Require linear history」和 merge commit 互斥**，开启后只能 squash 或 rebase。
3. **CODEOWNERS 的强制评审要单独开启**，文件本身不强制。
4. **管理员默认可能在绕过列表里**，看起来「规则没生效」多半是这个原因。
5. **Rulesets 可以叠加**，组织级和仓库级同时存在时取并集，排查要看全部。
6. **权限取并集**，团队成员的身份可能比你以为的多。
7. **最小权限**：能用 Read 就不给 Write，能用机器人账号就不给个人 token。

## 练习

1. 在测试仓库创建一条 main 的 Ruleset，要求 PR + 1 个批准 + CI 通过。
2. 尝试直接 push 到 main，确认被拒绝。
3. 把 Required status checks 改成一个不存在的名字，观察 PR 卡在 waiting。
4. 用 `gh api repos/{owner}/{repo}/rulesets` 查看规则 JSON。

---

上一篇：[模板与 CODEOWNERS](06-templates-and-codeowners.md) · 下一篇：[Codespaces、Webhooks、Insights](08-codespaces-webhooks-insights.md)
