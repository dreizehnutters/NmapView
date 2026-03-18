<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-scanned-hosts">
          <h2 id="scannedhosts" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Host Overview</h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host) &gt; 0">
              <xsl:call-template name="render-service-distribution"/>
              <div class="table-responsive">
                <table id="table-overview" class="table table-striped table-hover align-middle" role="grid">
                  <thead class="table-light">
                    <tr>
                      <th scope="col">State</th>
                      <th scope="col">Mac</th>
                      <th scope="col">Vendor</th>
                      <th scope="col">OS</th>
                      <th scope="col">Address</th>
                      <th scope="col">Hostname</th>
                      <th scope="col">Open TCP Ports</th>
                      <th scope="col">Open UDP Ports</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select="/nmaprun/host">
                      <tr>
                        <td>
                          <span class="badge bg-warning">
                            <xsl:if test="status/@state='up'">
                              <xsl:attribute name="class">badge bg-success</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="status/@state"/>
                          </span>
                        </td>
                        <td>
                          <xsl:value-of select="address[@addrtype='mac']/@addr"/>
                        </td>
                        <td>
                          <xsl:value-of select="address[@addrtype='mac']/@vendor"/>
                        </td>
                        <td>
                          <xsl:value-of select="os/osmatch[1]/@name"/>
                        </td>
                        <td>
                          <xsl:variable name="ip" select="address[not(@addrtype='mac')][1]/@addr"/>
                          <xsl:call-template name="render-onlinehosts-link">
                            <xsl:with-param name="address" select="$ip"/>
                          </xsl:call-template>
                        </td>
                        <td>
                          <xsl:value-of select="hostnames/hostname/@name"/>
                        </td>
                        <td>
                          <xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/>
                        </td>
                        <td>
                          <xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/>
                        </td>
                      </tr>
                    </xsl:for-each>
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
          <h2 id="onlinehosts" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Host Details</h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host[status/@state='up']) &gt; 0">
              <div class="host-controls mb-3">
                <button type="button" class="btn btn-outline-secondary btn-sm" id="toggle-all-hosts" aria-controls="onlinehosts-list" aria-expanded="false">Expand all</button>
              </div>
              <div class="host-list" id="onlinehosts-list">
                <xsl:for-each select="/nmaprun/host[status/@state='up']">
                  <xsl:variable name="host-id" select="translate(address/@addr, '.:', '--')"/>
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
                          <xsl:with-param name="hostname" select="hostnames/hostname/@name"/>
                        </xsl:call-template>
                      </span>
                    </summary>
                    <div class="host-entry-body">
                    <xsl:if test="count(hostnames/hostname) &gt; 0">
                      <h4 class="fs-6">Hostnames</h4>
                      <ul>
                        <xsl:for-each select="hostnames/hostname">
                          <li><xsl:value-of select="@name"/> (<xsl:value-of select="@type"/>)
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:if>
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
                                <xsl:value-of select="@portid"/>
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
                          <p><strong>Device Type:</strong><xsl:value-of select="@type"/><br/><strong>Running:</strong><xsl:value-of select="@vendor"/><xsl:value-of select="@osfamily"/><xsl:value-of select="@osgen"/>
                            (<xsl:value-of select="@accuracy"/>%)<br/>
                            <strong>OS CPE:</strong>
                            <xsl:if test="count(cpe) &gt; 0"><xsl:call-template name="render-nvd-cpe-link"><xsl:with-param name="cpe" select="cpe"/></xsl:call-template></xsl:if>
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
