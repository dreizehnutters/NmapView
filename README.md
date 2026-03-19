# NmapView

[![Latest Release](https://img.shields.io/github/v/release/dreizehnutters/NmapView?label=latest%20release)](https://github.com/dreizehnutters/NmapView/releases/latest/download/nmap2html-standalone.xsl)
[![Download Standalone XSL](https://img.shields.io/badge/download-standalone%20XSL-0d6efd)](https://github.com/dreizehnutters/NmapView/releases/latest/download/nmap2html-standalone.xsl)

NmapView turns raw Nmap XML into a single, portable HTML report - no backend, no database, just one file you can open, share, or archive.

Use it to turn scan output into something you can triage faster, share with a client or internal team, and archive as a clean assessment artifact.

[![Report Screenshot](./.github/assets/sample.gif)](https://möbius.band/report.html)

## Quick Start

Download the latest standalone stylesheet, render your XML, and open the report:

```bash
curl -fsSL -o nmap2html.xsl https://github.com/dreizehnutters/NmapView/releases/latest/download/nmap2html-standalone.xsl
xsltproc -o NmapView-Report.html nmap2html.xsl nmap-scan.xml
```

For best results, include service detection, OS detection, and relevant scripts during nmap scans

```bash
nmap -sV -O --script="default,vulners,http-headers,ssl-cert,banner" -oX nmap-scan.xml <target>
```

## Why Security Teams Use It

- Turn raw scan data into a report that is easier to review during assessments
- Instantly move from XML to something you can hand to a client, engineer, or stakeholder
- Search, sort, filter, and export findings without building a pipeline
- Review services, TLS, certificates, CPEs, ports, and host details in one place
- Keep output portable: one HTML file, no backend, no database

## What's In The Report

NmapView turns raw Nmap XML into a report you can actually work with during an assessment.

- Host Overview for quick asset triage across host state, OS guesses, vendors, hostnames, and open TCP/UDP port counts
- Service Overview for cross-host service review with versions, extra info, CPEs, and Vulners-linked exploit context
- Service Inventory to spot repeated exposure patterns by grouping services by name, port, and host
- Web & TLS Services with clickable URLs, HTTP titles, redirects, and certificate subject, issuer, expiry, and signature details
- Visualizations including service distribution, open ports per host, host-port matrix, and service-port heatmap
- Host Details with per-host ports, scripts, service fingerprints, and OS detection output
- Searchable & sortable tables with export to CSV, Excel, PDF, and JSON
- Dynamic keyword highlighting
- One clean and portable HTML file that is easy to share, archive, and drop into reporting workflows

## Requirements

- `xsltproc` to transform XML to HTML

No Python, Node, or backend required.

## Typical Use Cases

- Internal network assessments
- Pentest reporting
- Asset and service inventory generation
- Sharing scan results with non-technical stakeholders
- Reviewing large scans without digging through raw XML

## For Contributors

PRs are welcome.

- `xsl/`: split XSL source
- `tools/build_xsl.py`: build the standalone stylesheet from source

## Feedback

If the project is useful, star it. Open an issue for bugs, UX friction, or feature requests.

## Acknowledgment & Credits

Many thanks to the following individuals:

- [honze-net](https://github.com/honze-net) for [nmap-bootstrap-xsl](https://github.com/honze-net/nmap-bootstrap-xsl)
- [Haxxnet](https://github.com/Haxxnet) for [nmap-bootstrap-xsl](https://github.com/Haxxnet/nmap-bootstrap-xsl)
