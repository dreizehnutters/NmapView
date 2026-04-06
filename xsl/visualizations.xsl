<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-visualization-head-assets">
        <script src="https://cdn.plot.ly/plotly-3.3.0.min.js" crossorigin="anonymous"></script>
  </xsl:template>

  <xsl:template name="render-visualization-styles">
        <?include-asset type="css" href="assets/visualizations.css"?>
  </xsl:template>

  <xsl:template name="render-visualizations">
          <hr class="my-4"/>
          <h2 id="visualizations" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Visualizations</h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host) &gt; 0">
              <p class="text-muted fst-italic mb-3 visualization-empty">Visualization plots are embedded above in Host Overview, Open Services, and Service Summary.</p>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No hosts are available for visualization plots.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>

  <xsl:template name="render-os-distribution-card">
          <details class="visualization-card visualization-card-collapsible my-4" data-plot-targets="osTreemap">
            <summary class="visualization-card-summary">
              <div class="visualization-card-header">
                <h4 class="visualization-card-title">Operating System Distribution</h4>
                <p class="visualization-card-note">See which OS families dominate the environment and where platform diversity or concentration stands out.</p>
              </div>
            </summary>
            <div class="visualization-card-body">
              <div class="visualization-actions">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-plot-export="osTreemap">Export</button>
              </div>
              <div id="osTreemap" style="width: 1250px; max-width: 100%; height: 420px; margin: 0 auto;"/>
            </div>
          </details>
  </xsl:template>

  <xsl:template name="render-open-ports-per-host-card">
          <details class="visualization-card visualization-card-collapsible my-4" data-plot-targets="openPortsPerHostChart" open="open">
            <summary class="visualization-card-summary">
              <div class="visualization-card-header">
                <h4 class="visualization-card-title">Open Ports Per Host</h4>
                <p class="visualization-card-note">Compare host exposure at a glance. Use it to spot high-exposure systems and hosts that combine broad surface area with unusual service profiles.</p>
              </div>
            </summary>
            <div class="visualization-card-body">
              <div class="visualization-actions">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-plot-export="openPortsPerHostChart">Export</button>
              </div>
              <div class="visualization-scroll-x">
                <div id="openPortsPerHostChart" style="width: 100%;"/>
              </div>
            </div>
          </details>
  </xsl:template>

  <xsl:template name="render-host-service-relationships-card">
          <details class="visualization-card visualization-card-collapsible my-4" data-plot-targets="hostServiceGraph">
            <summary class="visualization-card-summary">
              <div class="visualization-card-header">
                <h4 class="visualization-card-title">Host-Service Relationships</h4>
                <p class="visualization-card-note">See which services are shared across hosts and which ones are isolated. Useful for spotting common baselines versus one-off systems.</p>
              </div>
            </summary>
            <div class="visualization-card-body">
              <div class="visualization-actions">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-plot-export="hostServiceGraph">Export</button>
              </div>
              <div class="visualization-scroll-x">
                <div id="hostServiceGraph" style="width: 100%;"/>
              </div>
            </div>
          </details>
  </xsl:template>

  <xsl:template name="render-service-matrix-data">
          <div id="matrixCount" class="d-none">
            <xsl:for-each select="//host">
              <xsl:variable name="effective-hostname">
                <xsl:call-template name="resolve-effective-hostname"/>
              </xsl:variable>
              <xsl:variable name="ip" select="address[not(@addrtype='mac')][1]/@addr"/>
              <div class="host">
                <xsl:attribute name="data-address">
                  <xsl:value-of select="$ip"/>
                </xsl:attribute>
                <xsl:attribute name="data-host">
	                  <xsl:value-of select="$ip"/>
	                  <xsl:if test="string(normalize-space($effective-hostname)) != ''">
	                    <xsl:text> - </xsl:text>
	                    <xsl:value-of select="$effective-hostname"/>
	                  </xsl:if>
                </xsl:attribute>
                <xsl:for-each select="ports/port[state/@state='open' and service/@name]">
                  <span class="port" data-port="{@portid}" data-conf="{service/@conf}">
                    <xsl:attribute name="data-service">
                      <xsl:value-of select="@protocol"/>
                      <xsl:text>:</xsl:text>
                      <xsl:if test="service/@tunnel = 'ssl'">
                        <xsl:text>ssl/</xsl:text>
                      </xsl:if>
                      <xsl:value-of select="service/@name"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-service-graph-label">
                      <xsl:if test="service/@tunnel = 'ssl'">
                        <xsl:text>ssl/</xsl:text>
                      </xsl:if>
                      <xsl:value-of select="service/@name"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="@portid"/>
                      <xsl:text>/</xsl:text>
                      <xsl:value-of select="@protocol"/>
                    </xsl:attribute>
                  </span>
                </xsl:for-each>
              </div>
            </xsl:for-each>
          </div>
  </xsl:template>

  <xsl:template name="render-host-port-matrix-card">
          <details class="visualization-card visualization-card-collapsible my-4" data-plot-targets="portHostMatrix" open="open">
            <summary class="visualization-card-summary">
              <div class="visualization-card-header">
                <h4 class="visualization-card-title">Host-Port Matrix</h4>
                <p class="visualization-card-note">See which ports appear on which hosts and spot unusual exposure patterns.</p>
              </div>
            </summary>
            <div class="visualization-card-body">
              <div class="visualization-actions visualization-actions-split">
                <div class="form-check form-switch mb-0">
                  <input type="checkbox" class="form-check-input" id="portHostPercentileToggle"/>
                  <label class="form-check-label small" for="portHostPercentileToggle">Mark 95th percentile uncommon ports</label>
                </div>
                <button type="button" class="btn btn-sm btn-outline-secondary" data-plot-export="portHostMatrix">Export</button>
              </div>
              <div class="visualization-scroll-x">
                <div id="portHostMatrix" style="width: 100%;"/>
              </div>
            </div>
          </details>
  </xsl:template>

  <xsl:template name="render-service-port-heatmap-card">
          <details class="visualization-card visualization-card-collapsible my-4" data-plot-targets="protocolPortMatrix">
            <summary class="visualization-card-summary">
              <div class="visualization-card-header">
                <h4 class="visualization-card-title">Service-Port Heatmap</h4>
                <p class="visualization-card-note">See which services cluster on which ports. Useful for confirming expected port usage and spotting unusual service-to-port combinations.</p>
              </div>
            </summary>
            <div class="visualization-card-body">
              <div class="visualization-actions">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-plot-export="protocolPortMatrix">Export</button>
              </div>
              <div class="visualization-scroll-x">
                <div id="protocolPortMatrix" style="width: 100%;"/>
              </div>
            </div>
          </details>
  </xsl:template>

  <xsl:template name="render-visualization-scripts">
        <?include-asset type="js" href="assets/visualizations-core.js"?>
        <?include-asset type="js" href="assets/visualizations-distribution.js"?>
        <?include-asset type="js" href="assets/visualizations-matrix.js"?>
        <?include-asset type="js" href="assets/visualizations-collapsible.js"?>
  </xsl:template>
</xsl:stylesheet>
