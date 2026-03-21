<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-head">
      <head>
        <meta name="referrer" content="no-referrer"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.css" rel="stylesheet" crossorigin="anonymous"/>
        <script src="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.js" crossorigin="anonymous"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.20/pdfmake.min.js" crossorigin="anonymous"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.20/vfs_fonts.js" crossorigin="anonymous"/>
        <script src="https://cdn.plot.ly/plotly-3.3.0.min.js" crossorigin="anonymous"></script>
        <style>
          a {
            text-decoration: none !important;
          }
          ul#topServicesLedger {
            list-style: none;
            padding: 0;
            max-width: 400px;
            margin-top: 2rem;
            font-family: Arial, sans-serif;
          }

          ul#topServicesLedger li {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 10px 15px;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 16px;
            gap: 3rem;
          }

          ul#topServicesLedger .badge {
            background-color: #007bff;
            color: white;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 14px;
          }

          .host-list {
            display: grid;
            gap: 1rem;
          }

          .host-entry {
            border: 1px solid #dee2e6;
            border-radius: 0.5rem;
            background: #fff;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            overflow: hidden;
          }

          .host-entry-summary {
            cursor: pointer;
            list-style: none;
            padding: 1rem 1.25rem;
            background: #f8f9fa;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.75rem;
          }

          .host-entry-summary::-webkit-details-marker {
            display: none;
          }

          .host-entry-summary::before {
            content: "+";
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.5rem;
            height: 1.5rem;
            border-radius: 999px;
            background: #0d6efd;
            color: #fff;
            font-weight: 700;
            flex: 0 0 auto;
          }

          .host-entry[open] .host-entry-summary::before {
            content: "-";
          }

          .host-entry-anchor {
            display: block;
            position: relative;
            top: -4rem;
            visibility: hidden;
            width: 0;
            height: 0;
          }

          .host-entry-label {
            flex: 1 1 auto;
          }

          .host-entry-body {
            padding: 1.25rem;
          }

          .certificate-block {
            display: grid;
            gap: 0.2rem;
            max-width: 20rem;
          }

          .certificate-row {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.3;
          }

          .certificate-label {
            font-weight: 600;
          }

          .certificate-value {
            display: inline;
          }

          .http-title-block {
            max-width: 20rem;
          }

          .http-title-value {
            display: block;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .web-http-column {
            min-width: 22rem;
          }

          .web-cert-column {
            min-width: 16rem;
          }

          .http-details-block {
            display: grid;
            gap: 0.2rem;
            max-width: 26rem;
          }

          .summary-command {
            margin: 1rem 0 0;
            border: 1px solid #dee2e6;
            border-radius: 0.5rem;
            background: rgba(255, 255, 255, 0.65);
          }

          .summary-command summary {
            cursor: pointer;
            padding: 0.75rem 1rem;
            color: #6c757d;
            font-size: 0.95rem;
            font-weight: 600;
          }

          .summary-command pre {
            margin: 0;
            padding: 0 1rem 1rem;
            font-size: 0.9rem;
            background: transparent;
            border: 0;
            color: #495057;
            white-space: pre-wrap;
            word-wrap: break-word;
          }

          .summary-progress {
            height: 1.75rem;
            font-size: 0.95rem;
          }

          .summary-progress .progress-bar {
            font-weight: 600;
          }

          .summary-progress .progress-bar.bg-warning {
            color: #212529;
          }

          .vulners-summary {
            cursor: pointer;
            color: #495057;
            font-weight: 600;
          }

          .vulners-summary::-webkit-details-marker {
            display: none;
          }

          .vulners-list {
            margin-top: 0.5rem;
          }

          .host-vuln-badge {
            min-width: 2.5rem;
            display: inline-flex;
            justify-content: center;
          }

          .cpe-copy {
            cursor: copy;
          }

          .cpe-copy.copied {
            color: #0a58ca !important;
          }

          .keyword-highlight-controls {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            align-items: center;
            margin-top: 1rem;
          }

          .keyword-highlight-controls .form-control {
            flex: 1 1 20rem;
            min-width: 16rem;
          }

          .keyword-highlight-controls .btn-warning {
            background-color: #e9ecef;
            border-color: #ced4da;
            color: #212529;
          }

          .keyword-highlight-controls .btn-warning:hover,
          .keyword-highlight-controls .btn-warning:focus,
          .keyword-highlight-controls .btn-warning:active {
            background-color: #dde1e5;
            border-color: #c6cbd1;
            color: #212529;
          }

          .keyword-highlight-mark {
            background: #fff3a3;
            color: inherit;
            padding: 0 0.15em;
            border-radius: 0.2rem;
          }

          #mainNavbar {
            border-bottom: 1px solid #dee2e6;
          }

          #summary,
          #scannedhosts,
          #openservices,
          #serviceinventory,
          #webservices,
          #visualizations,
          #onlinehosts {
            scroll-margin-top: 5.5rem;
          }

          .navbar-version-link {
            display: flex;
            align-items: center;
            height: 100%;
          }

          #navbarNav {
            width: 100%;
          }

          #navbarToggle {
            margin-left: auto;
          }

          @media (max-width: 991.98px) {
            #navbarNav {
              padding-top: 0.75rem;
            }

            #navbarNav .navbar-nav {
              gap: 0.25rem;
            }
          }

          @media (min-width: 992px) {
            #navbarNav {
              display: flex !important;
              align-items: center;
              justify-content: space-between;
            }
          }

        </style>
        <title>NmapView Report - Interactive Nmap Scan Summary</title>
      </head>
  </xsl:template>
  <xsl:template name="render-navbar">
        <nav id="mainNavbar" class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
          <div class="container-fluid">
            <button class="navbar-toggler" type="button" id="navbarToggle" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
              <span class="navbar-toggler-icon"/>
            </button>
            <div id="navbarNav" hidden="hidden">
              <ul class="navbar-nav me-auto">
                <li class="nav-item">
                  <a class="nav-link" href="#summary">Summary</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#scannedhosts">Host Overview</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#openservices">Open Services</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#serviceinventory">Service Summary</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#webservices">Web &amp; TLS Services</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#visualizations">Visualizations</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#onlinehosts">Host Details</a>
                </li>
              </ul>
              <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                  <a class="nav-link navbar-version-link" href="https://github.com/dreizehnutters/NmapView">NmapView v3.2</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="https://github.com/dreizehnutters/NmapView">
                    <svg height="100" width="100" viewbox="0 0 100 100" style="max-height: 42px; width: auto;">
                      <line x1="50" x2="50" y2="33" y1="0" stroke-width="3" stroke="#808080"/>
                      <line x1="25" x2="25" y2="66" y1="33" stroke-width="3" stroke="#808080"/>
                      <line x1="75" x2="75" y2="66" y1="33" stroke-width="3" stroke="#808080"/>
                      <line x1="2" x2="2" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                      <line x1="47" x2="47" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                      <line x1="53" x2="53" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                      <line x1="98" x2="98" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                    </svg>
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </nav>
  </xsl:template>
  <xsl:template name="render-summary">
          <xsl:variable name="total-hosts" select="count(/nmaprun/host)"/>
          <xsl:variable name="up-hosts" select="count(/nmaprun/host[status/@state='up'])"/>
          <xsl:variable name="down-hosts" select="count(/nmaprun/host[status/@state='down'])"/>
          <xsl:variable name="open-ports" select="count(/nmaprun/host/ports/port[state/@state='open'])"/>
          <xsl:variable name="unique-services" select="count(//host/ports/port[state/@state='open' and service/@name]
            [generate-id() = generate-id(
              key('serviceGroup',
                concat(
                  substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),
                  service/@name,
                  '-',
                  @protocol
                )
              )[1]
            )])"/>
          <xsl:variable name="web-tls-endpoints" select="count(/nmaprun/host/ports/port[(@protocol='tcp') and (state/@state='open') and (starts-with(service/@name, 'http') or script[@id='ssl-cert'])])"/>
          <xsl:variable name="duration-seconds" select="number(/nmaprun/runstats/finished/@time) - number(/nmaprun/@start)"/>
          <xsl:variable name="duration-hours" select="floor($duration-seconds div 3600)"/>
          <xsl:variable name="duration-minutes" select="floor(($duration-seconds mod 3600) div 60)"/>
          <xsl:variable name="duration-remainder-seconds" select="floor($duration-seconds mod 60)"/>
          <div id="summary" class="bg-light p-4 rounded my-5 shadow-sm">
            <h2 class="display-6 text-primary">Scan Summary</h2>
            <h5 class="mb-3">
              <small class="text-muted">
                Nmap Version: <xsl:value-of select="/nmaprun/@version"/> <br/>
                Scan Duration: <xsl:value-of select="/nmaprun/@startstr"/> - <xsl:value-of select="/nmaprun/runstats/finished/@timestr"/>
                <xsl:text> (</xsl:text>
                <xsl:if test="$duration-hours &gt; 0">
                  <xsl:value-of select="$duration-hours"/>
                  <xsl:text>h </xsl:text>
                </xsl:if>
                <xsl:if test="$duration-minutes &gt; 0 or $duration-hours &gt; 0">
                  <xsl:value-of select="$duration-minutes"/>
                  <xsl:text>m </xsl:text>
                </xsl:if>
                <xsl:value-of select="$duration-remainder-seconds"/>
                <xsl:text>s)</xsl:text>
              </small>
            </h5>
            <div class="row g-3 mb-4">
              <div class="col-6 col-lg-3">
                <div class="border rounded bg-white h-100 p-3">
                  <div class="text-muted small text-uppercase">Hosts Scanned</div>
                  <div class="fs-4 fw-semibold">
                    <xsl:value-of select="$total-hosts"/>
                  </div>
                </div>
              </div>
              <div class="col-6 col-lg-3">
                <div class="border rounded bg-white h-100 p-3">
                  <div class="text-muted small text-uppercase">Open Ports</div>
                  <div class="fs-4 fw-semibold">
                    <xsl:value-of select="$open-ports"/>
                  </div>
                </div>
              </div>
              <div class="col-6 col-lg-3">
                <div class="border rounded bg-white h-100 p-3">
                  <div class="text-muted small text-uppercase">Unique Services</div>
                  <div class="fs-4 fw-semibold">
                    <xsl:value-of select="$unique-services"/>
                  </div>
                </div>
              </div>
              <div class="col-6 col-lg-3">
                <div class="border rounded bg-white h-100 p-3">
                  <div class="text-muted small text-uppercase">Web/TLS Endpoints</div>
                  <div class="fs-4 fw-semibold">
                    <xsl:value-of select="$web-tls-endpoints"/>
                  </div>
                </div>
              </div>
            </div>
            <div class="progress summary-progress">
              <div class="progress-bar bg-success" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <xsl:attribute name="style">
                  <xsl:text>width:</xsl:text>
                  <xsl:choose>
                    <xsl:when test="$total-hosts &gt; 0">
                      <xsl:value-of select="$up-hosts div $total-hosts * 100"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>%;</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$up-hosts"/> Hosts up
              </div>
              <div class="progress-bar bg-warning" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <xsl:attribute name="style">
                  <xsl:text>width:</xsl:text>
                  <xsl:choose>
                    <xsl:when test="$total-hosts &gt; 0">
                      <xsl:value-of select="$down-hosts div $total-hosts * 100"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>%;</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$down-hosts"/> Hosts down
              </div>
            </div>
            <details class="summary-command">
              <summary>Show Nmap command</summary>
              <pre>
                <xsl:attribute name="text">
                  <xsl:value-of select="/nmaprun/@args"/>
                </xsl:attribute>
                <xsl:value-of select="/nmaprun/@args"/>
              </pre>
            </details>
            <div class="keyword-highlight-controls" aria-label="Keyword highlighter">
              <input
                type="text"
                id="keywordHighlightInput"
                class="form-control"
                placeholder="sha1, login, password, md5"
                aria-label="Comma-separated keywords to highlight"
              />
              <button type="button" class="btn btn-warning" id="highlightKeywordsButton">Highlight Keywords</button>
              <button type="button" class="btn btn-outline-secondary" id="resetHighlightsButton">Reset</button>
            </div>
          </div>
  </xsl:template>
  <xsl:template name="render-footer">
        <hr class="my-3"/>
        <footer class="footer bg-light py-3">
          <div class="container">
            <p class="text-muted mb-0 text-center">
              Generated with <a href="https://github.com/dreizehnutters/NmapView">NmapView</a></p>
          </div>
        </footer>
  </xsl:template>
  <xsl:template name="render-scripts">
        <script><![CDATA[
          function appendText(parent, text) {
            parent.appendChild(document.createTextNode(text));
          }

          function clamp(value, min, max) {
            return Math.max(min, Math.min(max, value));
          }

          function getDynamicTileSize(columns, rows, options = {}) {
            const maxWidth = options.maxWidth || Math.max(window.innerWidth - 220, 720);
            const maxHeight = options.maxHeight || Math.max(window.innerHeight * 0.7, 520);
            const minSize = options.minSize || 12;
            const maxSize = options.maxSize || 36;

            if (!columns || !rows) {
              return maxSize;
            }

            const widthLimited = Math.floor(maxWidth / columns);
            const heightLimited = Math.floor(maxHeight / rows);
            return clamp(Math.min(widthLimited, heightLimited), minSize, maxSize);
          }

          function truncateLabel(text, maxLength = 42) {
            if (!text || text.length <= maxLength) {
              return text;
            }
            return `${text.slice(0, maxLength - 1)}…`;
          }

          async function copyTextToClipboard(text) {
            if (navigator.clipboard && window.isSecureContext) {
              await navigator.clipboard.writeText(text);
              return;
            }

            const input = document.createElement("textarea");
            input.value = text;
            input.setAttribute("readonly", "");
            input.style.position = "absolute";
            input.style.left = "-9999px";
            document.body.appendChild(input);
            input.select();
            document.execCommand("copy");
            document.body.removeChild(input);
          }

          function initializeCpeCopy() {
            document.querySelectorAll(".cpe-copy").forEach(element => {
              element.addEventListener("click", async () => {
                const cpe = element.getAttribute("data-cpe");
                if (!cpe) return;

                try {
                  await copyTextToClipboard(cpe);
                  const previousTitle = element.getAttribute("title") || "";
                  element.setAttribute("title", "Copied");
                  element.classList.add("copied");
                  window.setTimeout(() => {
                    element.setAttribute("title", previousTitle || "Click to copy CPE");
                    element.classList.remove("copied");
                  }, 1200);
                } catch (error) {
                  element.setAttribute("title", "Copy failed");
                  window.setTimeout(() => {
                    element.setAttribute("title", "Click to copy CPE");
                  }, 1200);
                }
              });
            });
          }

          function renderTopServices(sortedServices) {
            const ledger = document.getElementById("topServicesLedger");
            if (!ledger) return;

            ledger.textContent = "";
            sortedServices.slice(0, 5).forEach(([service, count]) => {
              const listItem = document.createElement("li");
              const title = document.createElement("strong");
              const badge = document.createElement("span");

              title.textContent = service;
              badge.className = "badge";
              badge.textContent = String(count);

              listItem.appendChild(title);
              listItem.appendChild(badge);
              ledger.appendChild(listItem);
            });
          }

          function formatVulnersChunks() {
            document.querySelectorAll(".vulners-chunks").forEach(container => {
              const raw = container.getAttribute("data-raw") || "";
              if (!raw.trim()) {
                return;
              }

              const cleaned = raw.replace(/\r\n/g, "\n").trim();
              const lines = cleaned
                .split("\n")
                .map(line => line.trim())
                .filter(Boolean);
              const entries = [];

              lines.forEach(line => {
                if (!line.includes("\t")) {
                  return;
                }

                const parts = line.split("\t").map(part => part.trim()).filter(Boolean);
                if (parts.length < 3) {
                  return;
                }

                const [id, score, url] = parts;
                if (!id || !score || !url) {
                  return;
                }

                const urlMatch = url.match(/^https:\/\/vulners\.com\/([^/]+)\/(.+)$/);
                if (!urlMatch) {
                  return;
                }

                entries.push({
                  id,
                  score: Number(score),
                  scoreText: score,
                  href: url
                });
              });

              container.textContent = "";
              if (entries.length > 0) {
                entries.sort((a, b) => b.score - a.score || a.id.localeCompare(b.id, undefined, {
                  numeric: true,
                  sensitivity: "base"
                }));
                const visibleEntries = entries.slice(0, 5);

                const details = document.createElement("details");
                const summary = document.createElement("summary");
                const list = document.createElement("div");

                details.className = "vulners-details";
                summary.className = "vulners-summary";
                list.className = "vulners-list";

                const findingLabel = entries.length === 1 ? "finding" : "findings";
                summary.textContent = `${entries.length} ${findingLabel}, top CVSS ${entries[0].scoreText}`;

                visibleEntries.forEach(entry => {
                  const wrapper = document.createElement("div");
                  const label = document.createElement("strong");
                  const link = document.createElement("a");

                  wrapper.style.marginBottom = "0.5em";
                  label.textContent = `CVSS: ${entry.scoreText}`;
                  link.href = entry.href;
                  link.target = "_blank";
                  link.rel = "noopener noreferrer";
                  link.textContent = entry.id;

                  wrapper.appendChild(label);
                  appendText(wrapper, " - ");
                  wrapper.appendChild(link);
                  list.appendChild(wrapper);
                });

                if (entries.length > visibleEntries.length) {
                  const more = document.createElement("div");
                  more.style.color = "#6c757d";
                  more.textContent = `Showing top ${visibleEntries.length} of ${entries.length} findings`;
                  list.appendChild(more);
                }

                details.appendChild(summary);
                details.appendChild(list);
                container.appendChild(details);
                return;
              }

              const emptyState = document.createElement("em");
              emptyState.style.color = "#999";
              emptyState.textContent = "No valid Vulners links found";
              container.appendChild(emptyState);
            });
          }

          function formatInventoryLists() {
            document.querySelectorAll("td.port-list").forEach(td => {
              const raw = td.getAttribute("data-ports");
              if (!raw) return;

              const ports = raw.split(",").map(port => port.trim());
              const uniquePorts = [...new Set(ports)].sort((a, b) => Number(a) - Number(b));
              const container = td.querySelector(".display-ports");
              if (container) {
                container.textContent = uniquePorts.join(", ");
              }
            });

            document.querySelectorAll("td.host-list").forEach(td => {
              const raw = td.getAttribute("data-hosts");
              if (!raw) return;

              const hosts = raw.split(",").map(host => host.trim());
              const uniqueHosts = [...new Set(hosts)];
              const container = td.querySelector(".display-hosts");
              if (!container) return;

              container.textContent = "";
              uniqueHosts.forEach((ip, index) => {
                if (index > 0) {
                  appendText(container, ", ");
                }

                const anchor = document.createElement("a");
                anchor.href = `#onlinehosts-${ip.replace(/[.:]/g, "-")}`;
                anchor.textContent = ip;
                container.appendChild(anchor);
              });
            });
          }

          function initializeNavbarToggle() {
            const toggle = document.getElementById("navbarToggle");
            const menu = document.getElementById("navbarNav");
            if (!toggle || !menu) return;

            function syncNavbar() {
              if (window.innerWidth >= 992) {
                menu.hidden = false;
                toggle.setAttribute("aria-expanded", "true");
                return;
              }

              const expanded = toggle.getAttribute("aria-expanded") === "true";
              menu.hidden = !expanded;
            }

            toggle.addEventListener("click", () => {
              const expanded = toggle.getAttribute("aria-expanded") === "true";
              toggle.setAttribute("aria-expanded", expanded ? "false" : "true");
              menu.hidden = expanded;
            });

            window.addEventListener("resize", syncNavbar);
            syncNavbar();
          }

          function openLinkedHost(hash) {
            if (!hash || !hash.startsWith("#onlinehosts-")) {
              return null;
            }

            const target = document.querySelector(hash);
            if (!target) {
              return null;
            }

            const hostEntry = target.closest("details");
            if (hostEntry) {
              hostEntry.open = true;
            }

            return target;
          }

          function initializeHostToggle() {
            const toggle = document.getElementById("toggle-all-hosts");
            const hostList = document.getElementById("onlinehosts-list");
            if (!toggle || !hostList) return;

            const hostEntries = Array.from(hostList.querySelectorAll("details.host-entry"));
            if (hostEntries.length === 0) {
              toggle.hidden = true;
              return;
            }

            function syncLabel() {
              const allOpen = hostEntries.every(entry => entry.open);
              toggle.textContent = allOpen ? "Collapse all" : "Expand all";
              toggle.setAttribute("aria-expanded", allOpen ? "true" : "false");
            }

            toggle.addEventListener("click", () => {
              const shouldOpen = !hostEntries.every(entry => entry.open);
              hostEntries.forEach(entry => {
                entry.open = shouldOpen;
              });
              syncLabel();
            });

            hostEntries.forEach(entry => {
              entry.addEventListener("toggle", syncLabel);
            });

            syncLabel();
          }

          function initializeDataTable(selector) {
            const exportNames = {
              "#table-services": "nmapview-open-services",
              "#table-overview": "nmapview-scanned-hosts",
              "#web-services": "nmapview-web-services",
              "#service-inventory": "nmapview-service-inventory"
            };
            const exportName = exportNames[selector] || "nmapview-table-export";
            const buttons = [
              {
                extend: 'copyHtml5',
                text: 'Copy',
                title: exportName,
                exportOptions: { orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'csvHtml5',
                text: 'CSV',
                filename: exportName,
                fieldSeparator: ';',
                exportOptions: { orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'excelHtml5',
                text: 'Excel',
                filename: exportName,
                autoFilter: true,
                exportOptions: { orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'pdfHtml5',
                text: 'PDF',
                filename: exportName,
                title: exportName,
                orientation: 'landscape',
                pageSize: 'LEGAL',
                download: 'open',
                exportOptions: {},
                className: 'btn btn-light'
              },
              {
                text: 'JSON',
                className: 'btn btn-light',
                action: function (e, dt, node, config) {
                  const headers = dt.columns().header().toArray().map(h => $(h).text().trim());

                  const data = dt.rows({ search: 'applied' }).nodes().toArray().map(row => {
                    const obj = {};
                    $(row).find('td').each(function (i) {
                      obj[headers[i]] = $(this).text().trim();
                    });
                    return obj;
                  });

                  const json = JSON.stringify(data, null, 2);
                  const blob = new Blob([json], { type: 'application/json' });
                  const url = URL.createObjectURL(blob);
                  const a = document.createElement('a');
                  a.href = url;
                  a.download = `${exportName}.json`;
                  a.click();
                  URL.revokeObjectURL(url);
                }
              }
            ];

            if (selector === '#web-services') {
              buttons.push({
                extend: 'copyHtml5',
                text: 'Copy URLs',
                header: false,
                title: exportName,
                exportOptions: {  columns: [-1], orthogonal: 'export' },
                className: 'btn btn-light'
              });
            }

            $(selector).DataTable({
              lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
              order: [[0, 'desc']],
              columnDefs: [
                { targets: [0], orderable: true },
                { targets: [1], type: 'ip-address' },
              ],
              dom: '<"d-flex justify-content-between align-items-center mb-2"lfB>rtip',
              stateSave: true,
              buttons: buttons
            });
          }

          function escapeRegex(text) {
            return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
          }

          function unwrapHighlight(node) {
            const parent = node.parentNode;
            if (!parent) return;

            while (node.firstChild) {
              parent.insertBefore(node.firstChild, node);
            }
            parent.removeChild(node);
          }

          function clearKeywordHighlights() {
            document.querySelectorAll("mark.keyword-highlight-mark").forEach(unwrapHighlight);
          }

          function parseHighlightTerms(raw) {
            return [...new Set(
              (raw || "")
                .split(",")
                .map(term => term.trim())
                .filter(Boolean)
            )];
          }

          function highlightTextNode(textNode, regex) {
            const text = textNode.nodeValue;
            if (!text || !regex.test(text)) {
              regex.lastIndex = 0;
              return 0;
            }

            regex.lastIndex = 0;
            const fragment = document.createDocumentFragment();
            let lastIndex = 0;
            let matchCount = 0;
            let match;

            while ((match = regex.exec(text)) !== null) {
              const matchText = match[0];
              const matchIndex = match.index;

              if (matchIndex > lastIndex) {
                fragment.appendChild(document.createTextNode(text.slice(lastIndex, matchIndex)));
              }

              const mark = document.createElement("mark");
              mark.className = "keyword-highlight-mark";
              mark.textContent = matchText;
              fragment.appendChild(mark);
              lastIndex = matchIndex + matchText.length;
              matchCount++;
            }

            if (lastIndex < text.length) {
              fragment.appendChild(document.createTextNode(text.slice(lastIndex)));
            }

            textNode.parentNode.replaceChild(fragment, textNode);
            regex.lastIndex = 0;
            return matchCount;
          }

          function highlightKeywords(rawTerms) {
            clearKeywordHighlights();

            const terms = parseHighlightTerms(rawTerms);
            if (terms.length === 0) {
              return 0;
            }

            const container = document.getElementById("reportContent");
            if (!container) {
              return 0;
            }

            const regex = new RegExp(`(${terms.map(escapeRegex).join("|")})`, "gi");
            const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, {
              acceptNode(node) {
                const parent = node.parentElement;
                if (!parent) return NodeFilter.FILTER_REJECT;

                if (parent.closest(".keyword-highlight-controls")) {
                  return NodeFilter.FILTER_REJECT;
                }

                const tagName = parent.tagName;
                if (["SCRIPT", "STYLE", "NOSCRIPT", "TEXTAREA", "INPUT", "MARK"].includes(tagName)) {
                  return NodeFilter.FILTER_REJECT;
                }

                if (!node.nodeValue || !node.nodeValue.trim()) {
                  return NodeFilter.FILTER_REJECT;
                }

                return NodeFilter.FILTER_ACCEPT;
              }
            });

            const textNodes = [];
            let currentNode;
            while ((currentNode = walker.nextNode())) {
              textNodes.push(currentNode);
            }

            let matchCount = 0;
            textNodes.forEach(node => {
              matchCount += highlightTextNode(node, regex);
            });

            if (matchCount > 0) {
              document.querySelectorAll("mark.keyword-highlight-mark").forEach(mark => {
                const hostEntry = mark.closest("details.host-entry");
                if (hostEntry) {
                  hostEntry.open = true;
                }
              });

              const firstMatch = document.querySelector("mark.keyword-highlight-mark");
              if (firstMatch) {
                firstMatch.scrollIntoView({ behavior: "smooth", block: "center" });
              }
            }

            return matchCount;
          }

          function initializeKeywordHighlighter() {
            const input = document.getElementById("keywordHighlightInput");
            const highlightButton = document.getElementById("highlightKeywordsButton");
            const resetButton = document.getElementById("resetHighlightsButton");
            if (!input || !highlightButton || !resetButton) return;

            highlightButton.addEventListener("click", () => {
              highlightKeywords(input.value);
            });

            resetButton.addEventListener("click", () => {
              clearKeywordHighlights();
              input.focus();
            });

            input.addEventListener("keydown", event => {
              if (event.key === "Enter") {
                event.preventDefault();
                highlightKeywords(input.value);
              }
            });
          }

        ]]></script>
        <script>
          $(document).ready(function() {
              initializeNavbarToggle();
              initializeHostToggle();
              initializeKeywordHighlighter();
              initializeCpeCopy();
              initializeDataTable('#table-services');
              initializeDataTable('#table-overview');
              initializeDataTable('#web-services');
              initializeDataTable('#service-inventory');


              $("a[href^='#onlinehosts-']").click(function(event) {
                  event.preventDefault();
                  const target = openLinkedHost(this.hash);
                  if (!target) {
                    return;
                  }
                  $('html,body').animate({
                      scrollTop: ($(target).offset().top - 60)
                  }, 500);
              });

              const initialTarget = openLinkedHost(window.location.hash);
              if (initialTarget) {
                $('html,body').scrollTop($(initialTarget).offset().top - 60);
              }
          });
        </script>
        <script>
           document.addEventListener("DOMContentLoaded", function() {
            const serviceCounts = {};

            document.querySelectorAll("#serviceCounts .service").forEach(el => {
                const service = el.getAttribute("data-service");
                const port = el.getAttribute("data-portid");
                const proto = el.getAttribute("data-porto");
                if (service &amp;&amp; port) {
                    const key = `${service} (${proto}/${port})`;
                    serviceCounts[key] = (serviceCounts[key] || 0) + 1;
                }
            });
            const sortedServices = Object.entries(serviceCounts).sort((a, b) => b[1] - a[1]);

            const colorPalette = [
                "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf",
                "#393b79", "#637939", "#8c6d31", "#843c39", "#7b4173",
                "#3182bd", "#f33", "#11b", "#fb0", "#0f0", "#999", "#05a"
            ];

            const traces = sortedServices.map(([service, count], index) =>
                ({
                    y: [''],
                    x: [count],
                    name: service,
                    type: 'bar',
                    orientation: 'h',
	                    marker: {
	                        color: colorPalette[index % colorPalette.length]
	                    },
	                    text: service,
	                    hovertext: `Service: ${service}; Hosts: ${count}`,
	                    textposition: 'inside',
	                    insidetextanchor: 'start',
	                    hoverinfo: 'text',
	                    textfont: {
	                        color: 'white',
	                        size: 12
                    }
                }));

            const layout = {
                title: '',
                barmode: 'stack',
                height: 250,
                xaxis: {
                    title: 'Frequency',
                    automargin: true,
                    fixedrange: true,
                    showticklabels: false,
                    showgrid: false
                },
                yaxis: {
                    automargin: true,
                    fixedrange: true,
                    showgrid: false
                },
                showlegend: false,
                margin: {
                    t: 40,
                    b: 80,
                    l: 50,
                    r: 30
                }
            };

            Plotly.newPlot('serviceChart', traces, layout, {
                displayModeBar: false,
                responsive: true
            });

            renderTopServices(sortedServices);
        });
        </script>
        <script>
          document.addEventListener("DOMContentLoaded", function() {
            formatVulnersChunks();
            formatInventoryLists();
          });
        </script>

        <script><![CDATA[
          document.addEventListener("DOMContentLoaded", function() {
            const hostDivs = document.querySelectorAll("#matrixCount .host");
            const hosts = [];
            const portsSet = new Set();
            const servicesSet = new Set();
            const openServices = {};

            hostDivs.forEach(hostDiv => {
              const host = hostDiv.getAttribute("data-host");
              hosts.push(host);
              openServices[host] = {};

              hostDiv.querySelectorAll("span.port").forEach(span => {
                const port = parseInt(span.getAttribute("data-port"), 10);
                const serviceName = span.getAttribute("data-service") || "";
                openServices[host][port] = serviceName;
                portsSet.add(port);
                servicesSet.add(serviceName);
              });
            });

            const ports = Array.from(portsSet).sort((a, b) => a - b);
            const matrixConfig = {
              displayModeBar: false,
              scrollZoom: false
            };

            const portHostMatrix = document.getElementById("portHostMatrix");
            if (portHostMatrix) {
              const sortedHosts = [...hosts].sort((a, b) => a.localeCompare(b, undefined, {
                numeric: true,
                sensitivity: "base"
              }));
              const tileSize = getDynamicTileSize(ports.length, sortedHosts.length, {
                minSize: 14,
                maxSize: 36
              });
              const z = sortedHosts.map(host =>
                ports.map(port => openServices[host][port] ? 1 : 0)
              );

	              const zText = sortedHosts.map(host =>
	                ports.map(port => openServices[host][port] || "")
	              );
	              const hoverData = sortedHosts.map(host =>
	                ports.map(port => [
	                  host,
	                  String(port),
	                  openServices[host][port] || "No open service"
	                ])
	              );

	              const data = [{
	                z: z,
	                x: ports.map(String),
	                y: sortedHosts,
	                text: zText,
	                customdata: hoverData,
	                type: "heatmap",
	                colorscale: [[0, "#f3f4f6"], [1, "#2ca02c"]],
	                showscale: false,
	                xgap: 2,
	                ygap: 2,
	                hoverongaps: false,
	                hovertemplate: "Host: %{customdata[0]}<br>Port: %{customdata[1]}<br>Service: %{customdata[2]}<extra></extra>",
	                text: zText
	              }];

              const dynamicHeight = Math.max(600, sortedHosts.length * tileSize + 160);
              const dynamicWidth = Math.max(900, ports.length * tileSize + 180);
              portHostMatrix.style.height = dynamicHeight + "px";
              portHostMatrix.style.width = dynamicWidth + "px";
              portHostMatrix.style.margin = "0 auto";

	            const layout = {
	              title: "",
                xaxis: {
                  title: { text: "Port" },
                  side: "top",
                  type: "category",
                  tickangle: -45,
                  automargin: true,
                  ticks: "outside",
                  ticklen: 10,
                  tickcolor: "rgba(0,0,0,0.05)",
                  tickwidth: 1
                },
                yaxis: {
                  title: { text: "Host" },
                  type: "category",
                  autorange: "reversed",
                  automargin: true,
                  ticks: "outside",
                  ticklen: 10,
                  tickcolor: "rgba(0,0,0,0.05)",
                  tickwidth: 1
                },
                margin: { t: 80, l: 120, r: 50, b: 100 },
                dragmode: false,
                width: dynamicWidth,
                height: dynamicHeight
              };

              Plotly.newPlot("portHostMatrix", data, layout, matrixConfig);
            }

            const protocolPortMatrix = document.getElementById("protocolPortMatrix");
            if (!protocolPortMatrix) {
              return;
            }

            const services = Array.from(servicesSet).sort();
            const z = services.map(service =>
              ports.map(port => {
                let count = 0;
                for (const host of hosts) {
                  if (openServices[host][port] === service) count++;
                }
                return count;
              })
            );

            const serviceTotals = z.map(row => row.reduce((a, b) => a + b, 0));
            const sortedIndices = serviceTotals
              .map((total, index) => ({ total, index }))
              .sort((a, b) => b.total - a.total)
              .map(item => item.index);

	            const sortedServices = sortedIndices.map(index => services[index]);
	            const sortedTotals = sortedIndices.map(index => serviceTotals[index]);
	            const sortedZ = sortedIndices.map(index => z[index]);
	            const heatmapTileSize = getDynamicTileSize(ports.length, sortedServices.length, {
	              minSize: 14,
	              maxSize: 36
	            });
	            const zText = sortedZ.map(row => row.map(value => value > 0 ? value.toString() : ""));
	            const hoverData = sortedServices.map((service, index) =>
	              ports.map(port => [String(port), service, String(sortedTotals[index])])
	            );
	            const yLabels = sortedServices.map((service, index) => `${service} (${sortedTotals[index]})`);

	            const data = [{
	              z: sortedZ,
	              x: ports.map(String),
	              y: yLabels,
	              text: zText,
	              customdata: hoverData,
	              type: "heatmap",
	              colorscale: "Portland",
	              showscale: true,
	              hoverongaps: false,
	              hovertemplate: "Port: %{customdata[0]}<br>Service: %{customdata[1]}<br>Total: %{customdata[2]}<br>Occurrences: %{z}<extra></extra>",
	              texttemplate: "%{text}",
	              textfont: { color: "black", size: 12 }
	            }];

            const dynamicHeight = Math.max(600, sortedServices.length * heatmapTileSize + 160);
            const dynamicWidth = Math.max(900, ports.length * heatmapTileSize + 260);
            protocolPortMatrix.style.height = dynamicHeight + "px";
            protocolPortMatrix.style.width = dynamicWidth + "px";
            protocolPortMatrix.style.margin = "0 auto";

            const layout = {
              title: "",
              xaxis: {
                title: { text: "Port" },
                side: "top",
                type: "category",
                tickangle: -45,
                automargin: true
              },
              yaxis: {
                title: { text: "Service" },
                automargin: true
              },
              margin: { t: 80, l: 200, r: 50, b: 100 },
              width: dynamicWidth,
              height: dynamicHeight,
              dragmode: false
	            };

	            Plotly.newPlot("protocolPortMatrix", data, layout, matrixConfig);

	            const openPortsPerHostChart = document.getElementById("openPortsPerHostChart");
	            if (openPortsPerHostChart) {
	              const hostOpenPortCounts = hosts
	                .map(host => ({
	                  host,
	                  tcp: Object.entries(openServices[host]).filter(([, service]) => service.startsWith("tcp:")).length,
	                  udp: Object.entries(openServices[host]).filter(([, service]) => service.startsWith("udp:")).length
	                }))
	                .map(entry => ({
                    ...entry,
                    total: entry.tcp + entry.udp
                  }))
	                .sort((a, b) => b.total - a.total || a.host.localeCompare(b.host));
                const truncatedHosts = hostOpenPortCounts.map(entry => truncateLabel(entry.host));

	              const data = [{
	                type: "bar",
	                orientation: "h",
	                y: truncatedHosts,
	                x: hostOpenPortCounts.map(entry => entry.udp),
	                text: hostOpenPortCounts.map(entry => entry.udp > 0 ? `UDP: ${entry.udp}` : ""),
	                textposition: "inside",
                  cliponaxis: false,
                  customdata: hostOpenPortCounts.map(entry => [entry.host, String(entry.tcp), String(entry.udp), String(entry.total)]),
	                marker: {
	                  color: "#f59f00",
                    line: {
	                      color: "#d17d00",
                      width: 1
                    }
	                },
                  textfont: {
                    color: "#ffffff"
                  },
	                hovertemplate: "%{customdata[0]}<br>TCP: %{customdata[1]}<br>UDP: %{customdata[2]}<br>Total: %{customdata[3]}<extra></extra>",
                  hoverlabel: {
                    bgcolor: "#6c757d",
                    bordercolor: "#495057",
                    font: {
                      color: "#ffffff"
                    }
                  }
	              }, {
	                type: "bar",
	                orientation: "h",
	                y: truncatedHosts,
	                x: hostOpenPortCounts.map(entry => entry.tcp),
	                text: hostOpenPortCounts.map(entry => entry.tcp > 0 ? `TCP: ${entry.tcp}` : ""),
	                textposition: "inside",
                  insidetextanchor: "end",
                  cliponaxis: false,
                  customdata: hostOpenPortCounts.map(entry => [entry.host, String(entry.tcp), String(entry.udp), String(entry.total)]),
	                marker: {
	                  color: "#0d6efd",
                    line: {
	                      color: "#0a58ca",
                      width: 1
                    }
	                },
                  textfont: {
                    color: "#ffffff"
                  },
	                hovertemplate: "%{customdata[0]}<br>TCP: %{customdata[1]}<br>UDP: %{customdata[2]}<br>Total: %{customdata[3]}<extra></extra>",
                  hoverlabel: {
                    bgcolor: "#6c757d",
                    bordercolor: "#495057",
                    font: {
                      color: "#ffffff"
                    }
                  }
	              }];

	              const dynamicHeight = Math.max(320, hostOpenPortCounts.length * 28);
                const dynamicWidth = Math.max(900, Math.min(window.innerWidth - 40, 1400));
	              openPortsPerHostChart.style.height = dynamicHeight + "px";
                openPortsPerHostChart.style.width = dynamicWidth + "px";
                openPortsPerHostChart.style.margin = "0 auto";

	              const layout = {
	                title: "",
	                margin: { t: 20, l: 220, r: 60, b: 50 },
	                width: dynamicWidth,
	                height: dynamicHeight,
	                xaxis: {
	                  title: { text: "Open ports" },
	                  automargin: true,
	                  fixedrange: true,
                    showgrid: true,
                    gridcolor: "rgba(0,0,0,0.08)",
                    gridwidth: 1,
                    zeroline: false,
                    rangemode: "tozero",
                    dtick: 1
	                },
	                yaxis: {
	                  title: { text: "Host" },
	                  automargin: true,
	                  fixedrange: true,
	                  autorange: "reversed"
	                },
	                barmode: "stack",
	                showlegend: false,
	                dragmode: false,
                  bargap: 0.2
	              };

	              Plotly.newPlot("openPortsPerHostChart", data, layout, matrixConfig);
	            }
	          });
	        ]]></script>

        <script>console.log("Made by dreizehnutters")</script>
  </xsl:template>
</xsl:stylesheet>
