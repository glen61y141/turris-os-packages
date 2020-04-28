#
## Copyright (C) 2018-2020 CZ.NIC, z.s.p.o. (https://www.nic.cz/)
#
## This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sentinel-nikola
PKG_VERSION:=3.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.labs.nic.cz/turris/sentinel/nikola.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_MAINTAINER:=CZ.NIC <packaging@turris.cz>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/sentinel-nikola
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Sentinel
  TITLE:=Nikola
  URL:=https://gitlab.labs.nic.cz/turris/sentinel/nikola
  DEPENDS:= \
    +python3-light \
    +python3-setuptools \
    +python3-msgpack \
    +python3-zmq \
    +sentinel-proxy \
    +logrotate \
    +syslog-ng \
    +firewall
  VARIANT:=python3
endef

define Package/sentinel-nikola/description
  Collects firewall logs and sends it to sentinel.
endef

define Package/sentinel-nikola/conffiles
/etc/config/nikola
endef

define Py3Package/sentinel-nikola/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_BIN) ./files/nikola-firewall.sh $(1)/usr/bin/nikola-firewall.sh

	$(INSTALL_DIR) $(1)/etc/cron.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/cron/nikola $(1)/etc/cron.d/nikola
	$(INSTALL_DIR) $(1)/etc/logrotate.d/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/logrotate.d/iptables $(1)/etc/logrotate.d/iptables
	$(INSTALL_DIR) $(1)/etc/syslog-ng.d/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/syslog/syslog-ng.conf $(1)/etc/syslog-ng.d/nikola.conf

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults $(1)/etc/uci-defaults/99-sentinel-nikola
endef

define Package/sentinel-nikola/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/syslog-ng reload
}
endef

define Package/sentinel-nikola/prerm
[ -n "$${IPKG_INSTROOT}" ] || {
	nikola-firewall.sh -r
}
endef

define Package/sentinel-nikola/postrm
#!/bin/sh
syslog_ng_init="/etc/init.d/syslog-ng"
[ -n "$${IPKG_INSTROOT}" ] || {
	if [ -x "$$syslog_ng_init" ]; then
		"$$syslog_ng_init" reload
	fi
}
endef

$(eval $(call Py3Package,sentinel-nikola))
$(eval $(call BuildPackage,sentinel-nikola))
$(eval $(call BuildPackage,sentinel-nikola-src))
