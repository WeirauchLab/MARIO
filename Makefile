PKGNAME=MARIO pipeline
MODNAME=$(shell echo $(PKGNAME) | tr 'A-Z ' 'a-z_')
SCRIPTNAME=MARIO
# get the package version from the 'MARIO' Perl script
PKGVER=$(shell sed -n "s/^\(my \$$version  *=  *\)'\(.*\)';/\2/p" $(SCRIPTNAME))
# printed in the 'make help' output
READMEURL=https://tfwebdev.research.cchmc.org/gitlab/puj6ug/MARIO_pipeline\#readme

LABROOT=/data/weirauchlab
# where "local" modules are installed (modules for software *we* wrote)
MODULEROOT=$(LABROOT)/local/modules
# "root" dir where MARIO binaries & other supporting files will be installed
MODULEDIR=$(MODULEROOT)/$(MODNAME)/$(PKGVER)
# install these into $(MODULEDIR)/bin
EXECUTABLES=$(SCRIPTNAME) moods

# where 'modulefile' will be installed to with 'make install-modulefile'
MODULEDESTFILE=$(MODULEROOT)/modulefiles/$(MODNAME)/$(PKGVER)
# the name of the Environment Modules modulefile in the c.w.d.
MODULEFILE=modulefile.tcl
# today's date in MMDDYY format
TODAY=$(shell date +%m%d%y)
# use the Bash shell (always)
SHELL=bash

# ANSI terminal colors (see 'man tput') and
# https://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
#
# Don't use color if there isn't a $TERM environment variable:
ifneq ($(strip $(TERM)),)
	BOLD=$(shell tput bold)
	RED=$(shell tput setaf 1)
	GREEN=$(shell tput setaf 2)
	BLUE=$(shell tput setaf 4)
	MAGENTA=$(shell tput setaf 5)
	UL=$(shell tput sgr 0 1)
	RESET=$(shell tput sgr0 )
endif

help:
	@echo
	@echo "  $(UL)$(BOLD)$(BLUE)Makefile tasks for $(PKGNAME) v$(PKGVER)$(RESET)"
	@echo
	@echo "  Try one of these:"
	@echo
	@echo "      $(BOLD)make help$(RESET)                   - ($(GREEN)default$(RESET)) you're looking at it ;-)"
	@echo
	@echo "      $(BOLD)make install$(RESET)                - install '$(SCRIPTNAME)'"
	@echo
	@echo "      $(BOLD)make install-modulefile$(RESET)     - install Environment Modules modulefile"
	@echo
	@echo "      $(BOLD)make release VERSION=$(MAGENTA)x.y.z$(RESET)  - update '$(SCRIPTNAME)' to version $(MAGENTA)x.y.z$(RESET)"
	@echo
	@echo
	@echo "  For more help, see $(READMEURL)"
	@echo

install: install-modulefile
	# install executable scripts / binaries into module dir
	install -d $(MODULEDIR)/bin
	for exe in $(EXECUTABLES); do install -m755 $$exe $(MODULEDIR)/bin; done

install-modulefile:
	# -D = create all components of DEST except the last, copy SOURCE to DEST
	install -D $(MODULEFILE) $(MODULEDESTFILE)

# get VERSION from the environment/command line; use it to update the
# '$version' variable in the 'MARIO' Perl script as well as the modulefile
release: $(EXECUTABLES) $(MODULEFILE)
ifeq ($(VERSION),)
	@echo >&2
	@echo "  $(UL)$(BOLD)$(RED)OH NOES!$(RESET)"
	@echo >&2
	@echo "  Expected a value for VERSION. Try again like this:"
	@echo >&2
	@echo "      $(BOLD)make release VERSION=x.y.z$(RESET)" >&2
	@echo >&2
	@false
else
	@if ! [[ $(VERSION) =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$$ ]]; then \
		echo "(!!) $(BOLD)$(RED)ERROR$(RESET) - bad version; expected x.y[.z], where x, y, and z are all integers." >&2; \
		exit 1; \
	fi
	@if git status --porcelain | grep .; then \
		echo "(!!) $(BOLD)$(RED)ERROR$(RESET) - Git working tree is dirty; commit changes and try again." >&2; \
		exit 1; \
	fi
	@if git tag | grep $(VERSION); then \
		echo "(!!) $(BOLD)$(RED)ERROR$(RESET) - release $(VERSION) already exists." >&2; \
		exit 1; \
	fi
	# replace version string in the Perl script
	sed -i "s/^\(my \$$version  *=  *\)'\(.*\)';/\1'$(VERSION)';/" $(SCRIPTNAME)
	# update the modified date in the Perl script
	sed -i "s/^\(my \$$modified  *=  *\)'\(.*\)';/\1'$(TODAY)';/" $(SCRIPTNAME)
	# replace version in the modulefile, too
	sed -i 's/\(set version \)".*"/\1"$(VERSION)"/' $(MODULEFILE)
	# create a new commit log entry and tag for the release
	git add $^ && git commit -m'Release v$(VERSION)'
	@#           ^^ means "the names of all the prerequisites"
	git tag v$(VERSION)
	@echo
	@echo "  $(UL)$(BOLD)$(BLUE)SUPER!$(RESET)"
	@echo
	@echo "  Updated '$(SCRIPTNAME)' and '$(MODULEFILE)' from v$(PKGVER) to v$(VERSION)"
	@echo
	@echo "  It would be a good idea now to:"
	@echo
	@echo "      $(BOLD)make install$(RESET)"
	@echo
	@echo "  to update the installed code and Environment Modules modulefile."
	@echo
	@echo "  Then push the new tag to your default Git remote, like this:"
	@echo
	@echo "      $(BOLD)git push && git push --tags$(RESET)"
	@echo
	@echo "  so the new release shows up on GitLab/GitHub."
	@echo
endif
