#######################
#        ▘  ▌ ▜       #
#  ▌▌▀▌▛▘▌▀▌▛▌▐ █▌▛▘  #
#  ▚▘█▌▌ ▌█▌▙▌▐▖▙▖▄▌  #
#######################

# Figure out which shell user uses
SHELL_N := $(shell basename $$SHELL)
ifeq ($(SHELL_N),zsh)
	SHELL_RC = ~/.zshrc
else ifeq ($(SHELL_N),bash)
	SHELL_RC = ~/.bashrc
else
	SHELL_RC = ~/.profile
endif

INSTALL_DIR = $(HOME)/.funcheck
REPO_ADDR		= https://github.com/mord-tirith/funcheck.git

####################
#      ▜   ▗ ▗     #
#  ▛▌▀▌▐ █▌▜▘▜▘█▌  #
#  ▙▌█▌▐▖▙▖▐▖▐▖▙▖  #
#  ▌               #
####################

################
#      ▜       #
#  ▛▘▌▌▐ █▌▛▘  #
#  ▌ ▙▌▐▖▙▖▄▌  #
################

all: update
	@if [ ! -f .funcheck_temp_flag ]; then \
		$(MAKE) install; \
	else \
		rm -f .funcheck_temp_flag; \
	fi

install:
	mkdir -p $(INSTALL_DIR)
	cp funcheck.sh $(INSTALL_DIR)/funcheck.sh
	cp -r configs $(INSTALL_DIR)/configs
	alias

alias:
	@grep -qxF "alias funcheck='$(INSTALL_DIR)/funcheck.sh'" $(SHELL_RC) || \
	echo "alias funcheck='$(INSTALL_DIR)/funcheck.sh'" >> $(SHELL_RC)

update:
	if [ -d .git ]; then \
		if git remote get-url origin 2>/dev/null | grep -q "mord-tirith/funcheck"; then \
			git pull; \
		else \
			$(MAKE) temp_install; \
		fi; \
	else \
		if [ -z "$$(ls -A .)" ]; then \
			git clone $(REPO_ADDR) .; \
		else \
			$(MAKE) temp_install; \
	fi

temp_install:
	@rm -rf .funcheck_temp
	@git clone $(REPO_ADDR) .funcheck_temp
	$(MAKE) -C .funcheck_temp install
	@rm -rf .funcheck_temp
	@touch .funcheck_temp_flag
