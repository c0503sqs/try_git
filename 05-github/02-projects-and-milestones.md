# Projects 与 Milestones

## 能学到什么

- 用 Milestone 按版本组织 issue
- 用 Projects 做看板、表格、路线图
- 用 `gh project` 在命令行操作项目
- 知道两者的分工

## 两者解决不同问题

| | Milestone | Projects |
| --- | --- | --- |
| 粒度 | 一个版本/阶段 | 跨仓库的工作流 |
| 视图 | 列表 + 进度条 | 表格、看板、路线图 |
| 自定义字段 | 无 | 有（优先级、估点、状态） |
| 范围 | 单个仓库 | 仓库、组织、用户 |
| 适合 | 「这个版本要发什么」 | 「现在谁在做什么」 |

简单项目只用 Milestone 就够；多仓库、需要看板时上 Projects。

## Milestone

### 创建

网页：仓库 → Issues → Milestones → New milestone。

命令行（`gh` 没有 milestone 子命令，用 API）：

```bash
gh api repos/{owner}/{repo}/milestones \
  -f title="v1.2.0" \
  -f description="1.2 版本" \
  -f due_on="2026-12-31T23:59:59Z"
```

### 关联 issue

```bash
gh issue edit 42 --milestone "v1.2.0"
```

或在 issue 右侧 Milestone 下拉里选。

### 看进度

网页上的 Milestone 页会显示：

```text
v1.2.0
  12 open   8 closed   60% complete
  Due Dec 31, 2026
```

进度 = 已关闭 issue / 全部 issue。**注意它不统计 PR**。

### 关闭里程碑

所有 issue 关闭后手动点 Close。没关完也能关，但进度会停在中间。

## Projects（新版）

Projects 是独立于仓库的容器，可以跨多个仓库收集 issue 和 PR。

### 三种视图

| 视图 | 适合 |
| --- | --- |
| Table | 批量编辑字段、排序、筛选 |
| Board | 看板，按状态列移动卡片 |
| Roadmap | 按日期展示，做计划 |

同一个 Project 可以有多个视图，底层是同一批数据。

### 内置字段

| 字段 | 类型 |
| --- | --- |
| Status | 单选：Todo / In Progress / Done |
| Assignees | 人 |
| Labels | 标签 |
| Milestone | 里程碑 |
| Repository | 仓库 |
| Linked pull requests | PR |
| Sub-issues progress | 子任务进度 |

自定义字段支持文本、数字、日期、单选、迭代。

### 创建

```bash
gh auth refresh -s project      # 第一次使用需要 project scope

gh project create --owner @me --title "Roadmap"
gh project create --owner my-org --title "Q4 计划"
```

### 查看与添加

```bash
gh project list --owner @me
gh project view 1 --owner @me
gh project view 1 --owner @me --web

# 把 issue 或 PR 加进项目
gh project item-add 1 --owner @me --url https://github.com/owner/repo/issues/42

# 创建草稿条目（还没变成 issue 的想法）
gh project item-create 1 --owner @me --title "调研缓存方案"

# 列出条目
gh project item-list 1 --owner @me
```

### 字段

```bash
gh project field-list 1 --owner @me
gh project field-create 1 --owner @me --name "优先级" --data-type SINGLE_SELECT
```

`--data-type` 可选 `TEXT`、`NUMBER`、`DATE`、`SINGLE_SELECT`、`ITERATION`。

### 链接到仓库

```bash
gh project link 1 --owner @me --repo owner/repo
```

链接后，该仓库新建的 issue 可以直接加入这个项目。

## 内置自动化

Projects 自带工作流，可在网页的 ⋯ → Workflows 里开关：

| 工作流 | 效果 |
| --- | --- |
| Item closed | issue/PR 关闭时把 Status 设为 Done |
| Pull request merged | PR 合并时设为 Done |
| Item reopened | 重新打开时设为 Todo |
| Auto-add to project | 新 issue 自动加入 |

这些是平台功能，不需要写 Actions。

## 典型用法

```text
Milestone：v1.2.0 要修的 8 个 issue
Projects：整个团队本季度的 40 个任务
```

- 用 Milestone 回答「这个版本发什么」
- 用 Projects 回答「现在进展如何、谁在做」

两者可以同时用在同一个 issue 上。

## 注意事项

1. **`gh project` 需要 `project` scope**，报 403 时先 `gh auth refresh -s project`。
2. **Projects 的编号是全局的**，不同 owner 下可能重号，命令里要带 `--owner`。
3. **Milestone 进度不统计 PR**，只看 issue 的关闭比例。
4. **删除 Milestone 不会删除 issue**，只是解除关联。
5. **Projects 有自己的权限**，和仓库权限独立；组织项目要确认成员能访问。
6. **视图是保存的过滤器**，改视图不会改数据；数据在字段里。
7. **跨仓库项目要显式添加 item**，不会自动收集所有仓库的 issue，除非配了 Auto-add 工作流。

## 练习

1. 用 `gh api` 创建一个 Milestone，把两个 issue 加进去，观察网页进度条。
2. 用 `gh project create` 建一个项目，把 issue 加进去，用 `gh project item-list` 查看。
3. 在网页上切换 Table / Board 视图，修改一个条目的 Status。
4. 开启「Item closed」工作流，关闭一个 issue，确认状态自动变成 Done。

---

上一篇：[Issues、标签与指派](01-issues-and-labels.md) · 下一篇：[Actions：自动化工作流](03-actions.md)
