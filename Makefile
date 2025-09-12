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

all: update install

install: alias
	mkdir -p $(INSTALL_DIR)
	cp funcheck.sh $(INSTALL_DIR)/funcheck.sh
	cp -r configs $(INSTALL_DIR)/configs

alias:
	@grep -qxF "alias funcheck='$(INSTALL_DIR)/funcheck.sh'" $(SHELL_RC) || \
	echo "alias funcheck='$(INSTALL_DIR)/funcheck.sh'" >> $(SHELL_RC)

update:
	if [ -d .git ]; then \
		if git remote get-url origin 2>/dev/null | grep -q "mord-tirith/funcheck"; then \
			git pull; \
		else \
			rm -rf .funcheck_temp; \
			git clone $(REPO_ADDR) .funcheck_temp; \
			$$(MAKE) -C .funcheck_temp install; \
			rm -rf .funcheck_temp; \
			exit 0; \
		fi; \
	else \
		git clone $(REPO_ADDR) .; \
	fi
