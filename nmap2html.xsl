<?xml version="1.0" encoding="utf-8"?>
<!--
Nmap Bootstrap XSL
This software must not be used by military or secret service organisations.
Andreas Hontzia (@honze_net) & LRVT (@l4rm4nd) & Fabian Kopp (@dreizehnutters)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:key name="serviceGroup" match="host/ports/port[state/@state='open' and service/@name]" use="concat(            substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),            service/@name,            '-',            @protocol          )"/>
  <xsl:key name="uniquePorts" match="port[state/@state='open']" use="@portid"/>
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta name="referrer" content="no-referrer"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.1/b-3.2.3/b-colvis-3.2.3/b-html5-3.2.3/b-print-3.2.3/fh-4.0.2/datatables.min.css" rel="stylesheet" integrity="sha384-npHSxFxHOYzZ5rh7dTSWQz9iiFPD5EpGhraeLyrNOwAtnwNrZfEbDcA4aFwnYQKL" crossorigin="anonymous"/>
        <script src="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.1/b-3.2.3/b-colvis-3.2.3/b-html5-3.2.3/b-print-3.2.3/fh-4.0.2/datatables.min.js" integrity="sha384-AG5MJFbmBt6aryW6LS46cM1vt7UNBHkLZiCWbnKHdW3B+a3iZjlcZybzBx57ayaY" crossorigin="anonymous"/>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js" integrity="sha384-VFQrHzqBh5qiJIU0uGU5CIW3+OWpdGGJM9LBnGbuIH2mkICcFZ7lPd/AAtI7SNf7" crossorigin="anonymous"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js" integrity="sha384-/RlQG9uf0M2vcTw3CX7fbqgbj/h8wKxw7C3zu9/GxcBPRKOEcESxaxufwRXqzq6n" crossorigin="anonymous"/>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.bundle.min.js" integrity="sha384-mZ3q69BYmd4GxHp59G3RrsaFdWDxVSoqd7oVYuWRm2qiXrduT63lQtlhdD9lKbm3" crossorigin="anonymous"/>
        <script src="https://cdn.plot.ly/plotly-3.0.1.min.js" integrity="sha384-8cEu0XVLh4s92OG4Ua4ZS75MN//b+0KqyCrhQqaXgHMVHnKC3DNVhwUyH5spa1J2" crossorigin="anonymous"></script>
        <style>
          a {
            text-decoration: none !important;
          }
          ul#topServicesLedger {
            list-style: none;
            padding: 0;
            max-width: 400px;
            margin-top: 2rem;
            font-family: Arial, sans-serif;
          }

          ul#topServicesLedger li {
            background: #f8f9fa;
            border-radius: 6px;
            padding: 10px 15px;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 16px;
            gap: 3rem;
          }

          ul#topServicesLedger .badge {
            background-color: #007bff;
            color: white;
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 14px;
          }
        </style>
        <title>NmapView Report - Interactive Nmap Scan Summary</title>
      </head>
      <body>
        <nav id="mainNavbar" class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
          <div class="container-fluid">
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation"/>
            <div class="collapse navbar-collapse" id="navbarNav">
              <ul class="navbar-nav me-auto">
                <li class="nav-item">
                  <a class="nav-link" href="#scannedhosts">Scanned Hosts</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#openservices">Open Services</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#webservices">Web/SSL Services</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#serviceinventory">Service Inventory</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#onlinehosts">Online Hosts</a>
                </li>
              </ul>
              <ul class="navbar-nav ms-auto">
                <li class="nav-link">
                  Template: V3.0
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="https://github.com/dreizehnutters/NmapView">
                    <svg height="100" width="100" viewbox="0 0 100 100" style="max-height: 42px; width: auto;">
                      <line x1="50" x2="50" y2="33" y1="0" stroke-width="3" stroke="#808080"/>
                      <line x1="25" x2="25" y2="66" y1="33" stroke-width="3" stroke="#808080"/>
                      <line x1="75" x2="75" y2="66" y1="33" stroke-width="3" stroke="#808080"/>
                      <line x1="2" x2="2" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                      <line x1="47" x2="47" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                      <line x1="53" x2="53" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                      <line x1="98" x2="98" y2="99" y1="66" stroke-width="3" stroke="#808080"/>
                    </svg>
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </nav>
        <div class="container" style="min-width: fit-content;">
          <div id="jumbotron-container" class="bg-light p-4 rounded my-5 shadow-sm">
            <h2 class="display-6 text-primary">Port Scanning Results</h2>
            <h5 class="mb-3">
              <small class="text-muted">
                Nmap Version: <xsl:value-of select="/nmaprun/@version"/> <br/>
                Scan Duration: <xsl:value-of select="/nmaprun/@startstr"/> - <xsl:value-of select="/nmaprun/runstats/finished/@timestr"/>
              </small>
            </h5>
            <pre class="border rounded bg-white p-3 overflow-auto" style="white-space: pre-wrap; word-wrap: break-word;">
              <xsl:attribute name="text">
                <xsl:value-of select="/nmaprun/@args"/>
              </xsl:attribute>
              <xsl:value-of select="/nmaprun/@args"/>
            </pre>
            <div class="d-flex gap-3 my-3">
              <p class="mb-0">
                <b class="badge bg-info p-2"><xsl:value-of select="/nmaprun/runstats/hosts/@total"/> Hosts scanned</b>
              </p>
            </div>
            <div class="progress">
              <div class="progress-bar bg-success" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"><xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@up div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute><xsl:value-of select="/nmaprun/runstats/hosts/@up"/> Hosts up</div>
              <div class="progress-bar bg-warning" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"><xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@down div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute><xsl:value-of select="/nmaprun/runstats/hosts/@down"/> Hosts down</div>
            </div>
          </div>
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
                      <a>
                        <xsl:attribute name="href">
                          <xsl:text>#onlinehosts-</xsl:text>
                          <xsl:value-of select="translate($ip, '.:', '--')"/>
                        </xsl:attribute>
                        <xsl:value-of select="$ip"/>
                      </a>
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

          <hr class="my-4"/>
          <h2 id="openservices" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Open Services</h2>
          <div class="my-4 row" style="margin: 20px 0;">
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
            <div id="flex-container" class="d-flex flex-wrap gap-4 align-items-start">
              <div class="chart-container" style="flex: 1; max-width: 75%;">
                <h4 class="fs-6 mt-4">Service Distribution Across Hosts</h4>
                <div id="serviceChart" style="width: 100%; height: 250px"/>
              </div>
              <div class="list-container">
                <h3 class="fs-5 mb-3">Top 5 Services</h3>
                <ul id="topServicesLedger" class="list-group" style="font-size: 16px; color: #333; font-weight: bold;">
                </ul>
              </div>
            </div>
          </div>
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
                  <th scope="col">Extra</th>
                  <th scope="col">CPE</th>
                  <th scope="col">Exploits</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="/nmaprun/host">
                  <xsl:for-each select="ports/port[state/@state='open']">
                    <tr>
                      <td>
                        <xsl:if test="count(../../hostnames/hostname) = 0">N/A</xsl:if>
                        <xsl:if test="count(../../hostnames/hostname) &gt; 0">
                          <xsl:value-of select="../../hostnames/hostname/@name"/>
                        </xsl:if>
                      </td>
                      <td>
                        <xsl:variable name="ip" select="../../address[not(@addrtype='mac')][1]/@addr"/>
                        <a>
                          <xsl:attribute name="href">
                            <xsl:text>#onlinehosts-</xsl:text>
                            <xsl:value-of select="translate($ip, '.:', '--')"/>
                          </xsl:attribute>
                          <xsl:value-of select="$ip"/>
                        </a>
                      </td>
                      <td>
                        <xsl:value-of select="@portid"/>
                      </td>
                      <td>
                        <xsl:value-of select="@protocol"/>
                      </td>
                      <td>
                        <xsl:choose>
                          <xsl:when test="script[@id='ssl-cert']">
    ssl/<xsl:choose><xsl:when test="number(service/@conf) &gt; 5"><xsl:value-of select="service/@name"/></xsl:when><xsl:otherwise>unknown</xsl:otherwise></xsl:choose>
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
                        <xsl:value-of select="service/cpe"/>
                      </td>
                      <td>
                        <div class="vulners-chunks" data-raw="{.//script[@id='vulners']}"/>
                        <script type="text/javascript"><![CDATA[
                            (function() {
                              var container = document.currentScript.previousElementSibling;
                              if (!container) return;
                              var raw = container.getAttribute('data-raw') || '';
                              if (!raw.trim()) {
                                console.warn("No vulners data found for this port.");
                                return;
                              }
                              var cleaned = raw.replace(/\r\n/g, '\n').trim();
                              var chunks = cleaned.split(/\n\s*\n/).slice(0, 5);
                              var links = [];
                              for (var i = 0; i < chunks.length; i++) {
                                var lines = chunks[i].trim().split(/\n+/).map(function(line) {
                                  return line.trim();
                                });

                                if (lines.length >= 4) {
                                  var id = lines[0];
                                  var type = lines[2];
                                  var score = lines[3];
                                  if (id && type) {
                                    var url = 'https://vulners.com/' + type + '/' + id;
                                    var label = 'CVSS: ' + score;
                                    links.push('<div style="margin-bottom: 0.5em;"><strong>' + label + '</strong> - <a href="' + url + '" target="_blank">' + id + '</a></div>');
                                  }
                                }
                              }
                              container.innerHTML = links.length
                                ? links.join('')
                                : '<em style="color: #999;">No valid Vulners links found</em>';
                            })();
                          ]]></script>
                      </td>
                    </tr>
                  </xsl:for-each>
                </xsl:for-each>
              </tbody>
            </table>
          </div>

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
                    <script type="text/javascript">
                      <![CDATA[
                      document.addEventListener("DOMContentLoaded", () => {
                        document.querySelectorAll("td.port-list").forEach(td => {
                          const raw = td.getAttribute("data-ports");
                          if (!raw) return;
                          const ports = raw.split(",").map(p => p.trim());
                          const uniq = [...new Set(ports)].sort((a, b) => Number(a) - Number(b));
                          td.querySelector(".display-ports").textContent = uniq.join(", ");
                        });
                      });
                      ]]>
                    </script>
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
                    <script>
                      <![CDATA[
                        document.addEventListener("DOMContentLoaded", () => {
                          document.querySelectorAll("td.host-list").forEach(td => {
                            const raw = td.getAttribute("data-hosts");
                            if (!raw) return;

                            const hosts = raw.split(",").map(h => h.trim());
                            const uniq = [...new Set(hosts)];

                            const anchors = uniq.map(ip => {
                              const anchor = document.createElement("a");
                              const id = ip.replace(/[.:]/g, "-");
                              anchor.href = `#onlinehosts-${id}`;
                              anchor.textContent = ip;
                              return anchor;
                            });

                            const container = td.querySelector(".display-hosts");
                            container.innerHTML = "";
                            anchors.forEach((a, i) => {
                              if (i > 0) container.append(", ");
                              container.appendChild(a);
                            });
                          });
                        });
                        ]]>
                      </script>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </div>
          <h4 class="fs-6 mt-4">Communication Matrix</h4>
          <div id="portHostMatrix" style="width: 100%;"/>
          <h4 class="fs-6 mt-4">Service Heatmap</h4>
          <div id="protocolPortMatrix" style="width: 100%;"/>

          <hr class="my-4"/>
          <h2 id="webservices" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Web/SSL Services</h2>
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
                    <tr>
                      <td>
                        <xsl:if test="count(../../hostnames/hostname) = 0">N/A</xsl:if>
                        <xsl:if test="count(../../hostnames/hostname) &gt; 0">
                          <xsl:value-of select="../../hostnames/hostname/@name"/>
                        </xsl:if>
                      </td>
                      <td>
                        <xsl:variable name="ip" select="../../address[not(@addrtype='mac')][1]/@addr"/>
                        <a>
                          <xsl:attribute name="href">
                            <xsl:text>#onlinehosts-</xsl:text>
                            <xsl:value-of select="translate($ip, '.:', '--')"/>
                          </xsl:attribute>
                          <xsl:value-of select="$ip"/>
                        </a>
                      </td>
                      <td>
                        <xsl:value-of select="@portid"/>
                      </td>
                      <td>
                        <xsl:choose>
                          <xsl:when test="script[@id='ssl-cert']">
    ssl/<xsl:choose><xsl:when test="number(service/@conf) &gt; 5"><xsl:value-of select="service/@name"/></xsl:when><xsl:otherwise>unknown</xsl:otherwise></xsl:choose>
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
                      </td>
                      <td>
                        <xsl:value-of select="service/@product"/>
                      </td>
                      <td>
                        <xsl:value-of select="service/@version"/>
                      </td>
                      <td>
                        <xsl:choose>
                          <xsl:when test="count(script[@id='http-title']/elem[@key='title']) &gt; 0">
                            <i>
                              <xsl:value-of select="script[@id='http-title']/elem[@key='title']"/>
                            </i>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:if test="count(script[@id='http-title']/@output) &gt; 0">
                              <i>
                                <xsl:value-of select="script[@id='http-title']/@output"/>
                              </i>
                            </xsl:if>
                          </xsl:otherwise>
                        </xsl:choose>
                      </td>
                      <td>
                        <table class="table table-sm table-borderless mb-0">
                          <xsl:if test="script/table[@key='subject']/elem[@key='commonName'] or script/table[@key='subject']/elem[@key='organizationName']">
                            <tr>
                              <td>Subject</td>
                              <td>
                                <i>
                                  <xsl:value-of select="script/table[@key='subject']/elem[@key='commonName']"/>
                                  <xsl:if test="script/table[@key='subject']/elem[@key='organizationName']">
                                    <xsl:text> – </xsl:text>
                                    <xsl:value-of select="script/table[@key='subject']/elem[@key='organizationName']"/>
                                  </xsl:if>
                                </i>
                              </td>
                            </tr>
                          </xsl:if>
                          <xsl:if test="script/table[@key='issuer']/elem[@key='commonName'] or script/table[@key='issuer']/elem[@key='organizationName']">
                            <tr>
                              <td>Issuer</td>
                              <td>
                                <i>
                                  <xsl:value-of select="script/table[@key='issuer']/elem[@key='commonName']"/>
                                  <xsl:if test="script/table[@key='issuer']/elem[@key='organizationName']">
                                    <xsl:text> – </xsl:text>
                                    <xsl:value-of select="script/table[@key='issuer']/elem[@key='organizationName']"/>
                                  </xsl:if>
                                </i>
                              </td>
                            </tr>
                          </xsl:if>
                          <xsl:if test="script/table[@key='validity']/elem[@key='notAfter']">
                            <tr>
                              <td>Expiry</td>
                              <td>
                                <i>
                                  <xsl:value-of select="script/table[@key='validity']/elem[@key='notAfter']"/>
                                </i>
                              </td>
                            </tr>
                          </xsl:if>
                          <xsl:if test="script/elem[@key='sig_algo']">
                            <tr>
                              <td>SigAlgo</td>
                              <td>
                                <i>
                                  <xsl:value-of select="script/elem[@key='sig_algo']"/>
                                </i>
                              </td>
                            </tr>
                          </xsl:if>
                        </table>
                      </td>
                      <xsl:choose>
                        <xsl:when test="count(service/@tunnel) &gt; 0 or service/@name = 'https' or service/@name = 'https-alt'">
                          <td>
                            <xsl:if test="count(../../hostnames/hostname) &gt; 0">
                              <a target="_blank" href="https://{../../hostnames/hostname/@name}:{@portid}">https://<xsl:value-of select="../../hostnames/hostname/@name"/>:<xsl:value-of select="@portid"/></a>
                            </xsl:if>
                            <xsl:if test="count(../../hostnames/hostname) = 0">
                              <a target="_blank" href="https://{../../address/@addr}:{@portid}">https://<xsl:value-of select="../../address/@addr"/>:<xsl:value-of select="@portid"/></a>
                            </xsl:if>
                          </td>
                        </xsl:when>
                        <xsl:otherwise>
                          <td>
                            <xsl:if test="count(../../hostnames/hostname) &gt; 0">
                              <a target="_blank" href="http://{../../hostnames/hostname/@name}:{@portid}">http://<xsl:value-of select="../../hostnames/hostname/@name"/>:<xsl:value-of select="@portid"/></a>
                            </xsl:if>
                            <xsl:if test="count(../../hostnames/hostname) = 0">
                              <a target="_blank" href="http://{../../address/@addr}:{@portid}">http://<xsl:value-of select="../../address/@addr"/>:<xsl:value-of select="@portid"/></a>
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
                    <xsl:value-of select="address/@addr"/>
                    <xsl:if test="address[@addrtype='mac']">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="address[@addrtype='mac']/@addr"/>
                      <xsl:if test="address[@addrtype='mac']/@vendor">
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="address[@addrtype='mac']/@vendor"/>
                      </xsl:if>
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="count(hostnames/hostname) &gt; 0">
                      <xsl:text> - </xsl:text>
                      <xsl:value-of select="hostnames/hostname/@name"/>
                    </xsl:if>
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
                                <xsl:choose>
                                  <xsl:when test="script[@id='ssl-cert']">
    ssl/<xsl:choose><xsl:when test="number(service/@conf) &gt; 5"><xsl:value-of select="service/@name"/></xsl:when><xsl:otherwise>unknown</xsl:otherwise></xsl:choose>
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
                                  <a>
                                    <xsl:attribute name="href">
                            https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=<xsl:value-of select="service/cpe"/>
                          </xsl:attribute>
                                    <xsl:value-of select="service/cpe"/>
                                  </a>
                                </xsl:if>
                              </td>
                              <td>
                                <xsl:if test="count(script) &gt; 0">
                                  <ul class="list-unstyled mb-0">
                                    <xsl:for-each select="script">
                                      <li>
                                        <strong>
                                          <xsl:value-of select="@id"/>
                                        </strong>
                                        <pre class="bg-light p-2 rounded">
                                          <xsl:value-of select="@output"/>
                                        </pre>
                                      </li>
                                    </xsl:for-each>
                                  </ul>
                                </xsl:if>
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
                            <xsl:if test="count(cpe) &gt; 0"><a><xsl:attribute name="href">
                                  https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=<xsl:value-of select="cpe"/>
                                </xsl:attribute><xsl:value-of select="cpe"/></a></xsl:if>
                          </p>
                        </xsl:for-each>
                      </xsl:for-each>
                    </xsl:if>
                  </div>
                </div>
              </div>
            </xsl:for-each>
          </div>
        </div>
        <hr class="my-3"/>
        <footer class="footer bg-light py-3">
          <div class="container">
            <p class="text-muted mb-0">
              If you have any questions, encounter a bug, or have suggestions for improvements, please don’t hesitate to <a href="https://github.com/dreizehnutters/nmap2csv/issues">open an issue on GitHub</a>. Your feedback helps improve the tool for everyone.</p>
          </div>
        </footer>
        <script>
          function initializeDataTable(selector) {
            const buttons = [
              {
                extend: 'copyHtml5',
                text: 'Copy',
                exportOptions: { orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'csvHtml5',
                text: 'CSV',
                fieldSeparator: ';',
                exportOptions: { orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'excelHtml5',
                text: 'Excel',
                autoFilter: true,
                exportOptions: { orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'pdfHtml5',
                text: 'PDF',
                orientation: 'landscape',
                pageSize: 'LEGAL',
                download: 'open',
                exportOptions: {},
                className: 'btn btn-light'
              },
              {
                text: 'JSON',
                className: 'btn btn-light',
                action: function (e, dt, node, config) {
                  const headers = dt.columns().header().toArray().map(h =&gt; $(h).text().trim());

                  const data = dt.rows({ search: 'applied' }).nodes().toArray().map(row =&gt; {
                    const obj = {};
                    $(row).find('td').each(function (i) {
                      obj[headers[i]] = $(this).text().trim();
                    });
                    return obj;
                  });

                  const json = JSON.stringify(data, null, 2);
                  const blob = new Blob([json], { type: 'application/json' });
                  const url = URL.createObjectURL(blob);
                  const a = document.createElement('a');
                  a.href = url;
                  a.download = 'table-export.json';
                  a.click();
                  URL.revokeObjectURL(url);
                }
              }
            ];

            if (selector === '#web-services') {
              buttons.push({
                extend: 'copyHtml5',
                text: 'Copy URLs',
                header: false,
                title: '',
                exportOptions: {  columns: [-1], orthogonal: 'export' },
                className: 'btn btn-light'
              });
            }

            $(selector).DataTable({
              lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
              order: [[0, 'desc']],
              columnDefs: [
                { targets: [0], orderable: true },
                { targets: [1], type: 'ip-address' },
              ],
              dom: '&lt;"d-flex justify-content-between align-items-center mb-2"lfB&gt;rtip',
              stateSave: true,
              buttons: buttons
            });
          }

        </script>
        <script>
          $(document).ready(function() {
              initializeDataTable('#table-services');
              initializeDataTable('#table-overview');
              initializeDataTable('#web-services');
              initializeDataTable('#service-inventory');


              $("a[href^='#onlinehosts-']").click(function(event) {
                  event.preventDefault();
                  $('html,body').animate({
                      scrollTop: ($(this.hash).offset().top - 60)
                  }, 500);
              });
          });
        </script>
        <script>
           document.addEventListener("DOMContentLoaded", function() {
            const serviceCounts = {};

            document.querySelectorAll("#serviceCounts .service").forEach(el => {
                const service = el.getAttribute("data-service");
                const port = el.getAttribute("data-portid");
                const proto = el.getAttribute("data-porto");
                if (service &amp;&amp; port) {
                    const key = `${service} (${proto}/${port})`;
                    serviceCounts[key] = (serviceCounts[key] || 0) + 1;
                }
            });
            const sortedServices = Object.entries(serviceCounts).sort((a, b) => b[1] - a[1]);

            const colorPalette = [
                "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf",
                "#393b79", "#637939", "#8c6d31", "#843c39", "#7b4173",
                "#3182bd", "#f33", "#11b", "#fb0", "#0f0", "#999", "#05a"
            ];

            const traces = sortedServices.map(([service, count], index) =>
                ({
                    y: [''],
                    x: [count],
                    name: service,
                    type: 'bar',
                    orientation: 'h',
                    marker: {
                        color: colorPalette[index % colorPalette.length]
                    },
                    text: service,
                    textposition: 'inside',
                    insidetextanchor: 'start',
                    hoverinfo: 'text+x',
                    textfont: {
                        color: 'white',
                        size: 12
                    }
                }));

            const layout = {
                title: '',
                barmode: 'stack',
                height: 250,
                xaxis: {
                    title: 'Frequency',
                    automargin: true,
                    fixedrange: true,
                    showticklabels: false,
                    showgrid: false
                },
                yaxis: {
                    automargin: true,
                    fixedrange: true,
                    showgrid: false
                },
                showlegend: false,
                margin: {
                    t: 40,
                    b: 80,
                    l: 50,
                    r: 30
                }
            };

            Plotly.newPlot('serviceChart', traces, layout, {
                displayModeBar: false,
                responsive: true
            });

            const ledger = document.getElementById("topServicesLedger");
            sortedServices.slice(0, 5).forEach(([service, count]) => 
            {
                const listItem = document.createElement("li");
                listItem.innerHTML = `<strong>${service}</strong>
                  <span class="badge">${count}</span>`;
                ledger.appendChild(listItem);
            });
        });
        </script>

        <script>
          const hostDivs = document.querySelectorAll("#matrixCount .host");
          const hosts = [];
          const portsSet = new Set();
          const openPorts = {};

          hostDivs.forEach(hostDiv => {
            const host = hostDiv.getAttribute("data-host");
            hosts.push(host);
            openPorts[host] = {};
            const portSpans = hostDiv.querySelectorAll("span.port");
            portSpans.forEach(span => {
              const port = parseInt(span.getAttribute("data-port"), 10);
              const serviceName = span.getAttribute("data-service") || '';
              openPorts[host][port] = serviceName;
              portsSet.add(port);
            });
          });

          const ports = Array.from(portsSet).sort((a, b) => a - b);

          const z = hosts.map(host =>
            ports.map(port => openPorts[host][port] ? 1 : 0)
          );

          const zText = hosts.map(host =>
            ports.map(port => openPorts[host][port] || '')
          );

          const data = [{
            z: z,
            x: ports.map(String),
            y: hosts,
            text: zText,
            type: 'heatmap',
            colorscale: [[0, 'white'], [1, '#2ca02c']],
            showscale: false,
            hoverongaps: false,
            hoverinfo: 'x+y+text',
            text: zText
          }];

          const container = document.getElementById("portHostMatrix");
          const dynamicHeight = Math.max(600, hosts.length * 20);
          container.style.height = dynamicHeight + "px";


          const layout = {
            title: '',
            xaxis: {
              title: { text: 'Port' },
              side: 'top',
              type: 'category',
              tickangle: -45,
              automargin: true,
              ticks: 'outside',
              ticklen: 10,
              tickcolor: 'rgba(0,0,0,0.05)', 
              tickwidth: 1
            },
            yaxis: {
              title: { text: 'Host' },
              type: 'category',
              autorange: 'reversed',
              automargin: true,
              ticks: 'outside',
              ticklen: 10,
              tickcolor: 'rgba(0,0,0,0.05)', 
              tickwidth: 1
            },
            margin: { t: 80, l: 120, r: 50, b: 100 },
            dragmode: false,
            width: window.innerWidth * 0.95,
            height: dynamicHeight
          };

          const config = {
            displayModeBar: false,
            scrollZoom: false
          };

          Plotly.newPlot('portHostMatrix', data, layout, config);
        </script>

        <script>
          (function() {
            let hostDivs = document.querySelectorAll("#matrixCount .host");
            let hosts = [];
            let portsSet = new Set();
            let servicesSet = new Set();
            let openServices = {};

            hostDivs.forEach(hostDiv => {
              let host = hostDiv.getAttribute("data-host");
              hosts.push(host);
              openServices[host] = {};
              let portSpans = hostDiv.querySelectorAll("span.port");
              portSpans.forEach(span => {
                let port = parseInt(span.getAttribute("data-port"), 10);
                let serviceName = span.getAttribute("data-service") || '';
                openServices[host][port] = serviceName;
                portsSet.add(port);
                servicesSet.add(serviceName);
              });
            });

            let ports = Array.from(portsSet).sort((a, b) => a - b);
            let services = Array.from(servicesSet).sort();

            
            let z = services.map(service =>
              ports.map(port => {
                let count = 0;
                for (let host of hosts) {
                  if (openServices[host][port] === service) count++;
                }
                return count;
              })
            );

            
            let serviceTotals = z.map(row => row.reduce((a, b) => a + b, 0));

            
            let sortedIndices = serviceTotals
              .map((total, index) => ({ total, index }))
              .sort((a, b) => b.total - a.total)
              .map(obj => obj.index);

            
            let sortedServices = sortedIndices.map(i => services[i]);
            let sortedTotals = sortedIndices.map(i => serviceTotals[i]);
            let sortedZ = sortedIndices.map(i => z[i]);

            
            let zText = sortedZ.map(row => row.map(val => val > 0 ? val.toString() : ''));

            
            let yLabels = sortedServices.map((service, i) => `${service} (${sortedTotals[i]})`);

            let data = [{
              z: sortedZ,
              x: ports.map(String),
              y: yLabels,
              text: zText,
              type: 'heatmap',
              colorscale: 'Portland',
              showscale: true,
              hoverongaps: false,
              hoverinfo: 'x+y+text',
              texttemplate: '%{text}',
              textfont: { color: 'black', size: 12 }
            }];
          const container = document.getElementById("protocolPortMatrix");
          const dynamicHeight = Math.max(600, sortedServices.length * 20);
          container.style.height = dynamicHeight + "px";

          let horizontalLines = yLabels.map((_, i) => {
            return {
              type: 'line',
              xref: 'paper',
              x0: 0,
              x1: 1,
              yref: 'y',
              y0: i + 0.5,
              y1: i + 0.5,
              line: {
                color: 'rgba(0,0,0,0.2)',
                width: 1
              }
            };
          });

          let layout = {
            title: '',
            xaxis: {
              title: { text: 'Port' },
              side: 'top',
              type: 'category',
              tickangle: -45,
              automargin: true
            },
            yaxis: {
              title: { text: 'Service' },
              automargin: true
            },
            margin: { t: 80, l: 200, r: 50, b: 100 },
            width: window.innerWidth * 0.95,
            height: dynamicHeight,
            dragmode: false,
            shapes: horizontalLines
          };

          Plotly.newPlot('protocolPortMatrix', data, layout, config);
          })();
        </script>

        <script>console.log("Made by dreizehnutters")</script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
