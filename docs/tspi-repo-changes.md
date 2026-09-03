# 修改记录

本文档记录了在泰山派 SDK (tspi_repo) 中做的自定义修改。

## 修改概览

| 序号 | 提交哈希 | 模块 | 修改内容 | 提交时间 |
|------|----------|------|----------|----------|
| 1 | 240c5664 | buildroot | squashfs: 修复 GCC 10 -fcommon 编译问题 | 2026-03-31 |
| 2 | 3bc4b0e3 | kernel | dts: 适配 480x800 MIPI DSI 显示屏 | 2026-04-11 |

---

## 1. buildroot: squashfs GCC 10 编译修复

**提交信息**: `buildroot: squashfs: fixup compile gcc10 fcommon`  
**提交哈希**: `240c5664683b79ce8c01dec375126d471aa6aa5c`  
**提交者**: Czzqq <chenlthree@gmail.com>  
**提交时间**: 2026-03-31 22:00:06

### 修改文件
- `package/squashfs/0003-fix-gcc10-fcommon.patch` (新增)

### 修改说明
GCC 10 及以上版本默认使用 `-fno-common` 选项，这会导致 squashfs-tools 编译失败。此修改添加了一个 patch 文件，在 squashfs-tools 的 Makefile 中显式添加 `-fcommon` 编译选项来修复此问题。

### 技术细节
在 squashfs-tools 的 Makefile 中，CFLAGS 变量添加了 `-fcommon` 选项：

```makefile
CFLAGS ?= -O2
CFLAGS += $(EXTRA_CFLAGS) $(INCLUDEDIR) -D_FILE_OFFSET_BITS=64 \
	-fcommon \
	-D_LARGEFILE_SOURCE -D_GNU_SOURCE -DCOMP_DEFAULT=\"$(COMP_DEFAULT)\" \
	-Wall
```

### Patch 文件位置
```
patchs/buildroot/0001-squashfs-fix-gcc10-fcommon.patch
```

---

## 2. kernel: MIPI DSI 显示屏适配

**提交信息**: `dts: adjust dsi with 480x800 3.1 mipi display`  
**提交哈希**: `3bc4b0e346a1e6bced3ed14ebc7822305d044e72`  
**提交者**: Czzqq <chenlthree@gmail.com>  
**提交时间**: 2026-04-11 13:49:11

### 修改文件
- `arch/arm64/boot/dts/rockchip/tspi-rk3566-dsi-v10.dtsi`
- `arch/arm64/boot/dts/rockchip/tspi-rk3566-user-v10-linux.dts`

### 修改说明
将泰山派的 MIPI DSI 显示配置从默认的 8寸 800x1280 屏幕适配为 3.1寸 480x800 MIPI DSI 屏幕。

### 主要修改内容

#### 1. DSI 控制器配置 (tspi-rk3566-dsi-v10.dtsi)

**lane-rate 调整**:
- 从: `rockchip,lane-rate = <480>`
- 改为: `rockchip,lane-rate = <1000>`

**时序参数调整**:
- `reset-delay-ms`: 10ms → 30ms
- `enable-delay-ms`: 120ms → 100ms
- `disable-delay-ms`: 50ms → 20ms
- **新增** `init-delay-ms`: 120ms

**DSI 通道数调整**:
- 从: `dsi,lanes = <4>` (4 lane)
- 改为: `dsi,lanes = <2>` (2 lane)

**显示时序参数**:
```dts
// 修改前 (800x1280)
clock-frequency = <0x3c14b80>;  // 约 63MHz
hactive = <800>;
vactive = <1280>;
hfront-porch = <44>;
hback-porch = <40>;
hsync-len = <8>;
vfront-porch = <12>;
vback-porch = <8>;
vsync-len = <4>;

// 修改后 (480x800)
clock-frequency = <0x1908b100>;  // 约 400MHz
hactive = <480>;
vactive = <800>;
hfront-porch = <100>;
hback-porch = <100>;
hsync-len = <50>;
vfront-porch = <40>;
vback-porch = <40>;
vsync-len = <10>;
```

#### 2. 屏幕初始化序列更新
完全替换了屏幕的初始化命令序列，适配新的显示屏驱动 IC。

#### 3. 用户 DTS 调整 (tspi-rk3566-user-v10-linux.dts)
- 调整了与显示相关的配置引用

### 适配的屏幕规格
- **尺寸**: 3.1 英寸
- **分辨率**: 480 x 800 像素
- **接口**: MIPI DSI
- **通道数**: 2-lane
- **触摸**: 支持 (可能需要额外配置)

### Patch 文件位置
```
patchs/kernel/0001-dsi-adjust-480x800-display.patch
```

---

## 如何应用这些修改

详见 [patchs-usage.md](patchs-usage.md) 文档。

### 快速应用

```bash
# 在 tspi_repo 目录下执行
# 应用 buildroot patch
cd buildroot
git apply ../../patchs/buildroot/0001-squashfs-fix-gcc10-fcommon.patch

# 应用 kernel patch
cd ../kernel
git apply ../../patchs/kernel/0001-dsi-adjust-480x800-display.patch
```

---

## 注意事项

1. **屏幕适配**: 使用 480x800 MIPI 屏幕时，需要确保硬件连接正确（2-lane 模式）
2. **GCC 版本**: 如果使用 GCC 10+ 编译，必须应用 squashfs patch，否则编译会失败
3. **备份建议**: 在应用 patch 前，建议先备份原始的 tspi_repo 目录
4. **Repo 同步**: 如果 tspi_repo 通过 repo 同步更新，patch 可能会被覆盖，需要重新应用

---

## 作者信息

- **作者**: Czzqq
- **邮箱**: chenlthree@gmail.com
- **创建时间**: 2026-04-11
