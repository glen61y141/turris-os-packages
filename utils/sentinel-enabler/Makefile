include $(TOPDIR)/rules.mk

PKG_NAME:=contract-enforcer
PKG_VERSION:=1
PKG_MAINTAINER:=CZ.NIC <packaging@turris.cz>

include $(INCLUDE_DIR)/package.mk

define Package/contract-enforcer
	TITLE:=Package to ensure compliance with contract
	DEPENDS:=+sentinel-proxy
endef

define Package/contract-enforcer/description
 Make sure that all Sentinel related packages are enabled and up to date.
 Not intended for generic use. Only inteded for specific contract binded routers.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/contract-enforcer/install
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/contract_enforcer
endef

define Package/contract-enforcer/postinst
#!/bin/sh
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/contract_enforcer enable
	/etc/init.d/contract_enforcer restart
}
endef

$(eval $(call BuildPackage,contract-enforcer))
