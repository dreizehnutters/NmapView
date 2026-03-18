# NmapView

![License](https://img.shields.io/github/license/dreizehnutters/NmapView)

NmapView turns raw Nmap XML into a single, portable HTML report — no backend, no database, just one file you can open, share, or archive.

Nmaps XML data is powerful but difficult to explore at scale. Large scans quickly become hard to navigate, summarise, and share. NmapView focuses on turning that raw output into something analysts can actually work with.

> This software must not be used by military or secret service organisations.

## Why Use It

- No pipeline needed - works directly from standard Nmap XML
- One file output - easy to share, archive, or attach to reports
- Adds search, sorting, and export through DataTables
- Detailed views for web services, certificates, CPEs, Vulners links, and service inventory
- Keeps the end-user path simple: download one XSL file and run `xsltproc`


## Quick Start

Download the latest standalone stylesheet from GitHub Releases and render a report:

```bash
curl -fsSL -o nmap2html.xsl https://github.com/dreizehnutters/NmapView/releases/latest/download/nmap2html-standalone.xsl
xsltproc -o report.html nmap2html.xsl nmap-scan.xml
```

For best results, include service detection, OS detection, and relevant scripts during nmap scans

```bash
nmap -sV -O --script="default,vulners,http-headers,ssl-cert,banner" -oX nmap-scan.xml <target>
```

## Generated Report

[![Report Screenshot](./sample/output.gif)](./samples/report.html)


The generated report includes:

- interactive host and service tables
- CSV, Excel, PDF, JSON, and clipboard export
- service inventory and distribution views
- web service URLs and HTTP titles
- certificate metadata and weak-TLS indicators
- per-host deep-dive sections with script output and linked findings

## Typical Use Cases

- Internal network assessments
- Pentest reporting
- Asset/service inventory generation
- Sharing scan results with non-technical stakeholders

## What The Report Covers

- `Scanned Hosts`: online state, OS guess, MAC/vendor, hostnames, and open port counts
- `Open Services`: flat searchable service inventory with versions, CPEs, and Vulners/script findings
- `Web/SSL Services`: URLs, titles, redirects, and certificate metadata
- `Service Inventory`: grouped service prevalence by host and port
- `Online Hosts`: per-host accordion with open ports, service details, and script output
- `Charts`: service distribution and communication/service heatmaps

## Requirements

- `xsltproc` to render the report
- Nmap XML input created with `-oX`
- Internet access in the browser for CDN-hosted JS/CSS assets used by the report UI

No Python / Node / backend required

## For Contributors

PRs are welcome

- `xsl/`: split XSL source
- `tools/build_xsl.py`: build the standalone stylesheet from source

## Feedback

If the project is useful, star it - open issues for bugs or feature requests.
