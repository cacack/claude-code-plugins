.PHONY: install install-scripts

INSTALL_DIR := $(HOME)/.local/bin

install: install-scripts

install-scripts: $(INSTALL_DIR)
	ln -sf $(CURDIR)/scripts/ccstatusline-usage.sh $(INSTALL_DIR)/ccstatusline-usage.sh

$(INSTALL_DIR):
	mkdir -p $(INSTALL_DIR)
