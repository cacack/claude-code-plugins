.PHONY: install install-ccstatusline constitution-check

XDG_CONFIG_HOME ?= $(HOME)/.config
CCSTATUSLINE_DIR := $(XDG_CONFIG_HOME)/ccstatusline

install: install-ccstatusline

# Symlink the ccstatusline config dir so this repo is its single source of truth.
# A pre-existing real directory is moved aside, never deleted.
install-ccstatusline:
	@mkdir -p $(XDG_CONFIG_HOME)
	@if [ -d $(CCSTATUSLINE_DIR) ] && [ ! -L $(CCSTATUSLINE_DIR) ]; then \
	  mv $(CCSTATUSLINE_DIR) $(CCSTATUSLINE_DIR).bak; \
	  echo "moved existing $(CCSTATUSLINE_DIR) to $(CCSTATUSLINE_DIR).bak"; \
	fi
	ln -sfn $(CURDIR)/config/ccstatusline $(CCSTATUSLINE_DIR)

# Verify the Success Criteria in CONSTITUTION.md. Exits non-zero on a breach.
constitution-check:
	@scripts/constitution-check.sh
