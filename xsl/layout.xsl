<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-head">
      <head>
        <meta name="referrer" content="no-referrer"/>
        <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='14' fill='%23f7f9fb'/%3E%3Ccircle cx='27' cy='27' r='15' fill='none' stroke='%2324313d' stroke-width='6'/%3E%3Cpath d='M38 38 L52 52' stroke='%2324313d' stroke-width='6' stroke-linecap='round'/%3E%3C/svg%3E"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.css" rel="stylesheet" crossorigin="anonymous"/>
        <script src="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.js" crossorigin="anonymous"/>
        <xsl:call-template name="render-visualization-head-assets"/>
        <?include-asset type="css" href="assets/layout.css"?>
        <xsl:call-template name="render-visualization-styles"/>
        <title>NmapView | Analysis Interface</title>
      </head>
  </xsl:template>
  <xsl:template name="render-loading-overlay">
        <div id="reportLoadingOverlay" class="report-loading-overlay report-loading-overlay-no-blur" role="status" aria-live="polite" aria-label="Loading report">
          <div class="report-loading-card">
            <p class="report-loading-title"><span id="reportLoadingTitleText">Preparing Report</span><span class="report-loading-dots" aria-hidden="true"><span class="report-loading-dot"/><span class="report-loading-dot"/><span class="report-loading-dot"/></span></p>
          </div>
        </div>
  </xsl:template>
  <xsl:template name="render-navbar">
        <nav id="mainNavbar" class="navbar navbar-light bg-light fixed-top">
          <div class="container-fluid">
            <div id="navbarNav">
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
                  <a class="nav-link" href="#onlinehosts">Host Details</a>
                </li>
              </ul>
              <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                  <button
                    type="button"
                    class="nav-link navbar-about-trigger"
                    id="aboutDialogTrigger"
                    aria-haspopup="dialog"
                    aria-controls="aboutDialog"
                    aria-label="Get NmapView source and licenses"
                    title="Get NmapView source"
                  >
                    <span class="navbar-about-trigger-label">NmapView</span>
                    <svg class="navbar-brand-mark" height="64" width="64" viewBox="0 0 64 64" aria-hidden="true" style="max-height: 42px; width: auto;">
                      <rect width="64" height="64" rx="14" fill="#f7f9fb"/>
                      <circle class="navbar-brand-mark-lens" cx="27" cy="27" r="15" fill="none" stroke="#24313d" stroke-width="6"/>
                      <path class="navbar-brand-mark-lens" d="M38 38 L52 52" stroke="#24313d" stroke-width="6" stroke-linecap="round"/>
                    </svg>
                  </button>
                </li>
              </ul>
            </div>
          </div>
        </nav>
  </xsl:template>
  <xsl:template name="render-about-dialog">
        <dialog id="aboutDialog" class="report-dialog" aria-labelledby="aboutDialogTitle">
          <div class="report-dialog-shell">
            <div class="report-dialog-header">
              <div>
                <h2 id="aboutDialogTitle" class="report-dialog-title">About NmapView</h2>
                <p class="report-dialog-subtitle">Analysis stays local in the report and no scan data is sent anywhere.</p>
              </div>
              <button type="button" class="btn-close report-dialog-close" data-dialog-close="aboutDialog" aria-label="Close"></button>
            </div>
            <div class="report-dialog-body">
              <p class="report-dialog-lead">NmapView turns Nmap XML into a single interactive HTML analysis report. It helps you review hosts, open services, service variants, script output, and visualizations in one portable file.</p>
              <p class="report-dialog-note">Tip: <kbd class="report-dialog-note-kbd">/</kbd> Search active table</p>
              <p class="report-dialog-meta"><a class="report-dialog-version-link" href="https://github.com/dreizehnutters/NmapView/releases" target="_blank" rel="noopener noreferrer">NmapView v3.4</a><span class="report-dialog-meta-separator">·</span><a class="report-dialog-version-link" href="https://github.com/dreizehnutters/NmapView" target="_blank" rel="noopener noreferrer">Documentation &amp; Source</a></p>

              <section class="report-dialog-section" aria-labelledby="aboutDialogProjectTitle">
                <h3 id="aboutDialogProjectTitle" class="report-dialog-section-title">Project</h3>
                <div class="report-source-list">
                  <div class="report-source-item">
                    <div class="report-source-top">
                      <a class="report-source-name" href="https://github.com/dreizehnutters/NmapView" target="_blank" rel="noopener noreferrer">NmapView</a>
                      <span class="report-license-badge">MIT</span>
                    </div>
                    <p class="report-source-note">Project source, releases, and standalone XSL download.</p>
                  </div>
                </div>
              </section>

              <section class="report-dialog-section" aria-labelledby="aboutDialogSourcesTitle">
                <h3 id="aboutDialogSourcesTitle" class="report-dialog-section-title">Runtime Libraries</h3>
                <div class="report-source-list">
                  <div class="report-source-item">
                    <div class="report-source-top">
                      <a class="report-source-name" href="https://getbootstrap.com/" target="_blank" rel="noopener noreferrer">Bootstrap 5.3.8</a>
                      <span class="report-license-badge">MIT</span>
                    </div>
                    <p class="report-source-note">Base layout, spacing, and UI components.</p>
                  </div>
                  <div class="report-source-item">
                    <div class="report-source-top">
                      <a class="report-source-name" href="https://datatables.net/" target="_blank" rel="noopener noreferrer">DataTables 2.3.7 + Buttons, ColVis, FixedHeader</a>
                      <span class="report-license-badge">MIT</span>
                    </div>
                    <p class="report-source-note">Searchable tables, column toggles, and export controls.</p>
                  </div>
                  <div class="report-source-item">
                    <div class="report-source-top">
                      <a class="report-source-name" href="https://jquery.com/" target="_blank" rel="noopener noreferrer">jQuery 3.7.0</a>
                      <span class="report-license-badge">MIT</span>
                    </div>
                    <p class="report-source-note">Loaded as a DataTables runtime dependency.</p>
                  </div>
                  <div class="report-source-item">
                    <div class="report-source-top">
                      <a class="report-source-name" href="https://stuk.github.io/jszip/" target="_blank" rel="noopener noreferrer">JSZip 3.10.1</a>
                      <span class="report-license-badge">MIT or GPL-3.0+</span>
                    </div>
                    <p class="report-source-note">Loaded via the DataTables bundle for client-side export support.</p>
                  </div>
                  <div class="report-source-item">
                    <div class="report-source-top">
                      <a class="report-source-name" href="https://plotly.com/javascript/" target="_blank" rel="noopener noreferrer">Plotly.js 3.3.0</a>
                      <span class="report-license-badge">MIT</span>
                    </div>
                    <p class="report-source-note">Interactive charts and PNG plot export.</p>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </dialog>
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
          <xsl:variable name="rare-services" select="count(//host/ports/port[state/@state='open' and service/@name]
            [count(key('openPortProtocolGroup', concat(@portid, '-', @protocol))) = 1]
            [generate-id() = generate-id(
              key('rareServiceGroup',
                concat(
                  substring('ssl/', 1, count(script[@id='ssl-cert']) * string-length('ssl/')),
                  substring(service/@name, 1, string-length(service/@name) * (number(service/@conf) &gt; 5)),
                  substring('unknown', 1, string-length('unknown') * not(number(service/@conf) &gt; 5)),
                  '-',
                  @protocol
                )
              )[1]
            )])"/>
          <xsl:variable name="http-buckets" select="count(//host/ports/port[state/@state='open' and service/@name and (contains(translate(service/@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'http') or script[@id='http-title'] or script[@id='http-headers'] or script[@id='http-server-header'])]
            [generate-id() = generate-id(
              key('httpServiceBucketGroup',
                concat(
                  substring('ssl/', 1, count(script[@id='ssl-cert']) * string-length('ssl/')),
                  substring(service/@name, 1, string-length(service/@name) * (number(service/@conf) &gt; 5)),
                  substring('unknown', 1, string-length('unknown') * not(number(service/@conf) &gt; 5)),
                  '|',
                  normalize-space(service/@product),
                  '|',
                  substring(normalize-space(service/@version), 1, string-length(normalize-space(service/@version)) * boolean(string(normalize-space(service/@product))))
                )
              )[1]
            )])"/>
          <xsl:variable name="duration-seconds" select="number(/nmaprun/runstats/finished/@time) - number(/nmaprun/@start)"/>
          <xsl:variable name="duration-hours" select="floor($duration-seconds div 3600)"/>
          <xsl:variable name="duration-minutes" select="floor(($duration-seconds mod 3600) div 60)"/>
          <xsl:variable name="duration-remainder-seconds" select="floor($duration-seconds mod 60)"/>
          <div id="summary" class="bg-light p-4 rounded shadow-sm">
            <div class="row g-3 mb-4">
              <div class="col-6 col-lg">
                <a class="summary-card-link" href="#openservices">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Open ports</div>
                    <div class="summary-card-value" id="summaryOpenPortsValue">
                      <xsl:value-of select="$open-ports"/>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg">
                <a class="summary-card-link" href="#serviceinventory">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Unique services</div>
                    <div class="summary-card-value" id="summaryUniqueServicesValue">
                      <xsl:value-of select="$unique-services"/>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg">
                <a class="summary-card-link" href="#openservices">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Rare services</div>
                    <div class="summary-card-value" id="summaryRareServicesValue">
                      <xsl:value-of select="$rare-services"/>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg">
                <a class="summary-card-link" href="#serviceinventory">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">HTTP</div>
                    <div class="summary-card-value" id="summaryHttpBucketsValue">
                      <xsl:value-of select="$http-buckets"/>
                    </div>
                  </div>
                </a>
              </div>
            </div>
            <div class="progress summary-progress">
              <div class="progress-bar bg-success" id="summaryUpHostsBar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
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
              <xsl:if test="number($down-hosts) &gt; 0">
                <div class="progress-bar bg-warning" id="summaryDownHostsBar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
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
              </xsl:if>
            </div>
            <details class="summary-command">
              <summary>Nmap Version: <xsl:value-of select="/nmaprun/@version"/><xsl:text> | </xsl:text>Scan Duration: <xsl:value-of select="/nmaprun/@startstr"/> - <xsl:value-of select="/nmaprun/runstats/finished/@timestr"/><xsl:text> (</xsl:text><xsl:if test="$duration-hours &gt; 0"><xsl:value-of select="$duration-hours"/><xsl:text>h </xsl:text></xsl:if><xsl:if test="$duration-minutes &gt; 0 or $duration-hours &gt; 0"><xsl:value-of select="$duration-minutes"/><xsl:text>m </xsl:text></xsl:if><xsl:value-of select="$duration-remainder-seconds"/><xsl:text>s)</xsl:text></summary>
              <pre>
                <xsl:attribute name="text">
                  <xsl:value-of select="/nmaprun/@args"/>
                </xsl:attribute>
                <xsl:value-of select="/nmaprun/@args"/>
              </pre>
            </details>
            <p class="summary-note"><span class="summary-note-icon">ⓘ</span>Nmap's service detection is heuristic and may include false positives.</p>
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
              <button type="button" class="btn btn-warning" id="highlightKeywordsButton">Globally Highlight Keywords</button>
              <button type="button" class="btn btn-outline-secondary" id="resetHighlightsButton">Reset</button>
            </div>
          </div>
  </xsl:template>
  <xsl:template name="render-footer">
        <hr class="my-3 footer-spacer"/>
        <footer class="footer bg-light py-3">
          <div class="container">
            <p class="text-muted mb-0 text-center">
              Generated with <a href="https://github.com/dreizehnutters/NmapView">NmapView</a></p>
          </div>
        </footer>
  </xsl:template>
  <xsl:template name="render-scripts">
        <?include-asset type="js" href="assets/layout.js"?>
        <?include-asset type="js" href="assets/layout-init.js"?>
  </xsl:template>
</xsl:stylesheet>
