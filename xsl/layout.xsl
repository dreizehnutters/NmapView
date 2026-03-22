<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-head">
      <head>
        <meta name="referrer" content="no-referrer"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.css" rel="stylesheet" crossorigin="anonymous"/>
        <script src="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.js" crossorigin="anonymous"/>
        <xsl:call-template name="render-visualization-head-assets"/>
        <style>
          a {
            text-decoration: none !important;
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

          .certificate-expiry-value {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            flex-wrap: wrap;
          }

          .certificate-expiry-badge {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.15rem 0.55rem;
            font-size: 0.72rem;
            font-style: normal;
            font-weight: 700;
            letter-spacing: 0.01em;
            line-height: 1.2;
            white-space: nowrap;
            border: 1px solid transparent;
          }

          .certificate-expiry-badge.is-valid {
            background: #e8f5e9;
            border-color: #b7dfbd;
            color: #1f6f43;
          }

          .certificate-expiry-badge.is-expiring {
            background: #fff3cd;
            border-color: #f3d58a;
            color: #8a5a00;
          }

          .certificate-expiry-badge.is-expired {
            background: #f8d7da;
            border-color: #ecb5bc;
            color: #a61e2f;
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

          .summary-card-link {
            display: block;
            color: inherit;
          }

          .summary-card-link:hover,
          .summary-card-link:focus-visible {
            color: inherit;
          }

          .summary-card {
            border: 1px solid #dee2e6;
            border-radius: 0.85rem;
            background: #ffffff;
            height: 100%;
            padding: 1rem;
            transition: transform 0.16s ease, box-shadow 0.16s ease, border-color 0.16s ease;
          }

          .summary-card.is-clickable {
            cursor: pointer;
          }

          .summary-card-link:hover .summary-card,
          .summary-card-link:focus-visible .summary-card {
            transform: translateY(-1px);
            box-shadow: 0 0.45rem 1rem rgba(33, 37, 41, 0.08);
            border-color: rgba(13, 110, 253, 0.25);
          }

          .summary-card-hint {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            margin-top: 0.35rem;
            font-size: 0.78rem;
            color: #6c757d;
          }

          .summary-toolbar {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 1rem;
            margin-top: 1rem;
            align-items: center;
          }

          .density-controls {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
          }

          .density-controls-label {
            font-size: 0.82rem;
            font-weight: 600;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            color: #6c757d;
            white-space: nowrap;
          }

          .density-toggle-group .btn {
            min-width: 7rem;
          }

          body.report-density-comfortable .table {
            font-size: 0.95rem;
            line-height: 1.4;
          }

          body.report-density-comfortable .table > :not(caption) > * > * {
            padding-top: 0.75rem;
            padding-bottom: 0.75rem;
          }

          body.report-density-dense .table {
            font-size: 0.86rem;
            line-height: 1.2;
          }

          body.report-density-dense .table > :not(caption) > * > * {
            padding-top: 0.3rem;
            padding-bottom: 0.3rem;
            padding-left: 0.45rem;
            padding-right: 0.45rem;
          }

          body.report-density-dense .table .badge {
            font-size: 0.72rem;
          }

          body.report-density-dense .host-entry-summary {
            padding: 0.8rem 1rem;
            font-size: 0.95rem;
          }

          body.report-density-dense .host-entry-body {
            padding: 0.8rem;
          }

          body.report-density-dense .summary-command summary {
            padding: 0.55rem 0.85rem;
            font-size: 0.85rem;
          }

          body.report-density-dense .summary-command pre {
            padding: 0 0.85rem 0.85rem;
            font-size: 0.82rem;
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

          .dtfh-floatingparenthead {
            z-index: 1020 !important;
          }

          .dtfh-floatingparenthead table {
            margin-top: 0 !important;
            background: #ffffff;
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

          #navbarNav .navbar-nav.me-auto .nav-link {
            display: inline-flex;
            align-items: center;
            min-height: 3.45rem;
            padding: 0.75rem 1.2rem;
            border-radius: 0.75rem;
            font-weight: 500;
          }

          #navbarNav .navbar-nav.me-auto .nav-link:hover,
          #navbarNav .navbar-nav.me-auto .nav-link:focus-visible {
            background: rgba(13, 110, 253, 0.08);
          }

          #navbarNav .navbar-nav.me-auto .nav-link.is-active {
            background: rgba(13, 110, 253, 0.14);
            color: #0a58ca;
            box-shadow: inset 0 0 0 1px rgba(13, 110, 253, 0.12);
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

          <xsl:call-template name="render-visualization-styles"/>
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
          <xsl:variable name="recorded-hosts" select="count(/nmaprun/host)"/>
          <xsl:variable name="runstats-total-hosts" select="number(/nmaprun/runstats/hosts/@total)"/>
          <xsl:variable name="total-hosts">
            <xsl:choose>
              <xsl:when test="$recorded-hosts &gt; 0">
                <xsl:value-of select="$recorded-hosts"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$runstats-total-hosts"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="up-hosts">
            <xsl:choose>
              <xsl:when test="$recorded-hosts &gt; 0">
                <xsl:value-of select="count(/nmaprun/host[status/@state='up'])"/>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="down-hosts">
            <xsl:choose>
              <xsl:when test="$recorded-hosts &gt; 0">
                <xsl:value-of select="count(/nmaprun/host[status/@state='down'])"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$runstats-total-hosts"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
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
                <a class="summary-card-link" href="#scannedhosts">
                  <div class="summary-card is-clickable">
                    <div class="text-muted small text-uppercase">Hosts Scanned</div>
                    <div class="fs-4 fw-semibold">
                      <xsl:value-of select="$total-hosts"/>
                    </div>
                    <div class="summary-card-hint">Jump to Host Overview</div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#openservices">
                  <div class="summary-card is-clickable">
                    <div class="text-muted small text-uppercase">Open Ports</div>
                    <div class="fs-4 fw-semibold">
                      <xsl:value-of select="$open-ports"/>
                    </div>
                    <div class="summary-card-hint">Jump to Open Services</div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#serviceinventory">
                  <div class="summary-card is-clickable">
                    <div class="text-muted small text-uppercase">Unique Services</div>
                    <div class="fs-4 fw-semibold">
                      <xsl:value-of select="$unique-services"/>
                    </div>
                    <div class="summary-card-hint">Jump to Service Summary</div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#webservices">
                  <div class="summary-card is-clickable">
                    <div class="text-muted small text-uppercase">Web/TLS Endpoints</div>
                    <div class="fs-4 fw-semibold">
                      <xsl:value-of select="$web-tls-endpoints"/>
                    </div>
                    <div class="summary-card-hint">Jump to Web &amp; TLS Services</div>
                  </div>
                </a>
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
            <div class="summary-toolbar">
              <div class="density-controls" aria-label="Table density controls">
                <span class="density-controls-label">Table Density</span>
                <div class="btn-group btn-group-sm density-toggle-group" role="group" aria-label="Select table density">
                  <button type="button" class="btn btn-outline-secondary" id="densityComfortable" data-density="comfortable" aria-pressed="true">Comfortable</button>
                  <button type="button" class="btn btn-outline-secondary" id="densityDense" data-density="dense" aria-pressed="false">Dense</button>
                </div>
              </div>
            </div>
            <div class="keyword-highlight-controls" aria-label="Keyword highlighter">
              <input
                type="text"
                id="keywordHighlightInput"
                class="form-control"
                placeholder="sha1, ^ftp, ssh$, http*"
                aria-label="Comma-separated keywords or regex patterns to highlight"
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

          function parseCertificateExpiry(rawValue) {
            const trimmed = (rawValue || "").trim();
            const match = trimmed.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2}))?$/);
            if (!match) {
              return null;
            }

            const [, year, month, day, hour, minute, second = "00"] = match;
            const timestamp = Date.UTC(
              Number(year),
              Number(month) - 1,
              Number(day),
              Number(hour),
              Number(minute),
              Number(second)
            );
            return Number.isNaN(timestamp) ? null : timestamp;
          }

          function formatCertificateDayCount(days) {
            if (days === 0) {
              return "today";
            }

            const absoluteDays = Math.abs(days);
            const dayLabel = absoluteDays === 1 ? "day" : "days";
            return days > 0 ? `in ${absoluteDays} ${dayLabel}` : `${absoluteDays} ${dayLabel} ago`;
          }

          function initializeCertificateExpiryAlerts() {
            const dayMs = 24 * 60 * 60 * 1000;

            document.querySelectorAll(".certificate-expiry-value").forEach(element => {
              if (element.querySelector(".certificate-expiry-badge")) {
                return;
              }

              const rawExpiry = (element.textContent || "").trim();
              const expiryTimestamp = parseCertificateExpiry(rawExpiry);
              if (expiryTimestamp === null) {
                return;
              }

              const now = Date.now();
              const daysRemaining = Math.ceil((expiryTimestamp - now) / dayMs);
              let statusText = "Valid";
              let statusClass = "is-valid";

              if (expiryTimestamp < now) {
                statusText = "Expired";
                statusClass = "is-expired";
              } else if (daysRemaining <= 30) {
                statusText = "Expiring soon";
                statusClass = "is-expiring";
              }

              const badge = document.createElement("span");
              badge.className = `certificate-expiry-badge ${statusClass}`;
              badge.textContent = statusText;
              badge.title = `${rawExpiry} (${formatCertificateDayCount(daysRemaining)})`;
              element.appendChild(badge);
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
                window.requestAnimationFrame(syncDataTableFixedHeaders);
                return;
              }

              const expanded = toggle.getAttribute("aria-expanded") === "true";
              menu.hidden = !expanded;
              window.requestAnimationFrame(syncDataTableFixedHeaders);
            }

            toggle.addEventListener("click", () => {
              const expanded = toggle.getAttribute("aria-expanded") === "true";
              toggle.setAttribute("aria-expanded", expanded ? "false" : "true");
              menu.hidden = expanded;
              window.requestAnimationFrame(syncDataTableFixedHeaders);
            });

            menu.querySelectorAll(".navbar-nav.me-auto .nav-link[href^='#']").forEach(link => {
              link.addEventListener("click", () => {
                if (window.innerWidth >= 992) {
                  return;
                }

                toggle.setAttribute("aria-expanded", "false");
                menu.hidden = true;
                window.requestAnimationFrame(syncDataTableFixedHeaders);
              });
            });

            window.addEventListener("resize", syncNavbar);
            syncNavbar();
          }

          function initializeSectionNav() {
            const navLinks = Array.from(document.querySelectorAll("#navbarNav .navbar-nav.me-auto .nav-link[href^='#']"));
            if (navLinks.length === 0) {
              return;
            }

            const sections = navLinks
              .map(link => {
                const hash = link.getAttribute("href");
                if (!hash) {
                  return null;
                }

                const section = document.querySelector(hash);
                if (!section) {
                  return null;
                }

                return { link, hash, section };
              })
              .filter(Boolean);

            if (sections.length === 0) {
              return;
            }

            function setActiveLink(hash) {
              const normalizedHash = hash && hash.startsWith("#onlinehosts-") ? "#onlinehosts" : hash;
              sections.forEach(({ link, hash: sectionHash }) => {
                const isActive = sectionHash === normalizedHash;
                link.classList.toggle("is-active", isActive);
                if (isActive) {
                  link.setAttribute("aria-current", "page");
                } else {
                  link.removeAttribute("aria-current");
                }
              });
            }

            const observer = new IntersectionObserver(entries => {
              const visibleEntries = entries
                .filter(entry => entry.isIntersecting)
                .sort((a, b) => b.intersectionRatio - a.intersectionRatio);

              if (visibleEntries.length === 0) {
                return;
              }

              const activeSection = sections.find(({ section }) => section === visibleEntries[0].target);
              if (activeSection) {
                setActiveLink(activeSection.hash);
              }
            }, {
              rootMargin: "-25% 0px -55% 0px",
              threshold: [0.2, 0.35, 0.5]
            });

            sections.forEach(({ section }) => observer.observe(section));

            navLinks.forEach(link => {
              link.addEventListener("click", () => {
                const hash = link.getAttribute("href");
                if (hash) {
                  setActiveLink(hash);
                }
              });
            });

            setActiveLink(window.location.hash || sections[0].hash);
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

          function getDataTableHeaderOffset() {
            const navbar = document.getElementById("mainNavbar");
            return navbar ? Math.ceil(navbar.getBoundingClientRect().height) : 0;
          }

          function syncDataTableFixedHeaders() {
            if (!(window.jQuery && $.fn.dataTable)) {
              return;
            }

            const tables = $.fn.dataTable.tables({ visible: true, api: true });
            const headerOffset = getDataTableHeaderOffset();

            tables.every(function () {
              if (!this.fixedHeader) {
                return;
              }

              if (typeof this.fixedHeader.headerOffset === "function") {
                this.fixedHeader.headerOffset(headerOffset);
              }

              if (typeof this.fixedHeader.adjust === "function") {
                this.fixedHeader.adjust();
              }
            });
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
                extend: 'colvis',
                text: 'Columns',
                className: 'btn btn-light'
              },
              {
                extend: 'copyHtml5',
                text: 'Copy',
                title: exportName,
                exportOptions: { columns: ':visible', orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'csvHtml5',
                text: 'CSV',
                filename: exportName,
                fieldSeparator: ';',
                exportOptions: { columns: ':visible', orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'excelHtml5',
                text: 'Excel',
                filename: exportName,
                autoFilter: true,
                exportOptions: { columns: ':visible', orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                text: 'JSON',
                className: 'btn btn-light',
                action: function (e, dt, node, config) {
                  const visibleColumns = dt.columns(':visible');
                  const headerIndexes = visibleColumns.indexes().toArray();
                  const headers = visibleColumns.header().toArray().map(h => $(h).text().trim());

                  const data = dt.rows({ search: 'applied' }).nodes().toArray().map(row => {
                    const obj = {};
                    headerIndexes.forEach((columnIndex, i) => {
                      const cell = $(row).find('td').get(columnIndex);
                      obj[headers[i]] = cell ? $(cell).text().trim() : '';
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

            const table = $(selector).DataTable({
              lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
              order: [[0, 'desc']],
              columnDefs: [
                { targets: [0], orderable: true },
                { targets: [1], type: 'ip-address' },
              ],
              dom: '<"d-flex justify-content-between align-items-center mb-2"lfB>rtip',
              stateSave: true,
              buttons: buttons,
              fixedHeader: {
                header: true,
                headerOffset: getDataTableHeaderOffset()
              }
            });

            window.requestAnimationFrame(syncDataTableFixedHeaders);
            return table;
          }

          function initializeDensityToggle() {
            const body = document.body;
            const buttons = Array.from(document.querySelectorAll("[data-density]"));
            if (!body || buttons.length === 0) {
              return;
            }

            const storageKey = "nmapview-table-density";

            function syncButtons(density) {
              buttons.forEach(button => {
                const isActive = button.getAttribute("data-density") === density;
                button.classList.toggle("btn-secondary", isActive);
                button.classList.toggle("btn-outline-secondary", !isActive);
                button.setAttribute("aria-pressed", isActive ? "true" : "false");
              });
            }

            function applyDensity(density) {
              const normalized = density === "dense" ? "dense" : "comfortable";
              body.classList.remove("report-density-comfortable", "report-density-dense");
              body.classList.add(`report-density-${normalized}`);
              syncButtons(normalized);
              try {
                window.localStorage.setItem(storageKey, normalized);
              } catch (error) {
              }

              if (window.jQuery && $.fn.dataTable) {
                $.fn.dataTable.tables({ visible: true, api: true }).columns.adjust();
                syncDataTableFixedHeaders();
              }
            }

            const savedDensity = (() => {
              try {
                return window.localStorage.getItem(storageKey);
              } catch (error) {
                return null;
              }
            })();

            applyDensity(savedDensity || "comfortable");

            buttons.forEach(button => {
              button.addEventListener("click", () => {
                applyDensity(button.getAttribute("data-density"));
              });
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

          function normalizeHighlightWildcard(pattern) {
            let normalized = "";

            for (let index = 0; index < pattern.length; index++) {
              const character = pattern[index];
              const previousCharacter = index > 0 ? pattern[index - 1] : "";

              if (character === "*" && previousCharacter !== "\\") {
                normalized += ".*";
                continue;
              }

              normalized += character;
            }

            return normalized;
          }

          function isRegexHighlightTerm(term) {
            return (
              /^\/.+\/$/.test(term) ||
              /^\^/.test(term) ||
              /\$$/.test(term) ||
              /(^|[^\\])\*/.test(term) ||
              /\\[dDsSwWbB]/.test(term) ||
              /(^|[^\\])[\[\]\(\)\|\+\?\{\}]/.test(term)
            );
          }

          function getHighlightPatternSource(term) {
            if (!isRegexHighlightTerm(term)) {
              return escapeRegex(term);
            }

            const source = /^\/.+\/$/.test(term)
              ? term.slice(1, -1)
              : normalizeHighlightWildcard(term);

            try {
              new RegExp(source, "i");
              return source;
            } catch (error) {
              return escapeRegex(term);
            }
          }

          function buildHighlightRegex(rawTerms) {
            const terms = parseHighlightTerms(rawTerms);
            if (terms.length === 0) {
              return null;
            }

            const sources = terms.map(getHighlightPatternSource);
            return new RegExp(`(${sources.join("|")})`, "gi");
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

            const regex = buildHighlightRegex(rawTerms);
            if (!regex) {
              return 0;
            }

            const container = document.getElementById("reportContent");
            if (!container) {
              return 0;
            }

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
	              initializeSectionNav();
	              initializeHostToggle();
	              initializeKeywordHighlighter();
	              initializeCpeCopy();
	              initializeCertificateExpiryAlerts();
                formatVulnersChunks();
                formatInventoryLists();
	              initializeDataTable('#table-services');
	              initializeDataTable('#table-overview');
	              initializeDataTable('#web-services');
	              initializeDataTable('#service-inventory');
                initializeDensityToggle();


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
  </xsl:template>
</xsl:stylesheet>
