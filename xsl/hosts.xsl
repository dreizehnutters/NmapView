<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-scanned-hosts">
          <h2 id="scannedhosts" class="fs-4 mt-5 mb-3 bg-light p-3 rounded"><span class="section-heading-title">Host Overview</span><small class="section-heading-subtitle">Review scanned hosts at a high level to understand exposure, identity, and triage priority.</small></h2>
          <xsl:variable name="recorded-hosts" select="count(/nmaprun/host)"/>
          <xsl:variable name="runstats-total-hosts" select="number(/nmaprun/runstats/hosts/@total)"/>
          <xsl:choose>
	            <xsl:when test="$recorded-hosts &gt; 0">
	              <div class="table-responsive">
                <table id="table-overview" class="table table-striped table-hover align-middle" role="grid">
                  <thead class="table-light">
	                    <tr>
	                      <th scope="col">State</th>
	                      <th scope="col">Mac</th>
	                      <th scope="col">Vendor</th>
	                      <th scope="col">OS (est.)</th>
	                      <th scope="col">Address</th>
	                      <th scope="col">Hostname</th>
	                      <th scope="col">Open TCP Ports</th>
	                      <th scope="col">Open UDP Ports</th>
	                      <th scope="col">
	                        <span title="Estimated by Nmap from TCP timestamps; useful as context, not an exact reboot time.">Uptime (est.)</span>
	                      </th>
	                      <th scope="col">
	                        <span title="Approximate hop distance from the scanner, as reported by Nmap.">Hops</span>
	                      </th>
	                      <th scope="col">
	                        <span title="Relative rarity of this host's open services within this scan. Higher scores indicate hosts with less common service combinations.">Rarity</span>
	                      </th>
	                    </tr>
	                  </thead>
	                  <tbody>
	                    <xsl:for-each select="/nmaprun/host">
	                      <xsl:variable name="vuln-count" select="count(.//script[@id='vulners']//table[elem[@key='id']])"/>
	                      <xsl:variable name="uptime-seconds-raw" select="uptime/@seconds"/>
	                      <xsl:variable name="uptime-seconds" select="number($uptime-seconds-raw)"/>
	                      <xsl:variable name="uptime-days" select="floor($uptime-seconds div 86400)"/>
	                      <xsl:variable name="uptime-hours" select="floor(($uptime-seconds mod 86400) div 3600)"/>
	                      <xsl:variable name="uptime-minutes" select="floor(($uptime-seconds mod 3600) div 60)"/>
	                      <xsl:variable name="is-up" select="status/@state='up'"/>
	                      <xsl:variable name="hostname">
                          <xsl:call-template name="resolve-effective-hostname"/>
                        </xsl:variable>
	                      <xsl:variable name="ip" select="address[not(@addrtype='mac')][1]/@addr"/>
	                      <xsl:variable name="mac-address" select="address[@addrtype='mac']/@addr"/>
	                      <xsl:variable name="mac-vendor" select="address[@addrtype='mac']/@vendor"/>
	                      <xsl:variable name="os-name" select="os/osmatch[1]/@name"/>
	                      <xsl:variable name="has-uptime-estimate" select="status/@state='up' and (string(uptime/@lastboot) != '' or $uptime-seconds &gt; 0)"/>
	                      <tr data-state="{status/@state}" data-address="{$ip}" data-issues="{$vuln-count}">
                        <td>
                          <span class="badge text-bg-secondary">
                            <xsl:if test="status/@state='up'">
                              <xsl:attribute name="class">badge bg-success</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="status/@state"/>
                          </span>
                        </td>
                        <td>
                          <xsl:choose>
                            <xsl:when test="string($mac-address) != ''">
                              <xsl:value-of select="$mac-address"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                        <td>
                          <xsl:choose>
                            <xsl:when test="string($mac-vendor) != ''">
                              <xsl:value-of select="$mac-vendor"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                        <td>
                          <xsl:choose>
                            <xsl:when test="string($os-name) != ''">
                              <xsl:value-of select="$os-name"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                        <td>
                          <xsl:attribute name="data-order">
                            <xsl:call-template name="render-address-sort-key">
                              <xsl:with-param name="address" select="$ip"/>
                            </xsl:call-template>
                          </xsl:attribute>
                          <xsl:choose>
                            <xsl:when test="$is-up">
                              <xsl:call-template name="render-onlinehosts-link">
                                <xsl:with-param name="address" select="$ip"/>
                              </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="$ip"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
	                        <td>
	                          <xsl:choose>
	                            <xsl:when test="string(normalize-space($hostname)) != ''">
	                              <xsl:value-of select="$hostname"/>
	                            </xsl:when>
	                            <xsl:otherwise>
	                              <span class="text-muted">N/A</span>
	                            </xsl:otherwise>
	                          </xsl:choose>
	                        </td>
	                        <td>
                          <xsl:attribute name="data-order">
                            <xsl:choose>
                              <xsl:when test="$is-up">
                                <xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/>
                              </xsl:when>
                              <xsl:otherwise>-1</xsl:otherwise>
                            </xsl:choose>
                          </xsl:attribute>
                          <xsl:choose>
                            <xsl:when test="$is-up">
                              <xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                        <td>
                          <xsl:attribute name="data-order">
                            <xsl:choose>
                              <xsl:when test="$is-up">
                                <xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/>
                              </xsl:when>
                              <xsl:otherwise>-1</xsl:otherwise>
                            </xsl:choose>
                          </xsl:attribute>
                          <xsl:choose>
                            <xsl:when test="$is-up">
                              <xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
	                        <td>
                          <xsl:attribute name="data-order">
                            <xsl:choose>
                              <xsl:when test="$has-uptime-estimate and string($uptime-seconds-raw) != ''">
                                <xsl:value-of select="$uptime-seconds"/>
                                </xsl:when>
                                <xsl:otherwise>-1</xsl:otherwise>
                              </xsl:choose>
                            </xsl:attribute>
	                          <xsl:choose>
	                            <xsl:when test="$has-uptime-estimate">
	                              <span>
	                                <xsl:attribute name="title">
	                                  <xsl:text>Estimated by Nmap from TCP timestamps</xsl:text>
	                                  <xsl:if test="string(uptime/@lastboot) != ''">
	                                    <xsl:text>. Last boot guess: </xsl:text>
	                                    <xsl:value-of select="uptime/@lastboot"/>
	                                  </xsl:if>
	                                  <xsl:if test="string($uptime-seconds-raw) != ''">
	                                    <xsl:text>. Raw seconds: </xsl:text>
	                                    <xsl:value-of select="$uptime-seconds-raw"/>
	                                  </xsl:if>
	                                </xsl:attribute>
	                                <xsl:text>~</xsl:text>
	                                <xsl:choose>
	                                  <xsl:when test="$uptime-days &gt; 0">
	                                    <xsl:value-of select="$uptime-days"/>
	                                    <xsl:text>d</xsl:text>
	                                    <xsl:if test="$uptime-hours &gt; 0">
	                                      <xsl:text> </xsl:text>
	                                      <xsl:value-of select="$uptime-hours"/>
	                                      <xsl:text>h</xsl:text>
	                                    </xsl:if>
	                                  </xsl:when>
	                                  <xsl:when test="$uptime-hours &gt; 0">
	                                    <xsl:value-of select="$uptime-hours"/>
	                                    <xsl:text>h</xsl:text>
	                                    <xsl:if test="$uptime-minutes &gt; 0">
	                                      <xsl:text> </xsl:text>
	                                      <xsl:value-of select="$uptime-minutes"/>
	                                      <xsl:text>m</xsl:text>
	                                    </xsl:if>
	                                  </xsl:when>
	                                  <xsl:when test="$uptime-minutes &gt; 0">
	                                    <xsl:value-of select="$uptime-minutes"/>
	                                    <xsl:text>m</xsl:text>
	                                  </xsl:when>
	                                  <xsl:otherwise>&lt;1m</xsl:otherwise>
	                                </xsl:choose>
	                              </span>
	                            </xsl:when>
	                            <xsl:otherwise>
	                              <span class="text-muted">N/A</span>
	                            </xsl:otherwise>
	                          </xsl:choose>
	                        </td>
	                        <td>
                            <xsl:attribute name="data-order">
                              <xsl:choose>
                                <xsl:when test="status/@state='up' and string(distance/@value) != ''">
                                  <xsl:value-of select="number(distance/@value)"/>
                                </xsl:when>
                                <xsl:otherwise>-1</xsl:otherwise>
                              </xsl:choose>
                            </xsl:attribute>
	                          <xsl:choose>
	                            <xsl:when test="status/@state='up' and string(distance/@value) != ''">
	                              <span>
	                                <xsl:attribute name="title">Approximate hop distance from the scanner</xsl:attribute>
	                                <xsl:value-of select="distance/@value"/>
	                              </span>
	                            </xsl:when>
	                            <xsl:otherwise>
	                              <span class="text-muted">N/A</span>
	                            </xsl:otherwise>
	                          </xsl:choose>
	                        </td>
                        <td class="host-uniqueness-cell" data-order="0" data-search="0">
                          <xsl:choose>
                            <xsl:when test="$is-up">
                              <span class="text-muted">Calculating...</span>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </tbody>
                </table>
              </div>
              <xsl:if test="count(//host/ports/port[state/@state='open' and service/@name]) &gt; 0">
                <xsl:call-template name="render-open-ports-per-host-card"/>
              </xsl:if>
              <xsl:call-template name="render-os-distribution-card"/>
            </xsl:when>
            <xsl:when test="$runstats-total-hosts = 1">
              <xsl:variable name="scan-target-raw">
                <xsl:call-template name="extract-last-token">
                  <xsl:with-param name="text" select="/nmaprun/@args"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="scan-target">
                <xsl:choose>
                  <xsl:when test="contains($scan-target-raw, '/')">
                    <xsl:value-of select="substring-before($scan-target-raw, '/')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$scan-target-raw"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <div class="table-responsive">
                <table id="table-overview" class="table table-striped table-hover align-middle" role="grid">
                  <thead class="table-light">
	                    <tr>
	                      <th scope="col">State</th>
	                      <th scope="col">Mac</th>
	                      <th scope="col">Vendor</th>
	                      <th scope="col">OS (est.)</th>
	                      <th scope="col">Address</th>
	                      <th scope="col">Hostname</th>
	                      <th scope="col">Open TCP Ports</th>
	                      <th scope="col">Open UDP Ports</th>
	                      <th scope="col">
	                        <span title="Estimated by Nmap from TCP timestamps; useful as context, not an exact reboot time.">Uptime (est.)</span>
	                      </th>
	                      <th scope="col">
	                        <span title="Approximate hop distance from the scanner, as reported by Nmap.">Hops</span>
	                      </th>
	                      <th scope="col">
	                        <span title="Relative rarity of this host's open services within this scan. Higher scores indicate hosts with less common service combinations.">Rarity</span>
	                      </th>
	                    </tr>
	                  </thead>
	                  <tbody>
                      <tr data-state="down" data-address="{$scan-target}" data-issues="0">
                        <td>
                          <span class="badge text-bg-secondary">down</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td>
                          <xsl:attribute name="data-order">
                            <xsl:call-template name="render-address-sort-key">
                              <xsl:with-param name="address" select="$scan-target"/>
                            </xsl:call-template>
                          </xsl:attribute>
                          <xsl:choose>
                            <xsl:when test="string($scan-target) != ''">
                              <xsl:value-of select="$scan-target"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <span class="text-muted">N/A</span>
                            </xsl:otherwise>
                          </xsl:choose>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td data-order="-1">
                          <span class="text-muted">N/A</span>
                        </td>
                        <td class="host-uniqueness-cell" data-order="-1" data-search="N/A">
                          <span class="text-muted">N/A</span>
                        </td>
                      </tr>
                    </tbody>
                </table>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No hosts were recorded in this scan.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>
  <xsl:template name="render-online-hosts">
          <hr class="my-4"/>
          <h2 id="onlinehosts" class="fs-4 mt-5 mb-3 bg-light p-3 rounded"><span class="section-heading-title">Host Details</span><small class="section-heading-subtitle">Inspect each host in detail.</small></h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host[status/@state='up']) &gt; 0">
              <div class="host-controls mb-3">
                <button type="button" class="btn btn-outline-secondary btn-sm" id="toggle-all-hosts" aria-controls="onlinehosts-list" aria-expanded="false">Expand all</button>
              </div>
              <div class="host-list" id="onlinehosts-list">
                <xsl:for-each select="/nmaprun/host[status/@state='up']">
                  <xsl:variable name="host-id" select="translate(address/@addr, '.:', '--')"/>
                  <xsl:variable name="effective-hostname">
                    <xsl:call-template name="resolve-effective-hostname"/>
                  </xsl:variable>
                  <xsl:variable name="effective-hostname-source">
                    <xsl:call-template name="resolve-effective-hostname-source"/>
                  </xsl:variable>
                  <details class="host-entry">
                    <xsl:attribute name="id">host-entry-<xsl:value-of select="$host-id"/></xsl:attribute>
                    <summary class="host-entry-summary">
                      <span class="host-entry-anchor">
                        <xsl:attribute name="id">onlinehosts-<xsl:value-of select="$host-id"/></xsl:attribute>
                      </span>
                      <span class="host-entry-label">
                        <xsl:call-template name="render-host-header-label">
                          <xsl:with-param name="address" select="address/@addr"/>
                          <xsl:with-param name="mac" select="address[@addrtype='mac']/@addr"/>
                          <xsl:with-param name="vendor" select="address[@addrtype='mac']/@vendor"/>
                          <xsl:with-param name="hostname" select="$effective-hostname"/>
                        </xsl:call-template>
                      </span>
                    </summary>
                    <div class="host-entry-body">
                    <xsl:choose>
                    <xsl:when test="count(hostnames/hostname) &gt; 0">
                      <h4 class="fs-6">Hostnames</h4>
                      <ul>
                        <xsl:for-each select="hostnames/hostname">
                          <li><xsl:value-of select="@name"/> (<xsl:value-of select="@type"/>)
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:when test="string(normalize-space($effective-hostname)) != ''">
                      <h4 class="fs-6">Hostnames</h4>
                      <ul>
                        <li><xsl:value-of select="$effective-hostname"/> (<xsl:value-of select="$effective-hostname-source"/>)</li>
                      </ul>
                    </xsl:when>
                    </xsl:choose>
                    <h4 class="fs-6">Ports</h4>
                    <div class="table-responsive">
                      <table class="table table-striped table-bordered align-middle">
                        <thead>
                          <tr class="table-light">
                            <th>Port</th>
                            <th>Protocol</th>
                            <th>State</th>
                            <th>Reason</th>
                            <th>Service</th>
                            <th>Product</th>
                            <th>Version</th>
                            <th>Extra Info</th>
                            <th>CPE</th>
                            <th>Scripts</th>
                          </tr>
                        </thead>
                        <tbody>
                          <xsl:for-each select="ports/port">
                            <tr>
                              <td>
                                <xsl:call-template name="render-endpoint-link">
                                  <xsl:with-param name="address" select="ancestor::host[1]/address[not(@addrtype='mac')][1]/@addr"/>
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
                                <xsl:value-of select="state/@state"/>
                              </td>
                              <td>
                                <xsl:value-of select="state/@reason"/>
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
                                <xsl:value-of select="service/@extrainfo"/>
                              </td>
                              <td>
                                <xsl:if test="count(service/cpe) &gt; 0">
                                  <xsl:call-template name="render-nvd-cpe-link">
                                    <xsl:with-param name="cpe" select="service/cpe"/>
                                  </xsl:call-template>
                                </xsl:if>
                              </td>
                              <td>
                                <xsl:call-template name="render-script-output-list"/>
                              </td>
                            </tr>
                          </xsl:for-each>
                        </tbody>
                      </table>
                    </div>
                    <xsl:if test="count(os/osmatch) &gt; 0">
                      <h4 class="fs-6 mt-4">Operating System Detection</h4>
                      <xsl:for-each select="os/osmatch[not(@accuracy &lt; ../osmatch/@accuracy)]">
                        <h5>
                          OS Details:
                          <xsl:value-of select="@name"/>
                          (<xsl:value-of select="@accuracy"/>%)
                        </h5>
                        <xsl:for-each select="osclass">
                          <p><strong>Device Type:</strong><xsl:text> </xsl:text><xsl:value-of select="@type"/><br/><strong>Running:</strong><xsl:text> </xsl:text><xsl:value-of select="normalize-space(concat(@vendor, ' ', @osfamily, ' ', @osgen))"/>
                            <xsl:text> (</xsl:text><xsl:value-of select="@accuracy"/><xsl:text>%)</xsl:text><br/>
                            <strong>OS CPE:</strong>
                            <xsl:text> </xsl:text><xsl:if test="count(cpe) &gt; 0"><xsl:call-template name="render-nvd-cpe-link"><xsl:with-param name="cpe" select="cpe"/></xsl:call-template></xsl:if>
                          </p>
                        </xsl:for-each>
                      </xsl:for-each>
                    </xsl:if>
                    </div>
                  </details>
                </xsl:for-each>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No hosts are marked as up in this scan.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
