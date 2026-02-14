# The Complete OpenSuSE Mail Server

**A comprehensive guide to setting up a full-featured IMAP/SMTP/HTTPS/Webmail server**

> **Archival Notice**: This project is being preserved as a historical reference and educational resource. It was originally created in 2011-2012 and represents the state of mail server configuration at that time. While the fundamental concepts remain relevant, specific software versions, configuration syntax, and security best practices have evolved. This repository is **not actively maintained** and should be used primarily as a learning resource or historical reference.

## Table of Contents

- [The Complete OpenSuSE Mail Server](#the-complete-opensuse-mail-server)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [What This Document Covers](#what-this-document-covers)
  - [Why This Guide Matters](#why-this-guide-matters)
    - [The Need for Self-Hosted Mail](#the-need-for-self-hosted-mail)
    - [The Gap This Document Fills](#the-gap-this-document-fills)
  - [The Complexity of a Modern Mail Setup](#the-complexity-of-a-modern-mail-setup)
    - [Multiple Protocols and Ports](#multiple-protocols-and-ports)
    - [Security Layers](#security-layers)
    - [Service Integration](#service-integration)
    - [Configuration Complexity](#configuration-complexity)
  - [Components Covered](#components-covered)
    - [Core Mail Services](#core-mail-services)
    - [Filtering and Security](#filtering-and-security)
    - [Web Services](#web-services)
    - [Supporting Infrastructure](#supporting-infrastructure)
  - [Building the Documentation](#building-the-documentation)
    - [Prerequisites](#prerequisites)
      - [Installing on macOS](#installing-on-macos)
      - [Installing on Linux (OpenSuSE/SUSE)](#installing-on-linux-opensusesuse)
    - [Build Targets](#build-targets)
    - [Output Locations](#output-locations)
  - [Project Structure](#project-structure)
    - [DocBook Structure](#docbook-structure)
  - [Historical Context](#historical-context)
    - [When This Was Written (2010-2012)](#when-this-was-written-2010-2012)
    - [What Has Changed Since](#what-has-changed-since)
    - [Why Preserve This?](#why-preserve-this)
  - [License](#license)
  - [Contributing](#contributing)

## Overview

This comprehensive guide documents the complete process of setting up a production-ready mail server on OpenSuSE Linux. Unlike superficial tutorials that gloss over critical details, this document provides an exhaustive, technically rigorous explanation of every component, configuration decision, and security consideration involved in creating a modern mail infrastructure.

The guide covers everything from basic SMTP and IMAP setup to advanced topics like SSL/TLS encryption, spam filtering, mail filtering with procmail, webmail access via Roundcube, and proper integration of all components into a cohesive system.

## Quick Start

To build and view the documentation on macOS:

```bash
# Install dependencies
brew install docbook-xsl

# Build HTML documentation
make html

# Open in your browser
open output/html/index.html

# Or build all formats
make all
```

The documentation comprises **over 4,700 lines** of detailed XML covering 11 main sections and 6 comprehensive appendices with complete configuration examples.

## What This Document Covers

The tutorial walks through setting up a complete mail server stack consisting of 11 detailed sections:

1. **Introduction** - Why run your own mail server and when it makes sense
2. **Component Overview** - Understanding the ecosystem of mail server software
3. **Setup Process** - High-level architecture and planning
4. **Apache HTTP Server** - Web server configuration with SSL/TLS
5. **Dovecot** - IMAP server for mail retrieval
6. **Postfix** - SMTP server for sending and receiving mail
7. **Fetchmail** - Retrieving mail from external accounts
8. **SpamAssassin** - Spam filtering and detection
9. **Procmail** - Mail filtering and automated processing
10. **Roundcube** - Web-based mail client
11. **References and Resources** - Where to find more information

The document also includes 6 comprehensive appendices with complete configuration file examples for Postfix, Procmail, Dovecot, OpenSSL, and Apache.

## Why This Guide Matters

### The Need for Self-Hosted Mail

While public mail providers like Gmail and Outlook.com offer convenience, there are compelling reasons to run your own mail infrastructure:

- **Privacy and Data Sovereignty** - Complete control over your communication data
- **Custom Processing** - Automated mail handling, virus scanning, custom filtering rules
- **Backup Control** - Your own backup strategy and data retention policies
- **Domain Control** - Send mail from specific domains you control
- **Multi-Account Aggregation** - Centralize mail from multiple sources
- **Learning Experience** - Deep understanding of email protocols and infrastructure

### The Gap This Document Fills

Most mail server tutorials suffer from one or more problems:
- They perpetuate outdated practices from older tutorials
- They use deprecated configuration options that "work" but aren't optimal
- They skip critical security considerations
- They don't explain *why* certain configurations are necessary
- They assume too much prior knowledge or skip too many details

This guide aims to provide a *correct* and *modern* (for 2011-2012) explanation with thorough reasoning for every configuration choice.

## The Complexity of a Modern Mail Setup

Setting up a proper mail server is genuinely complex because email is an inherently distributed system built on multiple cooperating protocols and services. Understanding this complexity is crucial:

### Multiple Protocols and Ports

Email involves numerous protocols, each serving specific purposes:
- **SMTP (Port 25, 465, 587)** - Mail transfer between servers and mail submission
- **IMAP (Port 143, 993)** - Mail retrieval and folder synchronization
- **POP3 (Port 110, 995)** - Simple mail retrieval
- **HTTP/HTTPS (Port 80, 443)** - Webmail interface
- **Submission (Port 587)** - Authenticated mail submission from clients

### Security Layers

Modern mail servers require multiple security layers:
- **SSL/TLS Encryption** - Protecting data in transit
- **SASL Authentication** - Secure user authentication
- **Certificate Management** - Creating and managing SSL certificates
- **Access Control** - Firewall rules and service restrictions
- **Spam Prevention** - SpamAssassin configuration and training
- **Relay Controls** - Preventing your server from becoming an open relay

### Service Integration

Each component must be properly configured to work with the others:
- Postfix must authenticate against Dovecot (SASL)
- Dovecot must know where mail is stored (Maildir format)
- Procmail must integrate with Postfix for message filtering
- SpamAssassin must integrate with Procmail for spam detection
- Apache must proxy/serve Roundcube which connects to Dovecot
- Fetchmail must deliver to Postfix which delivers to local mailboxes
- All services must use consistent SSL certificates

### Configuration Complexity

Each component has:
- Multiple configuration files (Dovecot alone has dozens)
- Hundreds of configuration options
- Complex interactions between options
- Security implications for nearly every setting
- Performance tuning considerations

This is why many people choose hosted solutions - the complexity is real and significant.

## Components Covered

### Core Mail Services

**Postfix** - The Mail Transfer Agent (MTA) that handles SMTP for both receiving mail from the internet and sending mail out. Postfix is known for security and ease of configuration compared to older MTAs like Sendmail.

**Dovecot** - The IMAP/POP3 server that allows mail clients to retrieve and manage mail. Dovecot also provides SASL authentication services for Postfix.

**Fetchmail** - Retrieves mail from external POP3/IMAP accounts and delivers it to the local mail system. Useful for consolidating mail from multiple accounts.

### Filtering and Security

**Procmail** - A powerful mail filtering and processing tool that can automatically sort, forward, or process incoming mail based on complex rules.

**SpamAssassin** - A sophisticated spam detection system using multiple techniques including Bayesian filtering, network tests, and heuristic rules.

### Web Services

**Apache HTTP Server** - Web server configured with SSL/TLS to securely serve the webmail interface.

**Roundcube** - A modern, feature-rich webmail client written in PHP that provides browser-based access to mail via IMAP.

### Supporting Infrastructure

**OpenSSL** - For generating and managing SSL/TLS certificates for encrypted communication.

**MySQL** - Database backend for Roundcube to store user preferences, contacts, and other data.

## Building the Documentation

This documentation is written in **DocBook 5 XML**, an industry-standard format for technical documentation. DocBook allows generating multiple output formats (HTML, PDF, EPUB) from a single source.

### Prerequisites

To build the documentation, you need:

- **xsltproc** - XSLT processor for transforming XML to HTML
- **DocBook XSL Stylesheets** - Standard stylesheets for DocBook transformation
- **Apache FOP** - For PDF generation (optional)
- **dbtoepub** - For EPUB generation (optional)
- **tidy** - HTML tidying utility (optional but recommended)

#### Installing on macOS

```bash
# Core requirements
brew install docbook-xsl libxslt

# Optional for PDF generation
brew install fop

# Set DocBook catalog (may be needed)
export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
```

#### Installing on Linux (OpenSuSE/SUSE)

```bash
# Core requirements
zypper install docbook-xsl-stylesheets libxslt-tools

# Optional for PDF generation
zypper install fop

# Optional for EPUB
zypper install dbtoepub
```

### Build Targets

The original project used **Phing** (PHP-based build system). For accessibility, a Makefile is now provided:

```bash
# Generate single-page HTML (default)
make html

# Generate chunked HTML (one file per section)
make chunk

# Generate PDF (requires Apache FOP)
make pdf

# Generate EPUB
make epub

# Generate all formats
make all

# Clean generated files
make clean

# Validate XML against DocBook schema
make validate

# Check for required build tools
make check-tools
```

**Note on macOS**: The XSL stylesheet files use canonical DocBook URIs (e.g., `http://docbook.sourceforge.net/release/xsl/current/`) which are resolved to local files via XML catalogs. When you install DocBook XSL via Homebrew, it automatically configures the catalog at `/usr/local/etc/xml/catalog`. The `xsltproc` tool uses this catalog to map URIs to the actual installed files, making the stylesheets portable across different systems.

### Output Locations

Generated documentation appears in the `output/` directory:
- `output/html/index.html` - Single page HTML
- `output/chunkhtml/` - Chunked HTML output
- `output/pdf/article.pdf` - PDF version
- `output/epub/mailsetup-article.epub` - EPUB version

## Project Structure

```
.
├── README.md                          # This file
├── Makefile                           # Build automation
├── build.xml                          # Original Phing build script (legacy)
├── mailsetup.xpr                      # Oxygen XML Editor project file (optional)
├── mailsetup-article.xml              # Main document entry point
├── section01.xml - section11.xml      # Document sections
├── appendix01-postfix-examples.xml    # Configuration examples appendix
├── appendix02-procmail.xml            # Procmail configuration
├── appendix03-dovecot.xml             # Dovecot configuration
├── appendix04-postfix-complete.xml    # Complete postfix config
├── appendix05-openssl.xml             # OpenSSL examples
├── appendix06-apache.xml              # Apache configuration
├── xsl_stylesheets/                   # Custom XSL transformations
│   ├── html.xsl                       # HTML output customization
│   ├── chunk.xsl                      # Chunked HTML customization
│   ├── fo.xsl                         # PDF (FO) customization
│   └── epub.xsl                       # EPUB customization
├── css_stylesheets/                   # CSS styling for HTML output
│   ├── article.css
│   └── article-fancyterm.css
├── figures/                           # Images and diagrams
└── output/                            # Generated documentation (gitignored)
```

### DocBook Structure

The documentation uses **DocBook 5** with XInclude for modularity:
- `mailsetup-article.xml` - Root document that includes all sections
- `section*.xml` - Individual sections for each component
- `appendix*.xml` - Detailed configuration examples
- Custom XSL stylesheets customize the DocBook output appearance

**Note**: The `mailsetup.xpr` file is an Oxygen XML Editor project file from the original development environment. It's not required for building the documentation but is preserved to show the original editing workflow. You can safely ignore it if you're not using Oxygen XML Editor.

## Historical Context

### When This Was Written (2010-2012)

This guide was created during an era when:
- OpenSuSE was actively developed by Novell
- Dovecot 2.x was relatively new
- SSL/TLS was transitioning from SSL 3.0 to TLS 1.0/1.1
- Self-signed certificates were more commonly used
- SpamAssassin was the dominant spam filtering solution
- Webmail clients like Roundcube were gaining popularity
- The "maildir" format was becoming standard over mbox

### What Has Changed Since

Several aspects have evolved since this guide was written:

**Security**:
- TLS 1.2 and 1.3 are now standard; TLS 1.0/1.1 are deprecated
- Let's Encrypt provides free, automated certificate management
- Self-signed certificates are discouraged for public-facing services

**Software**:
- Configuration file formats and locations may have changed
- New security options and features have been added
- Some recommended practices have been superseded

**Infrastructure**:
- IPv6 has become more common
- DKIM, SPF, and DMARC are now essential for deliverability
- Modern spam filtering often includes machine learning approaches

### Why Preserve This?

Despite its age, this document has enduring value:

1. **Educational Resource** - Comprehensive explanation of mail server architecture
2. **Historical Reference** - Documents how things were done in the early 2010s
3. **Conceptual Foundation** - Core concepts remain valid even as specifics change
4. **Detailed Methodology** - Example of thorough technical documentation
5. **Starting Point** - Can be adapted for modern systems with appropriate updates

## License

Copyright (c) 2010-2012 Johan Persson

This documentation is provided as-is for educational and reference purposes. While originally copyrighted, it is being shared publicly as a historical and educational resource.

## Contributing

As this is an **archival project**, it is **not accepting updates** to the technical content. The goal is to preserve the document as it was, representing a snapshot of mail server configuration practices from 2010-2012.

However, you may:
- **Report issues** with the build process or documentation generation
- **Submit corrections** for obvious typos or broken build scripts
- **Add supplementary material** noting how things have changed (in separate documents)

For modern mail server setup, consider consulting current documentation for:
- Postfix: http://www.postfix.org/documentation.html
- Dovecot: https://doc.dovecot.org/
- Let's Encrypt: https://letsencrypt.org/
- Modern anti-spam: rspamd.com

---

**Remember**: This is a historical document. While the concepts are sound, always consult current best practices and security guidelines when setting up production mail servers in 2026.
