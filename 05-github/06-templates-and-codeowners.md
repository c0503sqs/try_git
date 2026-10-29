# 模板与 CODEOWNERS

## 能学到什么

- 用 Issue 模板规范提问
- 用 PR 模板统一描述结构
- 用 CODEOWNERS 自动指定评审人
- 知道这些文件的生效位置和优先级

## Issue 模板

### 两种格式

| 格式 | 文件 | 特点 |
| --- | --- | --- |
| Markdown 模板 | `bug_report.md` | 简单，正文预填 |
| Issue Forms | `bug_report.yml` | 表单，字段校验，必填项 |

新项目建议用 YAML 表单，能强制填写复现步骤和版本信息。

### 目录结构

```text
.github/
└── ISSUE_TEMPLATE/
    ├── bug_report.yml
    ├── feature_request.yml
    └── config.yml
```

### Issue Form 示例

```yaml
name: Bug 报告
description: 报告一个可复现的问题
title: "[Bug] "
labels: ["bug"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        感谢反馈。请先搜索是否已有相同 issue。

  - type: textarea
    id: steps
    attributes:
      label: 复现步骤
      placeholder: |
        1. 打开...
        2. 点击...
    validations:
      required: true

  - type: input
    id: version
    attributes:
      label: 版本
      placeholder: v1.2.0
    validations:
      required: true

  - type: dropdown
    id: os
    attributes:
      label: 操作系统
      options:
        - macOS
        - Windows
        - Linux
    validations:
      required: true

  - type: checkboxes
    id: checks
    attributes:
      label: 确认
      options:
        - label: 我已搜索过现有 issue
          required: true
```

字段类型：

| type | 用途 |
| --- | --- |
| `markdown` | 展示说明，不收集输入 |
| `input` | 单行文本 |
| `textarea` | 多行文本 |
| `dropdown` | 单选/多选下拉 |
| `checkboxes` | 勾选项 |

### config.yml

```yaml
blank_issues_enabled: false
contact_links:
  - name: 使用问题
    url: https://github.com/owner/repo/discussions
    about: 请到 Discussions 提问
```

`blank_issues_enabled: false` 强制用户选模板，避免空 issue。

## PR 模板

```text
.github/PULL_REQUEST_TEMPLATE.md
```

内容示例：

```markdown
## 做了什么

-

## 为什么

Closes #

## 怎么验证

1.

## 检查清单

- [ ] 补充/更新测试
- [ ] 更新文档
- [ ] 本地跑过 lint
```

也可以放多个模板在 `.github/PULL_REQUEST_TEMPLATE/` 下，创建 PR 时通过 URL 参数选择：

```text
?template=hotfix.md
```

PR 描述的具体写作规范见 `try_markdown` 的「提交信息与 PR 描述」一课。

## CODEOWNERS

CODEOWNERS 指定「哪些路径由谁负责」。配合分支保护或 Ruleset，可以要求对应负责人批准才能合并。

### 文件位置

按优先级：

```text
.github/CODEOWNERS     ← 推荐
CODEOWNERS
docs/CODEOWNERS
```

只需要一个，多个时 `.github/` 里的优先。

### 语法

```text
# 默认负责人
*                       @c0503sqs

# 目录
/docs/                  @c0503sqs @org/docs-team
/src/api/               @org/backend

# 按扩展名
*.go                    @org/gophers
*.md                    @org/docs-team

# 具体文件
/.github/workflows/     @org/ci-owners
```

规则要点：

1. **最后匹配的规则生效**，不是最具体的。所以把宽泛规则放前面，具体规则放后面。
2. `@username` 是个人，`@org/team` 是团队。
3. 路径以 `/` 开头表示仓库根；不含 `/` 的模式匹配任意层级。
4. `*` 匹配任意字符，`**` 匹配多级目录。

### 让 CODEOWNERS 真正生效

CODEOWNERS 只负责「自动请求 review」，**不强制**。要强制，需要在分支保护或 Ruleset 里开启：

```text
Require a pull request before merging
  ✓ Require review from Code Owners
```

否则负责人可以不理，PR 照样能合。

### 验证

提交 CODEOWNERS 后，打开一个 PR，右侧 Reviewers 应该自动出现对应的人/团队。没出现时检查：

```bash
# 文件位置对不对
git ls-files | grep -i codeowners

# 团队成员有没有仓库写权限（只读成员不会被自动请求）
gh api repos/{owner}/{repo}/collaborators --jq '.[].login'
```

## 本项目的模板

本项目在 `.github/` 下提供了：

```text
.github/
├── PULL_REQUEST_TEMPLATE.md
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml
│   ├── feature_request.yml
│   └── config.yml
└── CODEOWNERS
```

可以照着改成自己项目的字段。

## 注意事项

1. **模板只在网页创建时生效**。`gh issue create --template` 也可以，但 `gh pr create` 不会自动套用 PR 模板。
2. **YAML 表单对缩进敏感**，`body` 下每一项的 `type` 和 `attributes` 层级要正确。
3. **`labels` 里的标签必须已存在**，否则创建 issue 时会被忽略或报错。
4. **CODEOWNERS 的用户必须有权访问仓库**，外部贡献者写了也没用。
5. **CODEOWNERS 不开启强制评审就没有约束力**。
6. **最后匹配优先**，把 `*` 放最前面，特例放后面。
7. **模板文件改动要提交到默认分支才生效**，PR 里改模板看不到效果。

## 练习

1. 在本仓库 `.github/ISSUE_TEMPLATE/` 下新建一个表单，用网页创建 issue 验证字段。
2. 修改 `.github/PULL_REQUEST_TEMPLATE.md`，开一个 PR 看描述是否自动填充。
3. 写一个 CODEOWNERS，把 `/docs/` 指给自己，开 PR 确认自动请求 review。
4. 在分支保护里开启「Require review from Code Owners」，验证没有批准时无法合并。

---

上一篇：[安全：Dependabot、Code scanning、Secret scanning](05-security.md) · 下一篇：[Rulesets 与权限](07-rulesets-and-permissions.md)
