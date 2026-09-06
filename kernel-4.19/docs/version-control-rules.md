# TSPI SDK 版本控制规则

本文档描述泰山派 SDK 开发环境的版本控制策略。

## 概述

本项目采用**双仓库方案**：
- **原始 SDK** (`tspi_repo/`): 由 `repo` 工具管理，不包含在版本控制中
- **自定义 Git 仓库** (当前目录): 管理补丁、脚本、文档和构建产物

## 仓库结构

```
tspi/                          # 自定义 Git 仓库根目录
├── .git/                      # Git 元数据
├── .gitignore                 # 排除 tspi_repo/、*.tar.gz 等
├── patchs/                    # SDK 修改补丁
│   ├── buildroot/
│   └── kernel/
├── scripts/                   # 自动化脚本
│   └── apply-patches.sh
├── docs/                      # 文档
│   ├── tspi-repo-changes.md   # 修改记录
│   └── patchs-usage.md        # 补丁使用指南
├── docker/                    # Docker 配置
├── image/                     # 构建输出镜像
├── tspi_repo/                 # SDK 源码（Git 排除）
│   ├── .repo/                 # Repo 工具元数据
│   ├── buildroot/             # Buildroot 源码
│   ├── kernel/                # Kernel 源码
│   └── ...                    # 其他 SDK 组件
└── README
```

## 版本控制规则

### 1. 忽略的文件/目录

以下文件通过 `.gitignore` 明确排除在版本控制之外：

| 模式 | 原因 |
|------|------|
| `tspi_repo/` | SDK 源码由 repo 工具管理 |
| `*.tar.gz` | SDK 压缩包和下载文件 |
| `br/` | Buildroot 下载缓存 |

**重要提示**: `.gitignore` 中列出的任何文件或目录都不会被 Git 跟踪。

### 2. 需要版本控制的内容

**应当提交的内容：**
- ✅ `patchs/` 目录中的补丁文件
- ✅ `scripts/` 目录中的脚本
- ✅ `docs/` 目录中的文档
- ✅ Docker 配置文件
- ✅ `image/` 中的构建输出（如果体积不大）
- ✅ 配置文件（如 `.gitignore`、构建配置等）

**不应当提交的内容：**
- ❌ `tspi_repo/` 目录的内容
- ❌ SDK 压缩包 (`*.tar.gz`)
- ❌ 构建缓存和临时文件
- ❌ 大型二进制文件（除非必要）

### 3. SDK 修改工作流程

当你需要修改 SDK 源码时：

1. **在 `tspi_repo/` 中修改**（例如 `tspi_repo/kernel/`、`tspi_repo/buildroot/`）

2. **从修改生成补丁**：
   ```bash
   cd tspi_repo/kernel
   git format-patch -1 --stdout > ../../patchs/kernel/0002-your-change.patch
   ```

3. **提交补丁到本仓库**：
   ```bash
   cd /path/to/tspi
   git add patchs/kernel/0002-your-change.patch
   git commit -m "添加 XXX 功能的内核补丁"
   ```

4. **在 `docs/tspi-repo-changes.md` 中记录修改**

### 4. 补丁管理

补丁按目标组件组织：

```
patchs/
├── buildroot/          # Buildroot 相关补丁
│   └── 0001-*.patch
├── kernel/             # Kernel 相关补丁
│   └── 0001-*.patch
├── u-boot/             # U-Boot 补丁（如有）
└── device/             # 设备配置补丁（如有）
```

**补丁命名规范：**
```
XXXX-简短描述.patch
```
- `XXXX`: 顺序编号（0001, 0002, ...）
- `简短描述`: 使用小写字母和连字符的简要描述

### 5. SDK 更新工作流程

当更新 SDK 到新版本时：

1. **备份当前工作状态**：
   ```bash
   git status  # 检查当前状态
   git log --oneline -5  # 查看最近提交
   ```

2. **通过 repo 更新 SDK**：
   ```bash
   cd tspi_repo
   repo sync
   ```

3. **重新应用补丁**：
   ```bash
   cd /path/to/tspi
   ./scripts/apply-patches.sh
   ```

4. **解决冲突**（如有补丁应用失败），然后重新生成补丁

5. **测试构建**，确保一切正常

### 6. Git 提交规范

**提交信息格式：**
```
<类型>: <主题>

<正文>（可选）
```

**类型：**
- `patch`: 新增或更新补丁文件
- `docs`: 文档修改
- `script`: 脚本修改
- `config`: 配置修改
- `feat`: 新功能或能力

**示例：**
```
patch: 添加 MIPI DSI 显示屏支持的内核补丁

scripts: 更新 apply-patches.sh，改进错误处理

docs: 在 patchs-usage.md 中添加故障排除章节
```

### 7. 分支策略

推荐的分支命名：
- `main` 或 `master`: 稳定、可工作的状态
- `develop`: 新更改的集成分支
- `feature/xxx`: 功能特定分支
- `patch/xxx`: 补丁特定分支

示例工作流程：
```bash
# 创建功能分支
git checkout -b feature/add-camera-support

# 进行修改，提交补丁...

# 合并回主分支
git checkout main
git merge feature/add-camera-support
```

### 8. 备份与同步

**推送到个人 Git 服务器：**
```bash
# 首次添加远程仓库
git remote add myserver https://your-git-server.com/username/tspi-custom.git

# 推送更改
git push myserver main
```

**在新机器上克隆：**
```bash
# 克隆本仓库
git clone https://your-git-server.com/username/tspi-custom.git tspi
cd tspi

# 解压 SDK（不包含在 git 中）
tar xzf tspi_linux_sdk_repo_20240131.tar.gz
mv tspi_linux_sdk_repo_20240131 tspi_repo

# 应用所有补丁
./scripts/apply-patches.sh
```

## 最佳实践

1. **保持补丁小而专注**：每个补丁只做一件事
2. **记录所有修改**：每次修改都更新 `docs/tspi-repo-changes.md`
3. **提交前测试**：确保补丁能干净地应用且构建成功
4. **频繁提交**：使用清晰的信息频繁提交补丁
5. **定期备份**：推送到个人 Git 服务器或外部备份
6. **版本跟踪**：更新 SDK 时在提交信息中包含 SDK 版本信息

## 故障排除

### SDK 更新后补丁应用失败

如果 `repo sync` 后 `apply-patches.sh` 报告冲突：

1. 检查哪个补丁失败：
   ```bash
   cd tspi_repo/kernel
   git apply --check ../../patchs/kernel/0001-xxx.patch
   ```

2. 如果补丁已过时，从 `patchs/` 目录中删除

3. 如果补丁需要更新：
   - 重置修改的目录：`git checkout -- .`
   - 重新应用能工作的补丁
   - 手动重做修改
   - 生成新补丁：`git format-patch -1 ...`
   - 用新补丁替换旧补丁

### 意外提交了 tspi_repo

如果 `tspi_repo/` 被意外添加到 git：

```bash
# 从 git 中移除但保留文件
git rm -r --cached tspi_repo
echo "tspi_repo/" >> .gitignore
git add .gitignore
git commit -m "从版本控制中移除 tspi_repo"
```

## 相关文档

- [TSPI Repo 修改记录](tspi-repo-changes.md) - 具体修改的记录
- [补丁使用指南](patchs-usage.md) - 如何使用补丁系统

## 修订历史

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-04-11 | v1.0 | 初始版本控制规则 |

---

**维护者**: Czzqq  
**邮箱**: chenlthree@gmail.com
