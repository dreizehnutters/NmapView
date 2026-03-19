<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-web-services">
          <hr class="my-4"/>
          <h2 id="webservices" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Web &amp; TLS Services</h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host/ports/port[(@protocol='tcp') and (state/@state='open') and (starts-with(service/@name, 'http') or script[@id='ssl-cert'])]) &gt; 0">
              <div class="table-responsive">
                <table id="web-services" class="table table-striped table-hover table-bordered align-middle dataTable" role="grid">
                  <thead class="table-light">
                    <tr>
                      <th scope="col">Hostname</th>
                      <th scope="col">Address</th>
                      <th scope="col">Port</th>
                      <th scope="col">Service</th>
                      <th scope="col">Product</th>
                      <th scope="col">Version</th>
                      <th scope="col">HTTP-Title</th>
                      <th scope="col">SSL Certificate</th>
                      <th scope="col">URL</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select="/nmaprun/host">
                      <xsl:for-each select="ports/port[(@protocol='tcp') and (state/@state='open') and (starts-with(service/@name, 'http') or script[@id='ssl-cert'])]">
                        <xsl:variable name="hostname" select="../../hostnames/hostname/@name"/>
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
                            <xsl:call-template name="render-service-name"/>
                          </td>
                          <td>
                            <xsl:value-of select="service/@product"/>
                          </td>
                          <td>
                            <xsl:value-of select="service/@version"/>
                          </td>
                          <td>
                            <div class="http-title-block">
                              <xsl:choose>
                                <xsl:when test="count(script[@id='http-title']/elem[@key='title']) &gt; 0">
                                  <i class="http-title-value">
                                    <xsl:attribute name="title">
                                      <xsl:value-of select="script[@id='http-title']/elem[@key='title']"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="script[@id='http-title']/elem[@key='title']"/>
                                  </i>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:if test="count(script[@id='http-title']/@output) &gt; 0">
                                    <i class="http-title-value">
                                      <xsl:attribute name="title">
                                        <xsl:value-of select="script[@id='http-title']/@output"/>
                                      </xsl:attribute>
                                      <xsl:value-of select="script[@id='http-title']/@output"/>
                                    </i>
                                  </xsl:if>
                                </xsl:otherwise>
                              </xsl:choose>
                            </div>
                          </td>
                          <td>
                            <div class="certificate-block">
                              <xsl:call-template name="render-certificate-row">
                                <xsl:with-param name="label" select="'Subject'"/>
                                <xsl:with-param name="primary" select="script/table[@key='subject']/elem[@key='commonName']"/>
                                <xsl:with-param name="secondary" select="script/table[@key='subject']/elem[@key='organizationName']"/>
                              </xsl:call-template>
                              <xsl:call-template name="render-certificate-row">
                                <xsl:with-param name="label" select="'Issuer'"/>
                                <xsl:with-param name="primary" select="script/table[@key='issuer']/elem[@key='commonName']"/>
                                <xsl:with-param name="secondary" select="script/table[@key='issuer']/elem[@key='organizationName']"/>
                              </xsl:call-template>
                              <xsl:call-template name="render-certificate-row">
                                <xsl:with-param name="label" select="'Expiry'"/>
                                <xsl:with-param name="primary" select="script/table[@key='validity']/elem[@key='notAfter']"/>
                              </xsl:call-template>
                              <xsl:call-template name="render-certificate-row">
                                <xsl:with-param name="label" select="'SigAlgo'"/>
                                <xsl:with-param name="primary" select="script/elem[@key='sig_algo']"/>
                              </xsl:call-template>
                            </div>
                          </td>
                          <xsl:choose>
                            <xsl:when test="count(service/@tunnel) &gt; 0 or service/@name = 'https' or service/@name = 'https-alt'">
                              <td>
                                <xsl:if test="string($hostname) != ''">
                                  <xsl:call-template name="render-service-url">
                                    <xsl:with-param name="scheme" select="'https'"/>
                                    <xsl:with-param name="host" select="$hostname"/>
                                    <xsl:with-param name="port" select="@portid"/>
                                  </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="string($hostname) = ''">
                                  <xsl:call-template name="render-service-url">
                                    <xsl:with-param name="scheme" select="'https'"/>
                                    <xsl:with-param name="host" select="$ip"/>
                                    <xsl:with-param name="port" select="@portid"/>
                                  </xsl:call-template>
                                </xsl:if>
                              </td>
                            </xsl:when>
                            <xsl:otherwise>
                              <td>
                                <xsl:if test="string($hostname) != ''">
                                  <xsl:call-template name="render-service-url">
                                    <xsl:with-param name="scheme" select="'http'"/>
                                    <xsl:with-param name="host" select="$hostname"/>
                                    <xsl:with-param name="port" select="@portid"/>
                                  </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="string($hostname) = ''">
                                  <xsl:call-template name="render-service-url">
                                    <xsl:with-param name="scheme" select="'http'"/>
                                    <xsl:with-param name="host" select="$ip"/>
                                    <xsl:with-param name="port" select="@portid"/>
                                  </xsl:call-template>
                                </xsl:if>
                              </td>
                            </xsl:otherwise>
                          </xsl:choose>
                        </tr>
                      </xsl:for-each>
                    </xsl:for-each>
                  </tbody>
                </table>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No web or SSL services were detected in this scan.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
