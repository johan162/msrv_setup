# Dockerfile for building DocBook documentation
# Works with both Docker and Podman
# Based on Alpine Linux for minimal size

FROM alpine:3.19

LABEL maintainer="DocBook Build Environment"
LABEL description="Container for building DocBook 5 documentation in multiple formats"

# Install build dependencies
RUN apk add --no-cache \
    # Core XML/XSLT tools
    libxslt \
    libxml2-utils \
    docbook-xsl \
    docbook-xml \
    # Java for Apache FOP (PDF generation)
    openjdk11-jre \
    # Ruby and dependencies for dbtoepub
    ruby \
    ruby-dev \
    ruby-rexml \
    make \
    gcc \
    musl-dev \
    # Fonts for PDF generation
    ttf-liberation \
    fontconfig \
    # wget for downloading tools
    wget \
    bash \
    # Utilities
    zip \
    unzip

# Install Apache FOP for PDF generation
ENV FOP_VERSION=2.9
RUN cd /opt && \
    wget -q https://archive.apache.org/dist/xmlgraphics/fop/binaries/fop-${FOP_VERSION}-bin.tar.gz && \
    tar xzf fop-${FOP_VERSION}-bin.tar.gz && \
    rm fop-${FOP_VERSION}-bin.tar.gz && \
    chmod +x /opt/fop-${FOP_VERSION}/fop/fop && \
    ln -s /opt/fop-${FOP_VERSION}/fop/fop /usr/local/bin/fop && \
    # Configure FOP fonts
    mkdir -p /root/.fop && \
    fc-cache -f

# Install dbtoepub (DocBook to EPUB converter)
RUN gem install --no-document dbtoepub

# Install epubcheck for EPUB validation
ENV EPUBCHECK_VERSION=5.1.0
RUN cd /opt && \
    wget -q https://github.com/w3c/epubcheck/releases/download/v${EPUBCHECK_VERSION}/epubcheck-${EPUBCHECK_VERSION}.zip && \
    unzip -q epubcheck-${EPUBCHECK_VERSION}.zip && \
    rm epubcheck-${EPUBCHECK_VERSION}.zip && \
    echo '#!/bin/sh' > /usr/local/bin/epubcheck && \
    echo 'java -jar /opt/epubcheck-'${EPUBCHECK_VERSION}'/epubcheck.jar "$@"' >> /usr/local/bin/epubcheck && \
    chmod +x /usr/local/bin/epubcheck

# Set up XML catalog for DocBook
RUN mkdir -p /etc/xml && \
    xmlcatalog --noout --create /etc/xml/catalog && \
    # Add DocBook XSL catalog
    xmlcatalog --noout --add "delegatePublic" \
        "-//OASIS//DTD DocBook XML" \
        "file:///usr/share/xml/docbook/schema/dtd/catalog.xml" \
        /etc/xml/catalog && \
    xmlcatalog --noout --add "delegatePublic" \
        "-//OASIS//ENTITIES DocBook XML" \
        "file:///usr/share/xml/docbook/schema/dtd/catalog.xml" \
        /etc/xml/catalog && \
    xmlcatalog --noout --add "delegateSystem" \
        "http://www.oasis-open.org/docbook/" \
        "file:///usr/share/xml/docbook/schema/dtd/catalog.xml" \
        /etc/xml/catalog && \
    xmlcatalog --noout --add "delegateURI" \
        "http://www.oasis-open.org/docbook/" \
        "file:///usr/share/xml/docbook/schema/dtd/catalog.xml" \
        /etc/xml/catalog && \
    # Add rewrite rules for DocBook XSL stylesheets
    xmlcatalog --noout --add "rewriteSystem" \
        "http://docbook.sourceforge.net/release/xsl/current" \
        "file:///usr/share/xml/docbook/xsl-stylesheets-1.79.2" \
        /etc/xml/catalog && \
    xmlcatalog --noout --add "rewriteURI" \
        "http://docbook.sourceforge.net/release/xsl/current" \
        "file:///usr/share/xml/docbook/xsl-stylesheets-1.79.2" \
        /etc/xml/catalog

# Set environment variables
ENV XML_CATALOG_FILES=/etc/xml/catalog
ENV JAVA_OPTS="-Xmx1024m"

# Create working directory
WORKDIR /docs

# Default command
CMD ["/bin/bash"]
