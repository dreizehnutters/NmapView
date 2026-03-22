<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-open-services">
          <hr class="my-4"/>
          <h2 id="openservices" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Open Services</h2>
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
                            <xsl:value-of select="@portid"/>
                          </td>
                          <td>
                            <xsl:value-of select="@protocol"/>
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
                </span>
              </xsl:for-each>
            </xsl:for-each>
          </div>
  </xsl:template>

  <xsl:template name="render-service-distribution">
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host/ports/port[state/@state='open']) &gt; 0">
              <xsl:call-template name="render-service-counts-data"/>
              <div class="my-4 row" style="margin: 20px 0;">
	                <div id="flex-container" class="d-flex flex-wrap gap-4 align-items-start">
	                  <div class="chart-container" style="flex: 1; max-width: 75%;">
	                    <h4 class="fs-6 mt-4">Service Distribution Across Hosts</h4>
	                    <div id="serviceChart" style="width: 100%; height: 250px"/>
	                  </div>
	                  <div class="list-container">
                    <h3 class="fs-5 mb-3">Most Common Services</h3>
                    <ul id="topServicesLedger" class="list-group" style="font-size: 16px; color: #333; font-weight: bold;">
                    </ul>
                  </div>
                </div>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No open services are available for service distribution.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
