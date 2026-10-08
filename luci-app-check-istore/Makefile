#
# Copyright (C) 2026
#
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-check-istore
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=iStore Check & IPK Installer
LUCI_DESCRIPTION:=Detect luci-app-store(iStore), one‑click install, upload local ipk for OpenWrt‑25.12 apk
LUCI_DEPENDS:=+luci +wget

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
