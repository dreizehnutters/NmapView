<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-service-inventory">
          <hr class="my-4"/>
          <h2 id="serviceinventory" class="fs-4 mt-5 mb-3 bg-light p-3 rounded d-flex justify-content-between align-items-center">Service Inventory<small class="text-muted ms-auto"><em>Note: Nmap's service detection might produce false positives.</em></small></h2>
          <div id="matrixCount" class="d-none">
            <xsl:for-each select="//host">
              <div class="host" data-host="{(hostnames/hostname/@name)[1] | (address[1]/@addr)[1]}">
                <xsl:for-each select="ports/port[state/@state='open' and service/@name]">
                  <span class="port" data-port="{@portid}" data-conf="{service/@conf}">
                    <xsl:attribute name="data-service">
                      <xsl:value-of select="@protocol"/>
                      <xsl:text>:</xsl:text>
                      <xsl:if test="service/@tunnel = 'ssl'">
                        <xsl:text>ssl/</xsl:text>
                      </xsl:if>
                      <xsl:value-of select="service/@name"/>
                    </xsl:attribute>
                  </span>
                </xsl:for-each>
              </div>
            </xsl:for-each>
          </div>
          <div class="table-responsive">
            <table id="service-inventory" class="table table-striped table-hover table-bordered dataTable align-middle" role="grid">
              <thead class="table-light">
                <tr>
                  <th scope="col">Service Name</th>
                  <th scope="col">Ports</th>
                  <th scope="col">#</th>
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
          <h4 class="fs-6 mt-4">Communication Matrix</h4>
          <div id="portHostMatrix" style="width: 100%;"/>
          <h4 class="fs-6 mt-4">Service Heatmap</h4>
          <div id="protocolPortMatrix" style="width: 100%;"/>
  </xsl:template>
</xsl:stylesheet>
