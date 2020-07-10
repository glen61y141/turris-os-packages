include $(TOPDIR)/rules.mk

PKG_NAME:=sentinel-enabler
PKG_VERSION:=1
PKG_MAINTAINER:=CZ.NIC <packaging@turris.cz>

include $(INCLUDE_DIR)/package.mk

define Package/sentinel-enabler
	TITLE:=Package to ensure compliance with contract
	DEPENDS:=+sentinel-firewall +sentinel-dynfw-client +sentinel-minipot +sentinel-nikola +sentinel-proxy
endef

define Package/sentinel-enabler/description
 Make sure that all Sentinel related packages are enabled. Not intended for generic use.
 Only inteded for specific contract binded routers.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/sentinel-enabler/install
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/sentinel_enabler
endef

define Package/sentinel-enabler/postinst
#!/bin/sh
# Danger: spaces are not ordinary spaces, but special unicode ones
[ -n "$$IPKG_INSTROOT" ] || {
	/etc/init.d/sentinel_enabler enable
	/etc/init.d/sentinel_enabler restart
}
endef

$(eval $(call BuildPackage,sentinel-enabler))
