<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-service-inventory">
          <hr class="my-4"/>
          <h2 id="serviceinventory" class="fs-4 mt-5 mb-3 bg-light p-3 rounded"><span class="section-heading-title">Service Summary</span><small class="section-heading-subtitle">See which services are most common, where they appear, and how broadly they are distributed across hosts.</small></h2>
          <xsl:choose>
            <xsl:when test="count(//host/ports/port[state/@state='open' and service/@name]) &gt; 0">
              <div class="table-responsive">
                <table id="service-inventory" class="table table-striped table-hover table-bordered dataTable align-middle" role="grid">
                  <thead class="table-light">
                    <tr>
                      <th scope="col">Service Name</th>
                      <th scope="col">Ports</th>
                      <th scope="col">Count</th>
                      <th scope="col">Hosts</th>
                    </tr>
                  </thead>
                  <tbody>
                    <xsl:for-each select="//host/ports/port[state/@state='open' and service/@name]
                                          [generate-id() = generate-id(
                                            key('serviceGroup',
                                                concat(
                                                  substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),
                                                  service/@name,
                                                  '-',
                                                  @protocol
                                                )
                                            )[1]
                                          )]">
                      <xsl:variable name="key" select="concat(
                                                  substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),
                                                  service/@name,
                                                  '-',
                                                  @protocol
                                                )" />
                      <tr>
                        <td>
                          <xsl:value-of select="concat(
                                                substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),
                                                service/@name
                                              )"/>
                        </td>
                        <td class="port-list">
                          <xsl:attribute name="data-ports">
                            <xsl:for-each select="key('serviceGroup', $key)">
                              <xsl:sort select="@portid" data-type="number"/>
                              <xsl:value-of select="@portid"/>
                              <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <span class="display-ports">Loading...</span>
                        </td>
                        <td>
                          <xsl:value-of select="count(key('serviceGroup', $key))"/>
                        </td>
                        <td class="host-list">
                          <xsl:attribute name="data-hosts">
                            <xsl:for-each select="key('serviceGroup', $key)">
                              <xsl:variable name="ip" select="ancestor::host/address[not(@addrtype='mac')]/@addr"/>
                              <xsl:if test="not(preceding::host/address[not(@addrtype='mac')]/@addr = $ip)">
                                <xsl:if test="position() != 1">,</xsl:if>
                                <xsl:value-of select="$ip"/>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:attribute>
                          <span class="display-hosts">Loading...</span>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </tbody>
                </table>
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
