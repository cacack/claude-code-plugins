.PHONY: install install-scripts constitution-check

INSTALL_DIR := $(HOME)/.local/bin

install: install-scripts

install-scripts: $(INSTALL_DIR)
	ln -sf $(CURDIR)/scripts/ccstatusline-usage.sh $(INSTALL_DIR)/ccstatusline-usage.sh

$(INSTALL_DIR):
	mkdir -p $(INSTALL_DIR)

# Verify the Success Criteria in CONSTITUTION.md. Exits non-zero on a breach.
constitution-check:
	@scripts/constitution-check.sh
