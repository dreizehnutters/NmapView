<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-scanned-hosts">
          <h2 id="scannedhosts" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Scanned Hosts</h2>
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
  </xsl:template>
  <xsl:template name="render-online-hosts">
          <hr class="my-4"/>
          <h2 id="onlinehosts" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Online Hosts</h2>
          <div class="accordion" id="accordionOnlineHosts">
            <xsl:for-each select="/nmaprun/host[status/@state='up']">
              <div class="accordion-item">
                <h2 class="accordion-header">
                  <xsl:attribute name="id">heading-<xsl:value-of select="translate(address/@addr, '.:', '--')"/></xsl:attribute>
                  <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse">
                    <xsl:attribute name="id">onlinehosts-<xsl:value-of select="translate(address/@addr, '.:', '--')"/></xsl:attribute>
                    <xsl:attribute name="data-bs-target">#collapse-<xsl:value-of select="translate(address/@addr, '.:', '--')"/></xsl:attribute>
                    <xsl:attribute name="aria-controls">collapse-<xsl:value-of select="translate(address/@addr, '.:', '--')"/></xsl:attribute>
                    <xsl:call-template name="render-host-header-label">
                      <xsl:with-param name="address" select="address/@addr"/>
                      <xsl:with-param name="mac" select="address[@addrtype='mac']/@addr"/>
                      <xsl:with-param name="vendor" select="address[@addrtype='mac']/@vendor"/>
                      <xsl:with-param name="hostname" select="hostnames/hostname/@name"/>
                    </xsl:call-template>
                  </button>
                </h2>
                <div>
                  <xsl:attribute name="id">collapse-<xsl:value-of select="translate(address/@addr, '.:', '--')"/></xsl:attribute>
                  <xsl:attribute name="class">accordion-collapse collapse</xsl:attribute>
                  <xsl:attribute name="aria-labelledby">heading-<xsl:value-of select="translate(address/@addr, '.:', '--')"/></xsl:attribute>
                  <xsl:attribute name="data-bs-parent">#accordionOnlineHosts</xsl:attribute>
                  <div class="accordion-body">
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
                </div>
              </div>
            </xsl:for-each>
          </div>
  </xsl:template>
</xsl:stylesheet>
