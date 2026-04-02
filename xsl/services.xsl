<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-open-services">
          <hr class="my-4"/>
          <h2 id="openservices" class="fs-4 mt-5 mb-3 bg-light p-3 rounded"><span class="section-heading-title">Open Services</span><small class="section-heading-subtitle">Pivot by exposed endpoint to see which services are reachable, where they run, and what software they appear to be.</small></h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host/ports/port[state/@state='open']) &gt; 0">
              <div class="table-responsive">
                <table id="table-services" class="table table-striped table-hover align-middle" role="grid">
                  <thead class="table-light">
                    <tr>
                      <th scope="col">Hostname</th>
                      <th scope="col">Address</th>
                      <th scope="col">Port</th>
                      <th scope="col">Protocol</th>
                      <th scope="col">
                        <span title="Unique hosts exposing this exact port/protocol across the scan. Lower values are rarer.">Count</span>
                      </th>
                      <th scope="col">Service</th>
                      <th scope="col">Product</th>
                      <th scope="col">Version</th>
                      <th scope="col">Extra Info</th>
                      <th scope="col">CPE</th>
                      <th scope="col">Exploits</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select="/nmaprun/host">
                      <xsl:for-each select="ports/port[state/@state='open']">
                        <xsl:variable name="hostname">
                          <xsl:call-template name="resolve-effective-hostname"/>
                        </xsl:variable>
                        <xsl:variable name="ip" select="../../address[not(@addrtype='mac')][1]/@addr"/>
                        <xsl:variable name="port-id" select="@portid"/>
                        <xsl:variable name="port-protocol" select="@protocol"/>
                        <xsl:variable name="port-host-count" select="count(/nmaprun/host[ports/port[state/@state='open' and @portid=$port-id and @protocol=$port-protocol]])"/>
                        <xsl:variable name="http-headers-output" select="script[@id='http-headers']/@output"/>
                        <xsl:variable name="http-fingerprint-output" select="script[@id='fingerprint-strings']/elem[@key='GetRequest']"/>
                        <xsl:variable name="http-title">
                          <xsl:choose>
                            <xsl:when test="count(script[@id='http-title']/elem[@key='title']) &gt; 0">
                              <xsl:value-of select="script[@id='http-title']/elem[@key='title']"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="script[@id='http-title']/@output"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="http-location">
                          <xsl:choose>
                            <xsl:when test="count(script[@id='http-title']/elem[@key='redirect_url']) &gt; 0">
                              <xsl:value-of select="script[@id='http-title']/elem[@key='redirect_url']"/>
                            </xsl:when>
                            <xsl:when test="contains($http-headers-output, 'Location:')">
                              <xsl:call-template name="extract-header-value">
                                <xsl:with-param name="text" select="$http-headers-output"/>
                                <xsl:with-param name="label" select="'Location'"/>
                              </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="extract-header-value">
                                <xsl:with-param name="text" select="$http-fingerprint-output"/>
                                <xsl:with-param name="label" select="'Location'"/>
                              </xsl:call-template>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="http-server">
                          <xsl:choose>
                            <xsl:when test="count(script[@id='http-server-header']/elem) &gt; 0">
                              <xsl:value-of select="script[@id='http-server-header']/elem[1]"/>
                            </xsl:when>
                            <xsl:when test="string(script[@id='http-server-header']/@output) != ''">
                              <xsl:value-of select="script[@id='http-server-header']/@output"/>
                            </xsl:when>
                            <xsl:when test="contains($http-headers-output, 'Server:')">
                              <xsl:call-template name="extract-header-value">
                                <xsl:with-param name="text" select="$http-headers-output"/>
                                <xsl:with-param name="label" select="'Server'"/>
                              </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="extract-header-value">
                                <xsl:with-param name="text" select="$http-fingerprint-output"/>
                                <xsl:with-param name="label" select="'Server'"/>
                              </xsl:call-template>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="http-powered-by">
                          <xsl:choose>
                            <xsl:when test="contains(translate($http-headers-output, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'powered-by:')">
                              <xsl:call-template name="extract-powered-by-value">
                                <xsl:with-param name="text" select="$http-headers-output"/>
                              </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="extract-powered-by-value">
                                <xsl:with-param name="text" select="$http-fingerprint-output"/>
                              </xsl:call-template>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="http-stack-source" select="concat($http-headers-output, '&#xA;', $http-fingerprint-output)"/>
                        <xsl:variable name="http-stack-hint">
                          <xsl:call-template name="extract-stack-hint-line">
                            <xsl:with-param name="text" select="$http-stack-source"/>
                          </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="http-powered-by-evidence">
                          <xsl:choose>
                            <xsl:when test="string($http-powered-by) != ''">
                              <xsl:value-of select="$http-powered-by"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="$http-stack-hint"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="http-powered-by-stack">
                          <xsl:call-template name="normalize-powered-by-stack">
                            <xsl:with-param name="value" select="$http-stack-source"/>
                          </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="has-http-summary"
                          select="starts-with(service/@name, 'http') or script[@id='ssl-cert'] or string($http-title) != '' or string($http-location) != '' or string($http-server) != '' or string($http-powered-by-stack) != '' or string($http-powered-by-evidence) != ''"/>
                        <tr>
                          <td>
                            <xsl:call-template name="render-hostname-or-na">
                              <xsl:with-param name="hostname" select="$hostname"/>
                            </xsl:call-template>
                          </td>
                          <td>
                            <xsl:call-template name="render-onlinehosts-link">
                              <xsl:with-param name="address" select="$ip"/>
                            </xsl:call-template>
                          </td>
                          <td>
                            <xsl:attribute name="data-order">
                              <xsl:value-of select="@portid"/>
                            </xsl:attribute>
                            <xsl:attribute name="data-search">
                              <xsl:value-of select="@portid"/>
                            </xsl:attribute>
                            <xsl:call-template name="render-endpoint-link">
                              <xsl:with-param name="address" select="$ip"/>
                              <xsl:with-param name="port" select="@portid"/>
                              <xsl:with-param name="protocol" select="@protocol"/>
                              <xsl:with-param name="service-name" select="service/@name"/>
                              <xsl:with-param name="tunnel" select="service/@tunnel"/>
                              <xsl:with-param name="text" select="@portid"/>
                            </xsl:call-template>
                          </td>
                          <td>
                            <xsl:value-of select="@protocol"/>
                          </td>
                          <td>
                            <xsl:attribute name="data-order">
                              <xsl:value-of select="$port-host-count"/>
                            </xsl:attribute>
                            <xsl:value-of select="$port-host-count"/>
                          </td>
                          <td>
                            <xsl:call-template name="render-service-name"/>
                          </td>
                          <td>
                            <xsl:value-of select="service/@product"/>
                          </td>
                          <td>
                            <xsl:value-of select="service/@version"/>
                          </td>
                          <td>
                            <xsl:if test="string(service/@extrainfo) != ''">
                              <div>
                                <xsl:value-of select="service/@extrainfo"/>
                              </div>
                            </xsl:if>
                            <xsl:if test="$has-http-summary">
                              <div class="http-details-block service-extra-http">
                                <xsl:call-template name="render-http-row">
                                  <xsl:with-param name="label" select="'Title'"/>
                                  <xsl:with-param name="value" select="$http-title"/>
                                </xsl:call-template>
                                <xsl:call-template name="render-http-row">
                                  <xsl:with-param name="label" select="'Location'"/>
                                  <xsl:with-param name="value" select="$http-location"/>
                                </xsl:call-template>
                                <xsl:call-template name="render-http-row">
                                  <xsl:with-param name="label" select="'Server'"/>
                                  <xsl:with-param name="value" select="$http-server"/>
                                </xsl:call-template>
                                <xsl:call-template name="render-http-row">
                                  <xsl:with-param name="label" select="'Stack'"/>
                                  <xsl:with-param name="value" select="$http-powered-by-stack"/>
                                </xsl:call-template>
                                <xsl:call-template name="render-http-row">
                                  <xsl:with-param name="label" select="'Powered-By'"/>
                                  <xsl:with-param name="value" select="$http-powered-by-evidence"/>
                                </xsl:call-template>
                              </div>
                            </xsl:if>
                          </td>
                          <td>
                            <xsl:call-template name="render-cpe-text">
                              <xsl:with-param name="cpe" select="service/cpe"/>
                            </xsl:call-template>
                          </td>
                          <td>
                            <div class="vulners-chunks" data-raw="{.//script[@id='vulners']/@output}"/>
                          </td>
                        </tr>
                      </xsl:for-each>
                    </xsl:for-each>
                  </tbody>
                </table>
              </div>
              <xsl:call-template name="render-service-distribution"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No open services were found in this scan.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>

  <xsl:template name="render-service-counts-data">
          <div id="serviceCounts" class="d-none">
            <xsl:for-each select="//host">
              <xsl:variable name="ip" select="address[not(@addrtype='mac')][1]/@addr"/>
              <xsl:for-each select="ports/port[state/@state='open']">
                <span class="service">
                  <xsl:attribute name="data-service">
                    <xsl:choose>
                      <xsl:when test="script[@id='ssl-cert']">
                        <xsl:text>ssl/</xsl:text>
                        <xsl:choose>
                          <xsl:when test="number(service/@conf) &gt; 5">
                            <xsl:value-of select="service/@name"/>
                          </xsl:when>
                          <xsl:otherwise>unknown</xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="number(service/@conf) &gt; 5">
                            <xsl:value-of select="service/@name"/>
                          </xsl:when>
                          <xsl:otherwise>unknown</xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:attribute name="data-portid">
                    <xsl:value-of select="@portid"/>
                  </xsl:attribute>
                  <xsl:attribute name="data-porto">
                    <xsl:value-of select="@protocol"/>
                  </xsl:attribute>
                  <xsl:attribute name="data-address">
                    <xsl:value-of select="$ip"/>
                  </xsl:attribute>
                </span>
              </xsl:for-each>
            </xsl:for-each>
          </div>
  </xsl:template>

  <xsl:template name="render-service-distribution">
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host/ports/port[state/@state='open']) &gt; 0">
              <xsl:call-template name="render-service-counts-data"/>
              <details class="visualization-card visualization-card-collapsible my-4" data-plot-targets="serviceChart" open="open">
                <summary class="visualization-card-summary">
                  <div class="visualization-card-header">
                    <h4 class="visualization-card-title">Service Distribution Across Hosts</h4>
                    <p class="visualization-card-note">See which services are most widespread and which appear on only a few hosts. Useful for separating normal baseline services from uncommon ones.</p>
                  </div>
                </summary>
                <div class="visualization-card-body">
                  <div class="visualization-actions">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-plot-export="serviceChart">Export</button>
                  </div>
                  <div class="service-distribution-layout">
                    <div class="service-ledger-stack">
                      <section class="service-ledger-section" aria-labelledby="topServicesLedgerTitle">
                        <h5 id="topServicesLedgerTitle" class="service-ledger-title">Top 5 Common</h5>
                        <div id="topServicesLedger" role="list"></div>
                      </section>
                    </div>
                    <div class="service-distribution-chart">
                      <div id="serviceChart" style="width: 100%; height: 220px"/>
                    </div>
                    <div class="service-ledger-stack">
                      <section class="service-ledger-section" aria-labelledby="bottomServicesLedgerTitle">
                        <h5 id="bottomServicesLedgerTitle" class="service-ledger-title">Top 5 Rare</h5>
                        <div id="bottomServicesLedger" role="list"></div>
                      </section>
                    </div>
                  </div>
                </div>
              </details>
              <xsl:if test="count(//host/ports/port[state/@state='open' and service/@name]) &gt; 0">
                <xsl:call-template name="render-host-service-relationships-card"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
