# Path and Executables
PATH             := node_modules/.bin:$(PATH)
SHELL            := /bin/bash
HASH             := md5sum | awk '{print $$1}'
HB               := hb -i
BABEL            := babel --no-babelrc --presets=latest
ELM              := elm make

# Colors
GREEN            := \033[0;32m
BOLD             := \033[1m
LOW              := \033[2m
NORMAL           := \033[0m

# Folders
src              := src
elm_artifacts    := elm-stuff/build-artifacts
build            := build
dist             := dist
build_tmp        := build_tmp

# Parameters
prod            := prod
ifeq ($(TARGET), $(prod))
  ELMFLAGS       := --yes --warn
  CATCSS         := uglifycss
  CATJS          := babel --no-babelrc --presets=babili
  output         := $(dist)
  vendor_hash     = -$(shell cat $(vendor_css) | $(HASH)).css
  app_hash        = -$(shell cat $(app_js) | $(HASH)).js
else
  ELMFLAGS       := --yes --warn --debug
  CATCSS         := cat
  CATJS          := cat
  output         := $(build)
endif

# Source files
sources_css      := node_modules/ace-css/css/ace.css
sources_elm      := $(shell find $(src) -name "*.elm")
main_elm         := $(src)/Main.elm
index_js         := $(src)/index.js
index_html       := $(src)/index.html

# Build files
vendor_css       := $(build_tmp)/$(output)/vendor.css
main_elm_js      := $(build_tmp)/$(output)/main-elm.js
babel_index_js   := $(build_tmp)/$(output)/babel-index.js
app_js           := $(build_tmp)/$(output)/app.js
vendor_final      = $(output)/vendor$(vendor_hash).css
app_final         = $(output)/app$(app_hash).js
html             := $(output)/index.html


.PHONY: all clean clean-elm clean-javascript


all: $(html)
	@echo -e "$(GREEN)$(BOLD)App built$(NORMAL)$(BOLD) → $(output)/$(NORMAL)\n"


$(vendor_css): $(sources_css)
	@echo -e "$(LOW)Generating vendor.css$(NORMAL)"
	@mkdir -p $(@D)
	@$(CATCSS) $^ > $@


$(app_js): $(index_js) $(sources_elm)
	@echo -e "$(LOW)Generating app.js"
	@mkdir -p $(@D)
	@$(ELM) $(main_elm) $(ELMFLAGS) --output $(main_elm_js)
	@$(BABEL) -o $(babel_index_js) $<
	@$(CATJS) $(main_elm_js) $(babel_index_js) > $@
	@echo -e "$(NORMAL)"


$(html): $(vendor_css) $(app_js) $(index_html)
	@echo -e "$(LOW)Generating index.html$(NORMAL)"
	@mkdir -p $(@D)
	@cp $(vendor_css) $(vendor_final)
	@cp $(app_js) $(app_final)
	@echo '{"vendor-css": "$(subst $(@D),,$(vendor_final))", "app-js": "$(subst $(@D),,$(app_final))"}' | $(HB) $(index_html) > $@


clean-javascript:
	@echo -e "$(LOW)Cleaning javascript build directories$(NORMAL)"
	@rm -rf $(dist) $(build) $(build_tmp)


clean-elm:
	@echo -e "$(LOW)Cleaning Elm build directories$(NORMAL)"
	@rm -rf $(elm_artifacts)


clean: clean-javascript clean-elm
	@echo -e "$(GREEN)$(BOLD)Build directories cleaned$(NORMAL)\n"
