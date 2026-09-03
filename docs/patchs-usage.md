# Patch 管理使用指南

本文档介绍如何使用本仓库的 patch 系统来管理对泰山派 SDK (tspi_repo) 的自定义修改。

## 目录结构

```
tspi/                              # 你的 Git 仓库
├── patchs/                        # Patch 文件目录
│   ├── buildroot/                 # Buildroot 相关 patch
│   │   └── 0001-squashfs-fix-gcc10-fcommon.patch
│   └── kernel/                    # Kernel 相关 patch
│       └── 0001-dsi-adjust-480x800-display.patch
├── docs/                          # 文档目录
│   ├── czzqq-changes.md          # 修改记录
│   └── patchs-usage.md           # 本文件
└── tspi_repo/                     # SDK 源码 (repo 管理，.gitignore 排除)
    ├── buildroot/                 # Buildroot 目录
    └── kernel/                    # Kernel 目录
```

## 快速开始

### 1. 首次应用所有 Patch

```bash
# 进入你的 Git 仓库根目录
cd /home/zane/Workspace/sdk/tspi

# 方法一：使用脚本一键应用（推荐）
./scripts/apply-patches.sh

# 方法二：手动逐个应用
# 应用 buildroot patch
cd tspi_repo/buildroot
git apply ../../patchs/buildroot/0001-squashfs-fix-gcc10-fcommon.patch

# 应用 kernel patch
cd ../kernel
git apply ../../patchs/kernel/0001-dsi-adjust-480x800-display.patch
```

### 2. 验证 Patch 是否应用成功

```bash
# 在 buildroot 目录
cd tspi_repo/buildroot
git log --oneline -3
# 应该能看到 Czzqq 的提交

# 在 kernel 目录
cd ../kernel
git log --oneline -3
# 应该能看到 Czzqq 的提交
```

---

## 详细使用说明

### 查看可用的 Patch

```bash
# 列出所有 patch 文件
find patchs -name "*.patch" -type f

# 查看某个 patch 的内容
cat patchs/kernel/0001-dsi-adjust-480x800-display.patch
```

### 应用单个 Patch

```bash
# 进入目标目录
cd tspi_repo/buildroot

# 应用 patch（使用相对路径）
git apply ../../patchs/buildroot/0001-squashfs-fix-gcc10-fcommon.patch

# 或者使用绝对路径
git apply /home/zane/Workspace/sdk/tspi/patchs/buildroot/0001-squashfs-fix-gcc10-fcommon.patch
```

### 检查 Patch 是否可以应用

```bash
# 使用 --check 参数先检查，不实际应用
git apply --check ../../patchs/buildroot/0001-squashfs-fix-gcc10-fcommon.patch

# 如果没有输出，说明可以正常应用
```

### 应用 Patch 时忽略空白字符差异

```bash
# 如果 patch 因为空白字符问题无法应用，可以使用 -v 或 --whitespace 选项
git apply --ignore-whitespace ../../patchs/kernel/0001-dsi-adjust-480x800-display.patch
```

### 撤销已应用的 Patch

```bash
# 方法：使用 git checkout 恢复原始文件
cd tspi_repo/buildroot
git checkout -- .

# 或者使用 git reset 回退提交（如果已提交）
git reset --hard HEAD~1
```

---

## 创建新的 Patch

当你在 tspi_repo 中做了新的修改，想要保存为 patch 时：

### 方法一：从最新提交生成（推荐）

```bash
# 进入修改的目录
cd tspi_repo/kernel

# 先提交你的修改
git add .
git commit -m "你的修改描述"

# 生成 patch 文件
git format-patch -1 --stdout > ../../patchs/kernel/0002-your-change.patch
```

### 方法二：从工作区生成

```bash
# 生成包含所有未提交修改的 patch
cd tspi_repo/buildroot
git diff > ../../patchs/buildroot/0002-uncommitted-changes.patch
```

### 方法三：从指定范围生成

```bash
# 生成最近 3 个提交的 patch
cd tspi_repo/kernel
git format-patch -3 --stdout > ../../patchs/kernel/000x-multiple-changes.patch

# 或者生成两个提交之间的所有 patch
git format-patch abc1234..def5678 -o ../../patchs/kernel/
```

---

## Patch 命名规范

为了保持 patch 的可管理性，建议遵循以下命名规范：

```
<序号>-<简短描述>.patch
```

例如：
- `0001-squashfs-fix-gcc10-fcommon.patch`
- `0001-dsi-adjust-480x800-display.patch`
- `0002-add-custom-driver.patch`

### 命名规则

1. **序号**: 4 位数字，按顺序递增 (0001, 0002, ...)
2. **简短描述**: 使用小写字母和连字符，描述修改内容
3. **模块分类**: 将 patch 放在对应的子目录中 (buildroot/, kernel/, u-boot/, 等)

---

## 管理 Patch 的脚本

### apply-patches.sh

创建 `scripts/apply-patches.sh` 脚本来自动应用所有 patch：

```bash
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSPI_REPO="${SCRIPT_DIR}/../tspi_repo"
PATCH_DIR="${SCRIPT_DIR}/../patchs"

echo "=== 开始应用 Patch ==="

# 应用 buildroot patch
if [ -d "${PATCH_DIR}/buildroot" ]; then
    echo "应用 buildroot patch..."
    cd "${TSPI_REPO}/buildroot"
    for patch in ${PATCH_DIR}/buildroot/*.patch; do
        if [ -f "$patch" ]; then
            echo "  应用: $(basename $patch)"
            git apply "$patch" || echo "  警告: $(basename $patch) 应用失败或已应用"
        fi
    done
fi

# 应用 kernel patch
if [ -d "${PATCH_DIR}/kernel" ]; then
    echo "应用 kernel patch..."
    cd "${TSPI_REPO}/kernel"
    for patch in ${PATCH_DIR}/kernel/*.patch; do
        if [ -f "$patch" ]; then
            echo "  应用: $(basename $patch)"
            git apply "$patch" || echo "  警告: $(basename $patch) 应用失败或已应用"
        fi
    done
fi

echo "=== Patch 应用完成 ==="
```

使用方法：

```bash
chmod +x scripts/apply-patches.sh
./scripts/apply-patches.sh
```

---

## 最佳实践

### 1. 定期备份

在应用 patch 或更新 SDK 前，备份重要数据：

```bash
# 打包备份 tspi_repo
tar czf tspi_repo_backup_$(date +%Y%m%d).tar.gz tspi_repo/
```

### 2. 保持 Patch 更新

当 SDK 更新后，patch 可能需要更新：

```bash
# 检查 patch 是否还能应用
cd tspi_repo/kernel
git apply --check ../../patchs/kernel/0001-xxx.patch

# 如果失败，可能需要手动解决冲突或重新生成 patch
```

### 3. 文档同步

每次添加新 patch 时，同步更新文档：

- 在 `docs/czzqq-changes.md` 中记录修改内容
- 在本文档中添加使用说明（如需要）

### 4. 使用 Git 管理 Patch

patch 文件本身也是代码，应该提交到你的 Git 仓库：

```bash
git add patchs/
git add docs/
git commit -m "添加新的 patch 和文档"
```

---

## 常见问题

### Q1: Patch 应用失败

**错误信息**: `error: patch failed: xxx`

**解决方案**:
1. 检查是否已经在目标目录应用过此 patch
2. 检查 SDK 版本是否与 patch 生成时的版本一致
3. 手动解决冲突：编辑 patch 文件或手动修改代码

### Q2: 如何查看 patch 的原始提交信息？

```bash
# patch 文件头部包含提交信息
cat patchs/kernel/0001-dsi-adjust-480x800-display.patch | head -20
```

### Q3: Repo 同步后 patch 丢失了怎么办？

```bash
# 重新应用所有 patch
./scripts/apply-patches.sh
```

### Q4: 如何在不同的开发机器上使用？

```bash
# 克隆你的配置仓库
git clone <your-repo-url> tspi
cd tspi

# 解压 SDK
tar xzf tspi_linux_sdk_repo_20240131.tar.gz
mv tspi_linux_sdk_repo_20240131 tspi_repo

# 应用 patch
./scripts/apply-patches.sh
```

---

## 相关文档

- [sdk修改记录](tspi-repo-changes.md) - 查看具体的修改内容
- [泰山派官方文档](https://wiki.lckfb.com/) - 泰山派官方 Wiki

---

## 更新日志

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-04-11 | v1.0 | 初始版本，记录 Czzqq 的修改 |

---

## 作者

- **维护者**: Czzqq
- **邮箱**: chenlthree@gmail.com
