# Makefile for building The Complete OpenSuSE Mail Server documentation
# Converted from Phing build.xml for better accessibility
# 
# Available targets:
#   html (default) - Generate single-page HTML
#   chunk          - Generate chunked HTML (one file per section)
#   pdf            - Generate PDF (requires Apache FOP)
#   epub           - Generate EPUB
#   all            - Generate all formats
#   validate       - Validate XML against DocBook schema
#   clean          - Remove generated files

# Configuration
MAIN_DOCUMENT := mailsetup-article.xml
MAIN_DOCUMENT_STRIP := mailsetup-article

# Paths - adjust these based on your system
# For macOS with Homebrew, DocBook XSL is typically in:
DOCBOOK_XSL_DIR := /usr/local/opt/docbook-xsl/docbook-xsl
# For Linux, typically:
# DOCBOOK_XSL_DIR := /usr/share/xml/docbook/stylesheet/nwalsh

# Alternative: use our custom XSL which will import from system location
XSL_DIR := xsl_stylesheets

# CSS Stylesheets
CSS_STYLE := css_stylesheets/article.css
CSS_STYLE_FANCY := css_stylesheets/article-fancyterm.css
CSS_NAME := article.css

# Output directories
OUTPUT_DIR := output
HTML_DIR := $(OUTPUT_DIR)/html
CHUNK_DIR := $(OUTPUT_DIR)/chunkhtml
PDF_DIR := $(OUTPUT_DIR)/pdf
EPUB_DIR := $(OUTPUT_DIR)/epub
TMP_DIR := tmp

# Tools
XSLTPROC := xsltproc
FOP := fop
DBTOEPUB := dbtoepub
TIDY := tidy
XMLLINT := xmllint

# XSLT parameters
XSLT_PARAMS := --xinclude

# Source files
SECTION_FILES := $(wildcard section*.xml)
APPENDIX_FILES := $(wildcard appendix*.xml)
SOURCE_FILES := $(MAIN_DOCUMENT) $(SECTION_FILES) $(APPENDIX_FILES)

# Figures and images
FIGURES := $(wildcard figures/*.png figures/*.jpg)
ADMON_IMAGES := $(wildcard css_stylesheets/admon*.png)
CSS_IMAGES := $(wildcard css_stylesheets/img/*)

# Default target
.DEFAULT_GOAL := html

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make html       - Generate single-page HTML (default)"
	@echo "  make chunk      - Generate chunked HTML"
	@echo "  make pdf        - Generate PDF (requires Apache FOP)"
	@echo "  make epub       - Generate EPUB"
	@echo "  make all        - Generate all formats"
	@echo "  make validate   - Validate XML against DocBook schema"
	@echo "  make clean      - Remove generated files"
	@echo ""
	@echo "Output will be generated in the output/ directory"

# Create output directory structure
$(HTML_DIR) $(CHUNK_DIR) $(PDF_DIR) $(EPUB_DIR) $(TMP_DIR):
	@mkdir -p $@

# Validate XML against DocBook schema
.PHONY: validate
validate:
	@echo "Validating XML files against DocBook schema..."
	@for file in $(SOURCE_FILES); do \
		echo "  Validating $$file..."; \
		$(XMLLINT) --noout --xinclude --relaxng \
			http://www.oasis-open.org/docbook/xml/5.0/rng/docbookxi.rng \
			$$file || exit 1; \
	done
	@echo "All files validated successfully."

# Generate single-page HTML
.PHONY: html
html: $(HTML_DIR)
	@echo "Generating single-page HTML..."
	@mkdir -p $(HTML_DIR)/figures
	@# Copy figures
	@cp -f $(FIGURES) $(HTML_DIR)/figures/ 2>/dev/null || true
	@# Copy admon images
	@cp -f $(ADMON_IMAGES) $(HTML_DIR)/ 2>/dev/null || true
	@# Copy CSS images
	@mkdir -p $(HTML_DIR)/img
	@cp -f $(CSS_IMAGES) $(HTML_DIR)/img/ 2>/dev/null || true
	@# Copy checkmark images
	@cp -f css_stylesheets/checkmark-green.png $(HTML_DIR)/checkmark.png 2>/dev/null || true
	@cp -f css_stylesheets/checkmark-plain.gif $(HTML_DIR)/checkmark-plain.gif 2>/dev/null || true
	@# Copy CSS stylesheet
	@cp -f $(CSS_STYLE) $(HTML_DIR)/$(CSS_NAME)
	@# Transform XML to HTML
	$(XSLTPROC) $(XSLT_PARAMS) \
		--output $(HTML_DIR)/index.html \
		$(XSL_DIR)/html.xsl \
		$(MAIN_DOCUMENT)
	@# Optionally tidy HTML (ignore errors)
	@-$(TIDY) -m -utf8 $(HTML_DIR)/index.html 2>/dev/null || true
	@echo "HTML documentation generated in $(HTML_DIR)/index.html"

# Generate single-page HTML with fancy terminal styling
.PHONY: htmlfancy
htmlfancy: $(HTML_DIR)
	@echo "Generating single-page HTML with fancy terminal styling..."
	@mkdir -p $(HTML_DIR)/figures
	@# Copy figures
	@cp -f $(FIGURES) $(HTML_DIR)/figures/ 2>/dev/null || true
	@# Copy admon images
	@cp -f $(ADMON_IMAGES) $(HTML_DIR)/ 2>/dev/null || true
	@# Copy CSS images
	@mkdir -p $(HTML_DIR)/img
	@cp -f $(CSS_IMAGES) $(HTML_DIR)/img/ 2>/dev/null || true
	@# Copy checkmark images
	@cp -f css_stylesheets/checkmark-green.png $(HTML_DIR)/checkmark.png 2>/dev/null || true
	@cp -f css_stylesheets/checkmark-plain.gif $(HTML_DIR)/checkmark-plain.gif 2>/dev/null || true
	@# Copy fancy CSS stylesheet
	@cp -f $(CSS_STYLE_FANCY) $(HTML_DIR)/$(CSS_NAME)
	@# Transform XML to HTML
	$(XSLTPROC) $(XSLT_PARAMS) \
		--output $(HTML_DIR)/index.html \
		$(XSL_DIR)/html.fancycmd.xsl \
		$(MAIN_DOCUMENT)
	@# Optionally tidy HTML (ignore errors)
	@-$(TIDY) -m -utf8 $(HTML_DIR)/index.html 2>/dev/null || true
	@echo "HTML documentation with fancy styling generated in $(HTML_DIR)/index.html"

# Generate chunked HTML
.PHONY: chunk
chunk: $(CHUNK_DIR)
	@echo "Generating chunked HTML..."
	@mkdir -p $(CHUNK_DIR)/figures
	@# Copy figures
	@cp -f $(FIGURES) $(CHUNK_DIR)/figures/ 2>/dev/null || true
	@# Copy admon images
	@cp -f $(ADMON_IMAGES) $(CHUNK_DIR)/ 2>/dev/null || true
	@# Copy CSS images  
	@mkdir -p $(CHUNK_DIR)/img
	@cp -f $(CSS_IMAGES) $(CHUNK_DIR)/img/ 2>/dev/null || true
	@# Copy checkmark images
	@cp -f css_stylesheets/checkmark-green.png $(CHUNK_DIR)/checkmark.png 2>/dev/null || true
	@cp -f css_stylesheets/checkmark-plain.gif $(CHUNK_DIR)/checkmark-plain.gif 2>/dev/null || true
	@# Copy CSS stylesheet
	@cp -f $(CSS_STYLE) $(CHUNK_DIR)/$(CSS_NAME)
	@# Transform XML to chunked HTML
	$(XSLTPROC) $(XSLT_PARAMS) \
		--stringparam base.dir $(CHUNK_DIR)/ \
		$(XSL_DIR)/chunk.xsl \
		$(MAIN_DOCUMENT)
	@echo "Chunked HTML documentation generated in $(CHUNK_DIR)/"

# Generate PDF
.PHONY: pdf
pdf: $(PDF_DIR) $(TMP_DIR)
	@echo "Generating PDF..."
	@# Prepare temporary directory
	@mkdir -p $(TMP_DIR)/figures $(TMP_DIR)/src
	@cp -f $(SOURCE_FILES) $(TMP_DIR)/
	@cp -f $(FIGURES) $(TMP_DIR)/figures/ 2>/dev/null || true
	@cp -f src/* $(TMP_DIR)/src/ 2>/dev/null || true
	@cp -f $(ADMON_IMAGES) $(TMP_DIR)/ 2>/dev/null || true
	@cp -f css_stylesheets/checkmark-green.png $(TMP_DIR)/checkmark.png 2>/dev/null || true
	@cp -f css_stylesheets/checkmark-plain.gif $(TMP_DIR)/checkmark-plain.gif 2>/dev/null || true
	@# Generate FO (Formatting Objects) from XML
	@cd $(TMP_DIR) && $(XSLTPROC) $(XSLT_PARAMS) \
		--output manual.fo \
		../$(XSL_DIR)/fo.xsl \
		$(MAIN_DOCUMENT)
	@# Convert FO to PDF using Apache FOP
	@$(FOP) $(TMP_DIR)/manual.fo -pdf $(PDF_DIR)/article.pdf
	@# Clean up temporary directory
	@rm -rf $(TMP_DIR)
	@echo "PDF documentation generated in $(PDF_DIR)/article.pdf"

# Generate EPUB
.PHONY: epub
epub: $(EPUB_DIR)
	@echo "Generating EPUB..."
	@# Check if dbtoepub is available
	@if ! command -v $(DBTOEPUB) >/dev/null 2>&1; then \
		echo "Error: dbtoepub not found. Install it to generate EPUB."; \
		echo "On some systems this is part of the docbook-utils package."; \
		exit 1; \
	fi
	@# Generate EPUB
	$(DBTOEPUB) -s $(XSL_DIR)/epub.xsl \
		-c $(CSS_STYLE) \
		$(MAIN_DOCUMENT) \
		-o $(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub
	@echo "EPUB documentation generated in $(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub"

# Generate all formats
.PHONY: all
all: htmlfancy chunk pdf epub
	@echo "All documentation formats generated successfully."

# Generate image list (utility target)
.PHONY: imglist
imglist:
	@echo "Generating image list..."
	@$(XSLTPROC) $(XSL_DIR)/xmldepend.xsl $(MAIN_DOCUMENT) | \
		grep -E '\.(jpg|png)$$' | sort | uniq > imglist.txt
	@echo "Image list generated in imglist.txt"

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(OUTPUT_DIR)
	@rm -rf $(TMP_DIR)
	@rm -f imglist.txt
	@echo "Clean complete."

# Check for required tools
.PHONY: check-tools
check-tools:
	@echo "Checking for required tools..."
	@command -v $(XSLTPROC) >/dev/null 2>&1 || \
		{ echo "Error: xsltproc not found. Install libxslt."; exit 1; }
	@echo "  ✓ xsltproc found"
	@command -v $(XMLLINT) >/dev/null 2>&1 || \
		{ echo "Warning: xmllint not found. Validation will not work."; }
	@if command -v $(XMLLINT) >/dev/null 2>&1; then \
		echo "  ✓ xmllint found"; \
	fi
	@command -v $(FOP) >/dev/null 2>&1 || \
		{ echo "Warning: Apache FOP not found. PDF generation will not work."; }
	@if command -v $(FOP) >/dev/null 2>&1; then \
		echo "  ✓ Apache FOP found"; \
	fi
	@command -v $(DBTOEPUB) >/dev/null 2>&1 || \
		{ echo "Warning: dbtoepub not found. EPUB generation will not work."; }
	@if command -v $(DBTOEPUB) >/dev/null 2>&1; then \
		echo "  ✓ dbtoepub found"; \
	fi
	@command -v $(TIDY) >/dev/null 2>&1 || \
		{ echo "Warning: tidy not found. HTML cleanup will be skipped."; }
	@if command -v $(TIDY) >/dev/null 2>&1; then \
		echo "  ✓ tidy found"; \
	fi
	@echo "Tool check complete."

# Phony targets
.PHONY: help html htmlfancy chunk pdf epub all validate clean imglist check-tools
