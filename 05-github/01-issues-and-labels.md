# Issues、标签与指派

## 能学到什么

- Issue 的组成部分和典型用法
- 用标签、指派人、里程碑组织工作
- 交叉引用与自动关闭
- 用搜索限定符快速找到 issue

## Issue 是什么

Issue 是仓库里的**工作项**：bug 报告、功能请求、任务、讨论。它不只是「报错」，也是团队协作的入口。

一个 issue 由这些部分组成：

| 部分 | 作用 |
| --- | --- |
| 标题 | 一句话说清问题 |
| 正文 | 复现步骤、期望行为、环境信息 |
| 评论 | 讨论、补充信息、进展 |
| 标签 | 分类：类型、优先级、状态 |
| 指派人 | 谁负责 |
| 里程碑 | 归到哪个版本 |
| Projects | 看板/表格里的位置 |
| 关联 PR | 代码修复的链接 |

## 创建

网页：仓库 → Issues → New issue。

命令行：

```bash
gh issue create --title "导出 CSV 中文乱码" --body "复现步骤..." --label bug
```

带模板：

```bash
gh issue create --template "Bug report"
```

## 标签体系

GitHub 默认给几个标签：`bug`、`enhancement`、`documentation`、`good first issue`、`help wanted`、`question` 等。

团队通常按维度扩展：

| 维度 | 例子 |
| --- | --- |
| 类型 | `bug`、`feature`、`docs`、`refactor` |
| 优先级 | `priority:high`、`priority:low` |
| 状态 | `needs-triage`、`blocked`、`in-progress` |
| 范围 | `area:cli`、`area:api` |

用前缀 + 冒号分组，`gh issue list` 和网页筛选都会按字母序聚在一起。

管理标签：

```bash
gh label list
gh label create "priority:high" --color d73a4a --description "需要尽快处理"
gh label edit bug --description "确认的缺陷"
gh label delete "priority:low"
```

> 标签名区分大小写。`--label bug` 找不到 `Bug`。

## 指派与里程碑

```bash
gh issue create --assignee @me
gh issue edit 42 --add-assignee c0503sqs
gh issue edit 42 --milestone "v1.2.0"
```

- **指派**表示「谁负责推进」，不是「谁写的」。
- **里程碑**把 issue 分组到一个版本，网页上会显示完成进度条。

`gh` 没有 `milestone` 子命令，创建里程碑用 API：

```bash
gh api repos/{owner}/{repo}/milestones \
  -f title="v1.2.0" -f due_on="2026-12-31T23:59:59Z"
```

## 交叉引用

在 issue、PR、提交信息、评论里写：

| 写法 | 效果 |
| --- | --- |
| `#42` | 链接到本仓库 issue/PR 42 |
| `owner/repo#42` | 链接到其他仓库 |
| `a1b2c3d` | 链接到提交 |
| `@username` | 提到某人并通知 |

关闭关键字写在 PR 描述或提交信息里：

```text
Closes #42
Fixes #42
Resolves #42
```

合并后自动关闭。`Refs #42` 只建立引用，不关闭。

## 搜索

网页搜索框和 `gh issue list --search` 用同一套限定符：

```text
is:issue is:open label:bug assignee:@me
is:issue state:closed author:c0503sqs
is:issue no:assignee label:needs-triage
is:pr is:merged merged:>=2026-01-01
repo:owner/repo label:"priority:high"
```

常用：

```bash
gh issue list --search "is:open label:bug sort:updated-desc"
gh search issues --owner cli --state open --label bug
```

## 其他操作

| 操作 | 方式 |
| --- | --- |
| 固定 issue | 网页右侧 Pin |
| 锁定讨论 | 网页右侧 Lock conversation |
| 转移 issue | 网页 Transfer issue（目标仓库） |
| 引用到 Project | `gh project item-add` |
| 关闭 | `gh issue close 42 --reason "not planned"` |

## 注意事项

1. **一个 issue 只描述一个问题**。混在一起会让关闭和追踪变难。
2. **标题写现象，不写猜测**。「导出中文乱码」比「编码函数写错了」更准确，后者可能是错误结论。
3. **标签要精简**。几十个标签等于没有标签，按维度控制在 3–5 组。
4. **关闭关键字只写在 PR 描述或提交信息里**。写在评论里不会触发自动关闭。
5. **转移 issue 会改变编号所在仓库**，外部链接可能失效。
6. **`gh issue list` 默认只列 open**，历史问题加 `--state all`。
7. **敏感信息不要贴进 issue**。token、内网地址、用户数据打码后再贴。

## 练习

1. 创建一个标签 `priority:high`，再用 `gh issue create` 建一条带该标签和指派的 issue。
2. 在另一条 issue 里用 `#编号` 交叉引用，确认网页上出现链接。
3. 用 `gh issue list --search "is:open label:priority:high"` 过滤。
4. 写一个 PR 描述，包含 `Closes #<编号>`，合并后确认 issue 自动关闭。

---

上一篇：[alias 与扩展](../04-gh-cli/08-alias-and-extension.md) · 下一篇：[Projects 与 Milestones](02-projects-and-milestones.md)
