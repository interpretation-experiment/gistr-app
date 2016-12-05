# TODO
# - postcss for autoprefixer

# Path and Executables
PATH               := node_modules/.bin:$(PATH)
SHELL              := /bin/bash
HASH               := md5sum | awk '{print $$1}'
HB                 := hb -i
BABEL              := babel --no-babelrc --presets=latest
ELM                := elm-make
ELMCSS             := elm-css
ASSET_PATH          = sed "s/^$(src)\/\(.*\)$$/\1/"
SEDESCAPE          := sed "s/\//\\\\\//g" | sed "s/\./\\\\./g"

# Colors
GREEN              := \033[0;32m
BOLD               := \033[1m
LOW                := \033[2m
NORMAL             := \033[0m

# Folders
src                := src
src_assets         := $(src)/assets
elm_artifacts      := elm-stuff/build-artifacts
build              := build
dist               := dist
build_tmp          := build_tmp

# Parameters
prod               := prod
ifeq ($(TARGET), $(prod))
  ELMFLAGS         := --yes --warn
  CATCSS           := uglifycss
  CATJS            := babel --no-babelrc --presets=babili
  output           := $(dist)
  vendor_css_hash   = -$(shell cat $(vendor_css) | $(HASH))
  app_css_hash      = -$(shell cat $(app_css) | $(HASH))
  app_js_hash       = -$(shell cat $(app_js) | $(HASH))
  ASSET_PATH_HASH   = sed "s/^$(src)\/\(.*\)\.\([^\.]*\)$$/\1-$${hash}.\2/"
else
  ELMFLAGS         := --yes --warn --debug
  CATCSS           := cat
  CATJS            := cat
  output           := $(build)
  ASSET_PATH_HASH   = $(ASSET_PATH)
endif

# Source files
assets             := $(shell find $(src_assets) -type f)
sources_vendor_css := $(src)/vendor.css
sources_app_css    := $(src)/app.css
sources_elm        := $(shell find $(src) -name "*.elm")
stylesheets_elm    := $(src)/Stylesheets.elm
main_elm           := $(src)/Main.elm
index_js           := $(src)/index.js
index_html         := $(src)/index.html

# Build files
vendor_css         := $(build_tmp)/$(output)/vendor.css
app_css            := $(build_tmp)/$(output)/app.css
main_elm_js        := $(build_tmp)/$(output)/main-elm.js
babel_index_js     := $(build_tmp)/$(output)/babel-index.js
app_js             := $(build_tmp)/$(output)/app.js
vendor_css_final    = $(output)/vendor$(vendor_css_hash).css
app_css_final       = $(output)/app$(app_css_hash).css
app_js_final        = $(output)/app$(app_js_hash).js
html               := $(output)/index.html


.PHONY: all prod clean clean-elm clean-javascript


define hash-asset-paths =
  for a in $(assets); do \
    hash=$$(cat $${a} | $(HASH)); \
    sedpath=$$(echo $${a} | $(ASSET_PATH) | $(SEDESCAPE)); \
    sedpathhash=$$(echo $${a} | $(ASSET_PATH_HASH) | $(SEDESCAPE)); \
    sed -i "s/$${sedpath}/$${sedpathhash}/g" $@; \
  done
endef

all: $(html)
	@echo -e "$(GREEN)$(BOLD)App built$(NORMAL)$(BOLD) → $(output)/$(NORMAL)\n"

prod: clean
	@TARGET=prod $(MAKE) --no-print-directory


$(vendor_css): $(sources_vendor_css) $(assets)
	@echo -e "$(LOW)Generating vendor.css$(NORMAL)"
	@mkdir -p $(@D)
	@$(CATCSS) $(sources_vendor_css) > $@
	@$(hash-asset-paths)


# Suppress chattiness of elm-css, we already have progress report with elm-make
$(app_css): $(sources_elm) $(sources_app_css) $(assets)
	@echo -e "$(LOW)Generating app.css$(NORMAL)"
	@$(eval css_tmp := $(shell mktemp -d -p $(build_tmp)))
	@$(ELMCSS) $(stylesheets_elm) --output $(css_tmp) 1> /dev/null
	@$(CATCSS) $(sources_app_css) $(css_tmp)/* > $@
	@$(hash-asset-paths)
	@rm -rf $(css_tmp)


$(app_js): $(index_js) $(sources_elm) $(assets)
	@echo -e "$(LOW)Generating app.js"
	@mkdir -p $(@D)
	@$(ELM) $(main_elm) $(ELMFLAGS) --output $(main_elm_js)
	@$(BABEL) -o $(babel_index_js) $(index_js)
	@$(CATJS) $(main_elm_js) $(babel_index_js) > $@
	@$(hash-asset-paths)
	@echo -ne "$(NORMAL)"


$(html): $(app_js) $(vendor_css) $(app_css) $(index_html)
	@echo -e "$(LOW)Generating index.html$(NORMAL)"
	@mkdir -p $(@D)
	@cp $(vendor_css) $(vendor_css_final)
	@cp $(app_css) $(app_css_final)
	@cp $(app_js) $(app_js_final)
	@echo '{"vendor-css": "$(subst $(@D),,$(vendor_css_final))", "app-css": "$(subst $(@D),,$(app_css_final))", "app-js": "$(subst $(@D),,$(app_js_final))"}' | $(HB) $(index_html) > $@
	@for a in $(assets); do \
	  hash=$$(cat $${a} | $(HASH)); \
	  pathhash=$$(echo $${a} | $(ASSET_PATH_HASH)); \
	  mkdir -p $(@D)/$$(dirname $${pathhash}); \
	  cp $${a} $(@D)/$${pathhash}; \
	done


# Don't remove the actual $(build) directory since this disrupts BrowserSync,
# just remove its contents
clean-javascript:
	@echo -e "$(LOW)Cleaning javascript build directories$(NORMAL)"
	@rm -rf $(dist) $(build)/* $(build_tmp)


clean-elm:
	@echo -e "$(LOW)Cleaning Elm build directories$(NORMAL)"
	@rm -rf $(elm_artifacts)


clean: clean-javascript clean-elm
	@echo -e "$(GREEN)$(BOLD)Build directories cleaned$(NORMAL)\n"
