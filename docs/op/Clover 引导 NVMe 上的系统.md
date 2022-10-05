# Clover 引导 NVMe 上的系统

我购置了 R630 服务器，并将 PVE 系统安装在了 NVMe 硬盘上。但是因为 BIOS 太老了，缺少 NVMe 驱动，所以启动系统时读不到 PVE。可以在 U 盘上安装 Clover，R630 先启动 Clover，Clover 再去引导启动 NVMe 上的 PVE。

ref <https://blog.naturalwill.me/2020/06/13/boot-on-nvme-sdd-with-clover/>

先将 [Clover](https://github.com/CloverHackyColor/CloverBootloader/releases) 安装到 U 盘上，再把 U 盘中的 `/EFI/CLOVER/drivers/off/NvmExpressDxe.efi` 复制到 `/EFI/CLOVER/drivers/UEFI/` 下即可。
