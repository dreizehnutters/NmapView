<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-service-inventory">
          <hr class="my-4"/>
          <h2 id="serviceinventory" class="fs-4 mt-5 mb-3 bg-light p-3 rounded"><span class="section-heading-title">Service Summary</span><small class="section-heading-subtitle">Compare service variants by exact detected product and version while preserving host coverage and exposed ports.</small></h2>
          <xsl:choose>
            <xsl:when test="count(//host/ports/port[state/@state='open' and service/@name]) &gt; 0">
              <div class="table-responsive">
                <table id="service-inventory" class="table table-striped table-hover table-bordered align-middle dataTable" role="grid">
                  <thead class="table-light">
                    <tr>
                      <th scope="col" class="service-inventory-name-column">Service Name</th>
                      <th scope="col" class="service-inventory-count-column">Host Count</th>
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
