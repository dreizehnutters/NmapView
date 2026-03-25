<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-web-services">
          <hr class="my-4"/>
          <details id="webtlsservices-panel" class="section-disclosure">
            <summary class="section-disclosure-summary">
              <h2 id="webtlsservices" class="fs-4 mb-0 bg-light p-3 rounded"><span class="section-heading-title">Web/TLS Services</span><small class="section-heading-subtitle">Triage web-facing and/or TLS-enabled services using HTTP fingerprints and certificate details.</small></h2>
            </summary>
            <div class="section-disclosure-body">
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
                      <th scope="col" class="web-http-column">HTTP</th>
                      <th scope="col" class="web-cert-column">Certificate</th>
                      <th scope="col">URL</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select="/nmaprun/host">
                      <xsl:for-each select="ports/port[(@protocol='tcp') and (state/@state='open') and (starts-with(service/@name, 'http') or script[@id='ssl-cert'])]">
                        <xsl:variable name="hostname">
                          <xsl:call-template name="resolve-effective-hostname"/>
                        </xsl:variable>
                        <xsl:variable name="ip" select="../../address[not(@addrtype='mac')][1]/@addr"/>
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
                            <xsl:call-template name="render-service-name"/>
                          </td>
                          <td>
                            <xsl:value-of select="service/@product"/>
                          </td>
                          <td>
                            <xsl:value-of select="service/@version"/>
                          </td>
                          <td class="web-http-column">
                            <div class="http-details-block">
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
                          </td>
                          <td class="web-cert-column">
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
                                <xsl:with-param name="row-class" select="'certificate-expiry-row'"/>
                                <xsl:with-param name="value-class" select="'certificate-expiry-value'"/>
                                <xsl:with-param name="data-valid-from" select="script/table[@key='validity']/elem[@key='notBefore']"/>
                                <xsl:with-param name="data-valid-to" select="script/table[@key='validity']/elem[@key='notAfter']"/>
                              </xsl:call-template>
                              <xsl:call-template name="render-certificate-row">
                                <xsl:with-param name="label" select="'SigAlgo'"/>
                                <xsl:with-param name="primary" select="script/elem[@key='sig_algo']"/>
                              </xsl:call-template>
                            </div>
                          </td>
                          <xsl:choose>
                            <xsl:when test="service/@tunnel = 'ssl' or service/@name = 'https' or service/@name = 'https-alt'">
                              <td>
                                <xsl:call-template name="render-service-url">
                                  <xsl:with-param name="scheme" select="'https'"/>
                                  <xsl:with-param name="host" select="$ip"/>
                                  <xsl:with-param name="port" select="@portid"/>
                                </xsl:call-template>
                              </td>
                            </xsl:when>
                            <xsl:otherwise>
                              <td>
                                <xsl:call-template name="render-service-url">
                                  <xsl:with-param name="scheme" select="'http'"/>
                                  <xsl:with-param name="host" select="$ip"/>
                                  <xsl:with-param name="port" select="@portid"/>
                                </xsl:call-template>
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
                  <xsl:with-param name="message" select="'No Web/TLS services were detected in this scan.'"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            </div>
          </details>
  </xsl:template>
</xsl:stylesheet>
