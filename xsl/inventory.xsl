<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-service-inventory">
          <hr class="my-4"/>
          <h2 id="serviceinventory" class="fs-4 mt-5 mb-3 bg-light p-3 rounded"><span class="section-heading-title">Service Summary</span><small class="section-heading-subtitle">Compare service variants by exact detected product and version while preserving host coverage and exposed ports.</small></h2>
          <xsl:choose>
            <xsl:when test="count(//host/ports/port[state/@state='open' and service/@name]) &gt; 0">
              <div class="service-inventory-controls mb-3">
                <button type="button" class="btn btn-outline-secondary btn-sm" id="toggle-all-service-inventory" aria-controls="serviceInventoryTableBody" aria-expanded="false">Expand all</button>
              </div>
              <div class="table-responsive">
                <table id="service-inventory" class="table table-hover table-bordered align-middle dataTable" role="grid">
                  <thead class="table-light">
                    <tr>
                      <th scope="col">Host Details</th>
                    </tr>
                  </thead>
                  <tbody id="serviceInventoryTableBody"/>
                </table>
              </div>
              <div id="serviceInventoryData" class="d-none">
                <xsl:for-each select="//host/ports/port[state/@state='open' and service/@name]">
                  <xsl:variable name="effective-hostname">
                    <xsl:call-template name="resolve-effective-hostname"/>
                  </xsl:variable>
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
                  <span class="service-inventory-entry">
                    <xsl:attribute name="data-service">
                      <xsl:call-template name="render-service-name"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-product">
                      <xsl:value-of select="service/@product"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-version">
                      <xsl:value-of select="service/@version"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-extra-info">
                      <xsl:value-of select="service/@extrainfo"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-address">
                      <xsl:value-of select="ancestor::host[1]/address[not(@addrtype='mac')][1]/@addr"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-hostname">
                      <xsl:value-of select="$effective-hostname"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-port">
                      <xsl:value-of select="@portid"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-protocol">
                      <xsl:value-of select="@protocol"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-http-title">
                      <xsl:value-of select="$http-title"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-http-location">
                      <xsl:value-of select="$http-location"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-http-server">
                      <xsl:value-of select="$http-server"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-http-stack">
                      <xsl:value-of select="$http-powered-by-stack"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-http-powered-by">
                      <xsl:value-of select="$http-powered-by-evidence"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-vulners">
                      <xsl:value-of select=".//script[@id='vulners']/@output"/>
                    </xsl:attribute>
                    <xsl:for-each select="script[string(@output) != '' and not(contains(@output, 'ERROR: '))]">
                      <span class="service-inventory-script">
                        <xsl:attribute name="data-id">
                          <xsl:value-of select="@id"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-port">
                          <xsl:value-of select="../@portid"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-protocol">
                          <xsl:value-of select="../@protocol"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-valid-from">
                          <xsl:value-of select="table[@key='validity']/elem[@key='notBefore']"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-valid-to">
                          <xsl:value-of select="table[@key='validity']/elem[@key='notAfter']"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-self-signed">
                          <xsl:choose>
                            <xsl:when test="@id = 'ssl-cert' and normalize-space(concat(table[@key='subject']/elem[@key='commonName'], '|', table[@key='subject']/elem[@key='organizationName'])) != '' and normalize-space(concat(table[@key='subject']/elem[@key='commonName'], '|', table[@key='subject']/elem[@key='organizationName'])) = normalize-space(concat(table[@key='issuer']/elem[@key='commonName'], '|', table[@key='issuer']/elem[@key='organizationName']))">true</xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="@output"/>
                      </span>
                    </xsl:for-each>
                  </span>
                </xsl:for-each>
              </div>
              <xsl:call-template name="render-service-matrix-data"/>
              <xsl:call-template name="render-host-port-matrix-card"/>
              <xsl:call-template name="render-service-port-heatmap-card"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No named open services are available for inventory views.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
