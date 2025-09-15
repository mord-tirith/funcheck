#######################
#        ▘  ▌ ▜       #
#  ▌▌▀▌▛▘▌▀▌▛▌▐ █▌▛▘  #
#  ▚▘█▌▌ ▌█▌▙▌▐▖▙▖▄▌  #
#######################

INSTALL_DIR	:= $(HOME)/.funcheck
TEMP_DIR		:= /tmp/funcheck_update
REPO_URL		:= https://github.com/mord-tirith/funcheck.git
ALIAS_LINE	:= alias funcheck='$(INSTALL_DIR)/funcheck.sh'

SHELL_RC := $(shell \
	if [ -n "$$ZSH_VERSION" ] || [ "$$(basename "$$SHELL" 2>/dev/null)" = "zsh" ]; then \
		echo "$(HOME)/.zshrc"; \
	elif [ -n "$$BASH_VERSION" ] || [ "$$(basename "$$SHELL" 2>/dev/null)" = "bash" ]; then \
		echo "$(HOME)/.bashrc"; \
	elif [ -f "$(HOME)/.zshrc" ]; then \
		echo "$(HOME)/.zshrc"; \
	elif [ -f "$(HOME)/.bashrc" ]; then \
		echo "$(HOME)/.bashrc"; \
	else \
		echo "$(HOME)/.profile"; \
	fi)

MAKEFLAGS		+= --no-print-directory

####################
#      ▜   ▗ ▗     #
#  ▛▌▀▌▐ █▌▜▘▜▘█▌  #
#  ▙▌█▌▐▖▙▖▐▖▐▖▙▖  #
#  ▌               #
####################

RED			:= $(shell tput setaf 1)
GREEN		:= $(shell tput setaf 2)
YELLOW	:= $(shell tput setaf 3)
BLUE		:= $(shell tput setaf 4)
MAGENTA	:= $(shell tput setaf 5)
CYAN		:= $(shell tput setaf 6)
RESET		:= $(shell tput sgr0)

################
#      ▜       #
#  ▛▘▌▌▐ █▌▛▘  #
#  ▌ ▙▌▐▖▙▖▄▌  #
################

.PHONY: all install check-updates fresh-install update-check update-files setup-alias force-update clean update

all: install

install: check-updates setup-alias
	@echo "${GREEN}funcheck installation complete!${RESET}"
	@echo "${GREEN}Run ${YELLOW}'source $(SHELL_RC)' ${GREEN}or restart terminal to use funcheck${RESET}"

check-updates:
	@echo "${YELLOW}Checking for updates...${RESET}"
	@if [ ! -d "$(INSTALL_DIR)" ]; then \
		$(MAKE) fresh-install; \
	else \
		$(MAKE) update-check; \
	fi

fresh-install:
	@echo "${YELLOW}Creating installation directory${RESET}"
	@mkdir -p $(INSTALL_DIR)
	@echo "${YELLOW}Cloning funcheck repo${RESET}"
	@git clone $(REPO_URL) $(TEMP_DIR)
	@echo "${YELLOW}Copying files to $(INSTALL_DIR)${RESET}"
	@cp -r $(TEMP_DIR)/* $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/funcheck.sh
	@rm -rf $(TEMP_DIR)
	@echo "${GREEN}funcheck has been installed at $(INSTALL_DIR)${RESET}"

update-check: 
	@git clone $(REPO_URL) $(TEMP_DIR) 2>/dev/null || true
	@if [ -d "$(TEMP_DIR)" ]; then \
		cd $(INSTALL_DIR) && git init -q 2>/dev/null || true; \
		cd $(INSTALL_DIR) && git remote add origin $(REPO_URL) 2>/dev/null || true; \
		cd $(INSTALL_DIR) && git fetch origin main -q 2>/dev/null || true; \
		if [ -d "$(INSTALL_DIR)/.git" ]; then \
			LOCAL_HASH=$$(cd $(INSTALL_DIR) && git rev-parse HEAD 2>/dev/null || echo "none"); \
			REMOTE_HASH=$$(cd $(TEMP_DIR) && git rev-parse HEAD 2>/dev/null || echo "none"); \
			if [ "$$LOCAL_HASH" != "$$REMOTE_HASH" ]; then \
				echo "${YELLOW}Updates detected, updating files now${RESET}"; \
				$(MAKE) update-files; \
			else \
				echo "${YELLOW}Already up to date${RESET}"; \
			fi; \
		else \
			echo "${RED}Update system not in place, setting it up now${RESET}"; \
			$(MAKE) -C $(CURDIR) update-files; \
		fi; \
		rm -rf $(TEMP_DIR); \
	else \
		echo "${RED}Update process failed to check${RESET}"; \
	fi

update-files:
	@echo "${YELLOW}Downloading most recent version${RESET}"
	@git clone $(REPO_URL) $(TEMP_DIR)
	@echo "${YELLOW}Updating files in $(INSTALL_DIR)${RESET}"
	@cp -r $(TEMP_DIR)/* $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/funcheck.sh
	@cd $(INSTALL_DIR) && git init -q 2>/dev/null || true
	@cd $(INSTALL_DIR) && git remote remove origin 2>/dev/null || true
	@cd $(INSTALL_DIR) && git remote add origin $(REPO_URL) 2>/dev/null || true
	@cd $(INSTALL_DIR) && git add . && git commit -m "Newest version updated" -q 2>/dev/null || true
	@rm -rf $(TEMP_DIR)
	@echo "${GREEN}funcheck updated${RESET}"

setup-alias:
	@echo "${CYAN}Detected shell config: $(SHELL_RC)${RESET}"
	@if ! grep -q "alias funcheck=" $(SHELL_RC) 2>/dev/null; then \
		echo "" >> $(SHELL_RC); \
		echo "# 42 projects function checker (funcheck) alias" >> $(SHELL_RC); \
		echo "$(ALIAS_LINE)" >> $(SHELL_RC); \
		echo "${GREEN}Alias funcheck installed to $(SHELL_RC)${RESET}"; \
	else \
		echo "${YELLOW}Alias funcheck already installed${RESET}"; \
	fi

force-update:
	@echo "${YELLOW}Updating regardless of current install${RESET}"
	@$(MAKE) update-files
	@echo "${GREEN}Forced update finished${RESET}"

clean:
	@echo "${YELLOW}Uninstalling funcheck${RESET}"
	@rm -rf $(INSTALL_DIR)
	@sed -i.bak '/# 42 projects function checker/d; /alias funcheck=/d' $(SHELL_RC) 2>/dev/null || true
	@echo "${YELLOW}funcheck uninstalled${RESET}"

update: check-updates
