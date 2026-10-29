# gh issue

## 能学到什么

- 用命令行创建、查询、评论、关闭 issue
- 用标签、指派人、里程碑组织 issue
- 从 issue 直接拉出开发分支
- 知道哪些字段需要事先在仓库里配置

## 创建 issue

```bash
gh issue create \
  --title "导出 CSV 时中文乱码" \
  --body "## 复现

1. 导出含中文的表格
2. 用 Excel 打开

## 期望

中文正常显示。" \
  --label bug \
  --assignee @me \
  --milestone "v1.2.0"
```

常用参数：

| 参数 | 作用 |
| --- | --- |
| `-t, --title` | 标题 |
| `-b, --body` | 正文，支持 Markdown |
| `-F, --body-file` | 从文件读正文，`-` 表示 stdin |
| `-l, --label` | 标签，可重复 |
| `-a, --assignee` | 指派给谁，`@me` 表示自己 |
| `-m, --milestone` | 里程碑名称 |
| `-p, --project` | 加入 Project（需要 `project` scope） |
| `--template` | 使用 `.github/ISSUE_TEMPLATE` 里的模板 |
| `--web` | 在浏览器里创建 |

不带参数运行 `gh issue create` 会进入交互式提问。

> `--label` 和 `--milestone` 的名称必须已经存在。标签不存在会报错；先用 `gh label create bug` 创建，或在网页上建好。

## 查询

```bash
gh issue list
gh issue list --state open --limit 30
gh issue list --label bug --assignee @me
gh issue list --search "乱码 in:title"
gh issue list --json number,title,labels --jq '.[] | "\(.number) \(.title)"'
```

状态取值：`open`、`closed`、`all`。

查看单条：

```bash
gh issue view 42
gh issue view 42 --comments
gh issue view 42 --web
gh issue view 42 --json title,body,labels,assignees,state
```

## 评论与编辑

```bash
gh issue comment 42 --body "已复现，正在排查。"
gh issue comment 42 --body-file reply.md

gh issue edit 42 --add-label "priority:high"
gh issue edit 42 --remove-label "needs-triage"
gh issue edit 42 --title "新标题"
gh issue edit 42 --add-assignee @me
gh issue edit 42 --milestone "v1.2.0"
```

## 关闭与重开

```bash
gh issue close 42
gh issue close 42 --reason "not planned"
gh issue reopen 42
```

`--reason` 可选 `completed`（默认）或 `not planned`。

## 从 issue 拉分支

```bash
gh issue develop 42 --checkout
gh issue develop 42 --name fix/csv-encoding --base main --checkout
gh issue develop 42 --list      # 看这个 issue 关联了哪些分支
```

它会在远端创建分支（默认基于仓库默认分支），并关联到 issue。后续 PR 合并且描述里写 `Closes #42`，issue 会自动关闭。

## 批量操作

`gh issue list` 的结果可以接 `--json` 和 `--jq`，再交给 shell 循环：

```bash
gh issue list --state open --label needs-triage --json number \
  --jq '.[].number' | while read -r n; do
    gh issue edit "$n" --add-label "triaged"
  done
```

## issue 模板

仓库里放 `.github/ISSUE_TEMPLATE/bug_report.yml` 等文件后，网页创建 issue 时会让你选模板。命令行用：

```bash
gh issue create --template "Bug report"
```

模板的写法见 [模板与 CODEOWNERS](../05-github/06-templates-and-codeowners.md)。

## 注意事项

1. **标签必须先存在**。`gh issue create --label bug` 在仓库没有 `bug` 标签时会失败。
2. **`--assignee @me` 需要自己的账号有仓库访问权限**，外部贡献者可能无法指派。
3. **`gh issue develop` 创建的是远端分支**，需要先有推送权限，且通常需要 `repo` scope。
4. **关闭 issue 的关键字写在 PR 描述里**：`Closes #42`、`Fixes #42`；`Refs #42` 不会自动关闭。
5. **`gh issue list` 默认只列 open**，查历史加 `--state all`。
6. **`--project` 需要 `project` scope**，报 403 时执行 `gh auth refresh -s project`。
7. **issue 的正文同样是 Markdown**，任务列表、代码块、`<details>` 都能用。

## 练习

1. 在一个测试仓库里用 `gh label create bug` 建标签，再用 `gh issue create` 建一条带标签和指派的 issue。
2. 用 `gh issue list --json number,title --jq` 输出编号和标题。
3. 用 `gh issue comment` 评论，再 `gh issue view --comments` 查看。
4. 用 `gh issue develop <编号> --checkout` 创建并切到开发分支，然后在 PR 描述里写 `Closes #<编号>`。

---

上一篇：[gh repo](01-repo.md) · 下一篇：[gh pr](03-pr.md)
