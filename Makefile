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
MARKDOWN_DIR := $(OUTPUT_DIR)/markdown
TMP_DIR := tmp

# Tools
XSLTPROC := xsltproc
FOP := fop
DBTOEPUB := dbtoepub
PANDOC := pandoc
TIDY := tidy
XMLLINT := xmllint

# XSLT parameters
XSLT_PARAMS := --xinclude

# Source files
SECTION_FILES := $(wildcard sections/section*.xml)
APPENDIX_FILES := $(wildcard appendixes/appendix*.xml)
SOURCE_FILES := $(MAIN_DOCUMENT) $(SECTION_FILES) $(APPENDIX_FILES)

# Figures and images
FIGURES := $(wildcard figures/*.png figures/*.jpg)
ADMON_IMAGES := $(wildcard css_stylesheets/admon*.png)
FOP_ADMON_IMAGES := $(wildcard xsl_stylesheets/images/*.png)
CSS_IMAGES := $(wildcard css_stylesheets/img/*)

# Default target
.DEFAULT_GOAL := html

# Docker/Podman configuration
CONTAINER_RUNTIME := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)
CONTAINER_IMAGE := docbook-builder
CONTAINER_TAG := latest
CONTAINER_FULL_IMAGE := $(CONTAINER_IMAGE):$(CONTAINER_TAG)
CONTAINER_RUN_OPTS := --rm -v $(CURDIR):/docs:z -w /docs

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make html       - Generate single-page HTML (default)"
	@echo "  make chunk      - Generate chunked HTML"
	@echo "  make pdf        - Generate PDF (requires Apache FOP)"
	@echo "  make epub       - Generate EPUB"
	@echo "  make markdown   - Generate Markdown (requires Pandoc)"
	@echo "  make all        - Generate all formats"
	@echo "  make validate   - Validate XML against DocBook schema"
	@echo "  make clean      - Remove generated files"
	@echo ""
	@echo "Docker/Podman targets (no local dependencies needed):"
	@echo "  make docker-build       - Build the Docker/Podman image"
	@echo "  make docker-html        - Generate HTML in container"
	@echo "  make docker-chunk       - Generate chunked HTML in container"
	@echo "  make docker-pdf         - Generate PDF in container"
	@echo "  make docker-epub        - Generate EPUB in container"
	@echo "  make docker-markdown    - Generate Markdown in container"
	@echo "  make docker-all         - Generate all formats in container"
	@echo "  make docker-validate    - Validate XML in container"
	@echo "  make docker-verify-epub - Verify EPUB file with epubcheck"
	@echo "  make docker-shell       - Open shell in container"
	@echo ""
	@echo "Output will be generated in the output/ directory"

# Create output directory structure
$(HTML_DIR) $(CHUNK_DIR) $(PDF_DIR) $(EPUB_DIR) $(MARKDOWN_DIR) $(TMP_DIR):
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
	@# Fix figure paths (remove ../ prefix)
	@echo "  Fixing figure paths..."
	@sed -i.bak 's|src="../figures/|src="figures/|g' $(HTML_DIR)/index.html
	@rm -f $(HTML_DIR)/index.html.bak
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
	@# Fix figure paths (remove ../ prefix)
	@echo "  Fixing figure paths..."
	@sed -i.bak 's|src="../figures/|src="figures/|g' $(HTML_DIR)/index.html
	@rm -f $(HTML_DIR)/index.html.bak
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
	@# Fix figure paths (remove ../ prefix)
	@echo "  Fixing figure paths..."
	@for html in $(CHUNK_DIR)/*.html; do \
		if [ -f "$$html" ]; then \
			sed -i.bak 's|src="../figures/|src="figures/|g' "$$html"; \
		fi; \
	done
	@rm -f $(CHUNK_DIR)/*.html.bak
	@echo "Chunked HTML documentation generated in $(CHUNK_DIR)/"

# Generate PDF
.PHONY: pdf
pdf: $(PDF_DIR)
	@echo "Generating PDF..."
	@# Prepare temporary directory with subdirectories
	@mkdir -p $(TMP_DIR)/figures $(TMP_DIR)/src $(TMP_DIR)/sections $(TMP_DIR)/appendixes
	@mkdir -p $(TMP_DIR)/xsl_stylesheets/images
	@cp -f $(MAIN_DOCUMENT) $(TMP_DIR)/
	@cp -f $(SECTION_FILES) $(TMP_DIR)/sections/ 2>/dev/null || true
	@cp -f $(APPENDIX_FILES) $(TMP_DIR)/appendixes/ 2>/dev/null || true
	@cp -f $(FIGURES) $(TMP_DIR)/figures/ 2>/dev/null || true
	@cp -f src/* $(TMP_DIR)/src/ 2>/dev/null || true
	@cp -f $(FOP_ADMON_IMAGES) $(TMP_DIR)/xsl_stylesheets/images/ 2>/dev/null || true
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
	@# Expand XIncludes and copy necessary files to tmp directory
	@echo "  Expanding XIncludes and preparing temporary directory..."
	@mkdir -p $(TMP_DIR)/sections $(TMP_DIR)/appendixes $(TMP_DIR)/figures
	@# Expand XIncludes into a single file
	@$(XMLLINT) --xinclude --output $(TMP_DIR)/$(MAIN_DOCUMENT) $(MAIN_DOCUMENT)
	@# Copy figures directory
	@cp -rf figures/* $(TMP_DIR)/figures/ 2>/dev/null || true
	@# Copy XSL and CSS to tmp
	@cp -rf $(XSL_DIR) $(TMP_DIR)/ 2>/dev/null || true
	@cp -rf css_stylesheets $(TMP_DIR)/ 2>/dev/null || true
	@# Now run dbtoepub from the tmp directory where all paths are relative
	@cd $(TMP_DIR) && $(DBTOEPUB) -s xsl_stylesheets/epub.xsl \
		-c css_stylesheets/article.css \
		$(MAIN_DOCUMENT) \
		-o ../$(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub
	@# dbtoepub doesn't include CSS-referenced images, so we need to add them manually
	@echo "  Adding CSS images to EPUB..."
	@mkdir -p $(TMP_DIR)/epub_extract
	@cd $(TMP_DIR)/epub_extract && unzip -q ../../$(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub
	@# Copy CSS images (png, gif, jpg) to OEBPS directory
	@find css_stylesheets -maxdepth 1 -type f \( -name "*.png" -o -name "*.gif" -o -name "*.jpg" \) \
		-exec cp {} $(TMP_DIR)/epub_extract/OEBPS/ \; 2>/dev/null || true
	@# Copy figures to OEBPS directory  
	@cp -rf $(TMP_DIR)/figures $(TMP_DIR)/epub_extract/OEBPS/ 2>/dev/null || true
	@# Fix figure paths in HTML files (remove ../ prefix)
	@echo "  Fixing figure paths in HTML..."
	@for html in $(TMP_DIR)/epub_extract/OEBPS/*.html; do \
		if [ -f "$$html" ]; then \
			sed -i.bak 's|src="../figures/|src="figures/|g' "$$html"; \
		fi; \
	done
	@rm -f $(TMP_DIR)/epub_extract/OEBPS/*.html.bak
	@# Fix CSS image references for missing files
	@echo "  Fixing CSS image references..."
	@if [ -f "$(TMP_DIR)/epub_extract/OEBPS/article.css" ]; then \
		sed -i.bak \
			-e '/text-document\.png/d' \
			-e 's|url("checkmark.png")|url("checkmark-green.png")|g' \
			$(TMP_DIR)/epub_extract/OEBPS/article.css; \
		rm -f $(TMP_DIR)/epub_extract/OEBPS/article.css.bak; \
	fi
	@# Add image entries to content.opf manifest
	@echo "  Updating OPF manifest..."
	@for img in $(TMP_DIR)/epub_extract/OEBPS/*.png $(TMP_DIR)/epub_extract/OEBPS/*.gif $(TMP_DIR)/epub_extract/OEBPS/*.jpg; do \
		if [ -f "$$img" ]; then \
			basename=$$(basename "$$img"); \
			ext=$${basename##*.}; \
			id=$$(echo "$$basename" | sed 's/[^a-zA-Z0-9]/_/g'); \
			if ! grep -q "id=\"$$id\"" $(TMP_DIR)/epub_extract/OEBPS/content.opf 2>/dev/null; then \
				sed -i.bak "s|</manifest>|<item id=\"$$id\" href=\"$$basename\" media-type=\"image/$$ext\"/>&|" \
					$(TMP_DIR)/epub_extract/OEBPS/content.opf; \
			fi; \
		fi; \
	done
	@# Add figures directory images to manifest
	@for img in $(TMP_DIR)/epub_extract/OEBPS/figures/*.png $(TMP_DIR)/epub_extract/OEBPS/figures/*.jpg; do \
		if [ -f "$$img" ]; then \
			basename=$$(basename "$$img"); \
			ext=$${basename##*.}; \
			mediatype="image/$$ext"; \
			if [ "$$ext" = "jpg" ]; then mediatype="image/jpeg"; fi; \
			id=$$(echo "figures_$$basename" | sed 's/[^a-zA-Z0-9]/_/g'); \
			if ! grep -q "id=\"$$id\"" $(TMP_DIR)/epub_extract/OEBPS/content.opf 2>/dev/null; then \
				sed -i.bak "s|</manifest>|<item id=\"$$id\" href=\"figures/$$basename\" media-type=\"$$mediatype\"/>&|" \
					$(TMP_DIR)/epub_extract/OEBPS/content.opf; \
			fi; \
		fi; \
	done
	@rm -f $(TMP_DIR)/epub_extract/OEBPS/content.opf.bak
	@# Re-package the EPUB with images included
	@cd $(TMP_DIR)/epub_extract && zip -q -X -r ../$(MAIN_DOCUMENT_STRIP).epub mimetype META-INF OEBPS
	@mv $(TMP_DIR)/$(MAIN_DOCUMENT_STRIP).epub $(EPUB_DIR)/
	@# Clean up temporary directory
	@rm -rf $(TMP_DIR)
	@echo "EPUB documentation generated in $(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub"

# Generate Markdown
.PHONY: markdown
markdown: $(MARKDOWN_DIR)
	@echo "Generating Markdown..."
	@# Check if pandoc is available
	@if ! command -v $(PANDOC) >/dev/null 2>&1; then \
		echo "Error: pandoc not found. Install it to generate Markdown."; \
		echo "On macOS: brew install pandoc"; \
		echo "On Linux: apt-get install pandoc or dnf install pandoc"; \
		exit 1; \
	fi
	@# Create temporary directory and expand XIncludes
	@mkdir -p $(TMP_DIR)
	@$(XMLLINT) --xinclude --output $(TMP_DIR)/$(MAIN_DOCUMENT) $(MAIN_DOCUMENT)
	@# Copy figures to tmp for relative path resolution
	@mkdir -p $(TMP_DIR)/figures
	@cp -f $(FIGURES) $(TMP_DIR)/figures/ 2>/dev/null || true
	@# Convert DocBook to Markdown using Pandoc (run from tmp dir for image paths)
	@cd $(TMP_DIR) && $(PANDOC) --from=docbook --to=gfm \
		--standalone \
		--extract-media=../$(MARKDOWN_DIR) \
		--output=../$(MARKDOWN_DIR)/$(MAIN_DOCUMENT_STRIP).md \
		$(MAIN_DOCUMENT)
	@# Fix image paths - remove the relative directory prefix since images are in same dir as markdown
	@# Use a portable sed approach that works on both macOS and Linux
	@sed 's|src="../output/markdown/|src="|g' $(MARKDOWN_DIR)/$(MAIN_DOCUMENT_STRIP).md > $(MARKDOWN_DIR)/$(MAIN_DOCUMENT_STRIP).md.tmp
	@mv $(MARKDOWN_DIR)/$(MAIN_DOCUMENT_STRIP).md.tmp $(MARKDOWN_DIR)/$(MAIN_DOCUMENT_STRIP).md
	@# Clean up temporary expanded XML file
	@rm -f $(TMP_DIR)/$(MAIN_DOCUMENT)
	@echo "Markdown documentation generated in $(MARKDOWN_DIR)/$(MAIN_DOCUMENT_STRIP).md"

# Generate all formats
.PHONY: all
all: htmlfancy chunk pdf epub markdown
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
	@rm -f .collapsed.*.xml
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

# ============================================================================
# Docker/Podman targets for containerized builds
# ============================================================================

# Check if container runtime is available
.PHONY: check-container-runtime
check-container-runtime:
	@if [ -z "$(CONTAINER_RUNTIME)" ]; then \
		echo "Error: Neither podman nor docker found."; \
		echo "Please install Podman or Docker to use containerized builds."; \
		exit 1; \
	fi
	@echo "Using container runtime: $(CONTAINER_RUNTIME)"

# Build the Docker/Podman image
.PHONY: docker-build
docker-build: check-container-runtime
	@echo "Building container image $(CONTAINER_FULL_IMAGE)..."
	$(CONTAINER_RUNTIME) build -t $(CONTAINER_FULL_IMAGE) .
	@echo "Container image built successfully."

# Generate HTML in container
.PHONY: docker-html
docker-html: check-container-runtime
	@echo "Generating HTML in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make html
	@echo "HTML generated successfully."

# Generate chunked HTML in container
.PHONY: docker-chunk
docker-chunk: check-container-runtime
	@echo "Generating chunked HTML in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make chunk
	@echo "Chunked HTML generated successfully."

# Generate PDF in container
.PHONY: docker-pdf
docker-pdf: check-container-runtime
	@echo "Generating PDF in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make pdf
	@echo "PDF generated successfully."

# Generate EPUB in container
.PHONY: docker-epub
docker-epub: check-container-runtime
	@echo "Generating EPUB in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make epub
	@echo "EPUB generated successfully."

# Generate Markdown in container
.PHONY: docker-markdown
docker-markdown: check-container-runtime
	@echo "Generating Markdown in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make markdown
	@echo "Markdown generated successfully."

# Generate all formats in container
.PHONY: docker-all
docker-all: check-container-runtime
	@echo "Generating all formats in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make all
	@echo "All formats generated successfully."

# Validate XML in container
.PHONY: docker-validate
docker-validate: check-container-runtime
	@echo "Validating XML in container..."
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) make validate

# Verify EPUB file with epubcheck
.PHONY: docker-verify-epub
docker-verify-epub: check-container-runtime
	@echo "Verifying EPUB file with epubcheck..."
	@if [ ! -f $(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub ]; then \
		echo "Error: EPUB file not found. Run 'make docker-epub' first."; \
		exit 1; \
	fi
	$(CONTAINER_RUNTIME) run $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) \
		epubcheck $(EPUB_DIR)/$(MAIN_DOCUMENT_STRIP).epub
	@echo "EPUB verification complete."

# Open interactive shell in container
.PHONY: docker-shell
docker-shell: check-container-runtime
	@echo "Opening shell in container..."
	$(CONTAINER_RUNTIME) run -it $(CONTAINER_RUN_OPTS) $(CONTAINER_FULL_IMAGE) /bin/bash

# Clean container image
.PHONY: docker-clean
docker-clean: check-container-runtime
	@echo "Removing container image..."
	$(CONTAINER_RUNTIME) rmi $(CONTAINER_FULL_IMAGE) || true
	@echo "Container image removed."

# Phony targets
.PHONY: help html htmlfancy chunk pdf epub all validate clean imglist check-tools
.PHONY: check-container-runtime docker-build docker-html docker-chunk docker-pdf
.PHONY: docker-epub docker-all docker-validate docker-verify-epub docker-shell docker-clean
