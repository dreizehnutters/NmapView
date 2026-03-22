<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-visualization-head-assets">
        <script src="https://cdn.plot.ly/plotly-3.3.0.min.js" crossorigin="anonymous"></script>
  </xsl:template>

  <xsl:template name="render-visualization-styles">
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

          .visualization-grid {
            display: grid;
            gap: 1.1rem;
          }

          .visualization-card {
            border: 1px solid #dee2e6;
            border-radius: 0.9rem;
            background: #ffffff;
            box-shadow: 0 0.35rem 1rem rgba(33, 37, 41, 0.05);
            overflow: hidden;
          }

          .visualization-card-header {
            padding: 1rem 1.1rem 0;
          }

          .visualization-card-title {
            margin: 0;
            font-size: 0.98rem;
            font-weight: 700;
            color: #212529;
          }

          .visualization-card-note {
            margin: 0.35rem 0 0;
            color: #6c757d;
            font-size: 0.92rem;
          }

          .visualization-controls {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 0.85rem;
            margin-top: 0.85rem;
          }

          .visualization-control-group {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            min-width: min(100%, 26rem);
          }

          .visualization-control-label {
            font-size: 0.84rem;
            font-weight: 600;
            color: #495057;
            white-space: nowrap;
          }

          .visualization-control-group input[type="range"] {
            flex: 1 1 auto;
          }

          .visualization-control-value {
            min-width: 7rem;
            font-size: 0.84rem;
            color: #6c757d;
            text-align: right;
            white-space: nowrap;
          }

          .visualization-card-body {
            padding: 0.75rem 0.9rem 1rem;
          }

          .visualization-empty {
            margin-top: 1rem;
          }
  </xsl:template>

  <xsl:template name="render-visualizations">
          <hr class="my-4"/>
          <h2 id="visualizations" class="fs-4 mt-5 mb-3 bg-light p-3 rounded">Visualizations</h2>
          <xsl:choose>
            <xsl:when test="count(/nmaprun/host) &gt; 0">
              <div class="visualization-grid">
                <div class="visualization-card">
                  <div class="visualization-card-header">
                    <h4 class="visualization-card-title">Operating System Distribution</h4>
                    <p class="visualization-card-note">Compare platform families and spot where host coverage clusters.</p>
                  </div>
                  <div class="visualization-card-body">
                    <div id="osTreemap" style="width: 1250px; max-width: 100%; height: 420px; margin: 0 auto;"/>
                  </div>
                </div>
                <xsl:choose>
                  <xsl:when test="count(//host/ports/port[state/@state='open' and service/@name]) &gt; 0">
                    <div id="matrixCount" class="d-none">
                      <xsl:for-each select="//host">
                        <xsl:variable name="effective-hostname">
                          <xsl:call-template name="resolve-effective-hostname"/>
                        </xsl:variable>
                        <div class="host">
                          <xsl:attribute name="data-host">
	                            <xsl:value-of select="address[1]/@addr"/>
	                            <xsl:if test="string(normalize-space($effective-hostname)) != ''">
	                              <xsl:text> - </xsl:text>
	                              <xsl:value-of select="$effective-hostname"/>
	                            </xsl:if>
                          </xsl:attribute>
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
                    <div class="visualization-card">
                      <div class="visualization-card-header">
                        <h4 class="visualization-card-title">Open Ports Per Host</h4>
                        <p class="visualization-card-note">Spot the hosts carrying the widest exposed surface first. Darker bar colors indicate more potential issues for that host.</p>
                      </div>
                      <div class="visualization-card-body">
                        <div id="openPortsPerHostChart" style="width: 100%;"/>
                      </div>
                    </div>
                    <div class="visualization-card">
                      <div class="visualization-card-header">
                        <h4 class="visualization-card-title">Host-Service Relationships</h4>
                        <p class="visualization-card-note">See which services repeat across hosts and where they concentrate.</p>
                      </div>
                      <div class="visualization-card-body">
                        <div id="hostServiceGraph" style="width: 100%;"/>
                      </div>
                    </div>
                    <div class="visualization-card">
                      <div class="visualization-card-header">
                        <h4 class="visualization-card-title">Host-Port Matrix</h4>
                        <p class="visualization-card-note">Find hosts that stand out from the common port exposure pattern. Amber cells mark ports at or below the selected percentile on hosts that also remain at or below that percentile for open services.</p>
                        <div class="visualization-controls" aria-label="Host-Port Matrix controls">
                          <label class="visualization-control-group" for="portMatrixPercentile">
                            <span class="visualization-control-label">Anomaly Percentile</span>
                            <input type="range" id="portMatrixPercentile" min="0.05" max="0.95" step="0.05" value="0.95"/>
                            <span class="visualization-control-value" id="portMatrixPercentileValue">95th percentile</span>
                          </label>
                        </div>
                      </div>
                      <div class="visualization-card-body">
                        <div id="portHostMatrix" style="width: 100%;"/>
                      </div>
                    </div>
                    <div class="visualization-card">
                      <div class="visualization-card-header">
                        <h4 class="visualization-card-title">Service-Port Heatmap</h4>
                        <p class="visualization-card-note">Identify which named services dominate specific ports at a glance.</p>
                      </div>
                      <div class="visualization-card-body">
                        <div id="protocolPortMatrix" style="width: 100%;"/>
                      </div>
                    </div>
                  </xsl:when>
                  <xsl:otherwise>
                    <p class="text-muted fst-italic mb-3 visualization-empty">No named open services are available for service-based visualization plots.</p>
                  </xsl:otherwise>
                </xsl:choose>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="render-empty-state">
                <xsl:with-param name="message" select="'No hosts are available for visualization plots.'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
  </xsl:template>

  <xsl:template name="render-visualization-scripts">
        <script><![CDATA[
          function clamp(value, min, max) {
            return Math.max(min, Math.min(max, value));
          }

          function getDynamicTileSize(columns, rows, options = {}) {
            const maxWidth = options.maxWidth || Math.max(window.innerWidth - 220, 720);
            const maxHeight = options.maxHeight || Math.max(window.innerHeight * 0.7, 520);
            const minSize = options.minSize || 12;
            const maxSize = options.maxSize || 36;

            if (!columns || !rows) {
              return maxSize;
            }

            const widthLimited = Math.floor(maxWidth / columns);
            const heightLimited = Math.floor(maxHeight / rows);
            return clamp(Math.min(widthLimited, heightLimited), minSize, maxSize);
          }

          function truncateLabel(text, maxLength = 42) {
            if (!text || text.length <= maxLength) {
              return text;
            }
            return `${text.slice(0, maxLength - 1)}…`;
          }

          function calculatePercentile(values, percentile) {
            const numbers = (values || [])
              .map(value => Number(value))
              .filter(value => Number.isFinite(value))
              .sort((a, b) => a - b);

            if (numbers.length === 0) {
              return 0;
            }

            const clampedPercentile = clamp(Number(percentile), 0, 1);
            const index = Math.max(0, Math.min(numbers.length - 1, Math.floor((numbers.length - 1) * clampedPercentile)));
            return numbers[index];
          }

          function formatPercentileLabel(percentile) {
            const value = Math.round(clamp(Number(percentile), 0, 1) * 100);
            const remainderTen = value % 10;
            const remainderHundred = value % 100;
            let suffix = "th";

            if (remainderHundred < 11 || remainderHundred > 13) {
              if (remainderTen === 1) suffix = "st";
              else if (remainderTen === 2) suffix = "nd";
              else if (remainderTen === 3) suffix = "rd";
            }

            return `${value}${suffix} percentile`;
          }

          function renderTopServices(sortedServices) {
            const ledger = document.getElementById("topServicesLedger");
            if (!ledger) return;

            ledger.textContent = "";
            sortedServices.slice(0, 5).forEach(([service, count]) => {
              const listItem = document.createElement("li");
              const title = document.createElement("strong");
              const badge = document.createElement("span");

              title.textContent = service;
              badge.className = "badge";
              badge.textContent = String(count);

              listItem.appendChild(title);
              listItem.appendChild(badge);
              ledger.appendChild(listItem);
            });
          }

          function classifyOperatingSystemFamily(name) {
            const normalized = (name || "").toLowerCase();
            if (!normalized || normalized === "unknown") return "unknown";
            if (normalized.includes("windows")) return "windows";
            if (normalized.includes("linux")) return "linux";
            if (normalized.includes("freebsd") || normalized.includes("openbsd") || normalized.includes("netbsd") || normalized.includes("bsd")) return "bsd";
            if (normalized.includes("mac os") || normalized.includes("macos") || normalized.includes("os x") || normalized.includes("darwin")) return "macos";
            if (normalized.includes("cisco") || normalized.includes("router") || normalized.includes("switch") || normalized.includes("embedded")) return "network";
            return "unknown";
          }

          function formatHostDetails(hostDetails) {
            const uniqueHostDetails = [...new Set((hostDetails || []).filter(Boolean))];
            if (uniqueHostDetails.length === 0) {
              return "Host details: N/A";
            }

            uniqueHostDetails.sort((a, b) => a.localeCompare(b, undefined, {
              numeric: true,
              sensitivity: "base"
            }));

            return `Host details:<br>${uniqueHostDetails.join("<br>")}`;
          }
        ]]></script>
        <script><![CDATA[
          document.addEventListener("DOMContentLoaded", function() {
            const serviceChart = document.getElementById("serviceChart");
            if (serviceChart) {
              const serviceCounts = {};

              document.querySelectorAll("#serviceCounts .service").forEach(element => {
                const service = element.getAttribute("data-service");
                const port = element.getAttribute("data-portid");
                const protocol = element.getAttribute("data-porto");

                if (service && port) {
                  const key = `${service} (${protocol}/${port})`;
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

              const traces = sortedServices.map(([service, count], index) => ({
                y: [""],
                x: [count],
                name: service,
                type: "bar",
                orientation: "h",
                marker: {
                  color: colorPalette[index % colorPalette.length]
                },
                text: service,
                hovertext: `Service: ${service}; Hosts: ${count}`,
                textposition: "inside",
                insidetextanchor: "start",
                hoverinfo: "text",
                textfont: {
                  color: "white",
                  size: 12
                }
              }));

              const layout = {
                title: "",
                barmode: "stack",
                height: 250,
                xaxis: {
                  title: "Frequency",
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

              Plotly.newPlot("serviceChart", traces, layout, {
                displayModeBar: false,
                responsive: true
              });

              renderTopServices(sortedServices);
            }

            const hostOverviewTable = document.getElementById("table-overview");
            const hostOverviewRows = Array.from(document.querySelectorAll("#table-overview tbody tr"));

            if (!hostOverviewTable || hostOverviewRows.length === 0) {
              return;
            }

            const hostOverviewHeaders = Array.from(hostOverviewTable.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
            const osColumnIndex = hostOverviewHeaders.indexOf("OS");
            const addressColumnIndex = hostOverviewHeaders.indexOf("Address");
            const hostnameColumnIndex = hostOverviewHeaders.indexOf("Hostname");
            if (osColumnIndex === -1 || addressColumnIndex === -1 || hostnameColumnIndex === -1) {
              return;
            }

            const osMap = new Map();
            hostOverviewRows.forEach(row => {
              const cells = row.querySelectorAll("td");
              if (cells.length <= Math.max(osColumnIndex, addressColumnIndex, hostnameColumnIndex)) {
                return;
              }

              const os = (cells[osColumnIndex].textContent || "").trim() || "Unknown";
              const address = (cells[addressColumnIndex].textContent || "").trim();
              const hostname = (cells[hostnameColumnIndex].textContent || "").trim();
              const hostLabel = address && hostname ? `${address} (${hostname})` : (address || hostname || "N/A");
              const current = osMap.get(os) || { hosts: 0, hostDetails: [] };
              current.hosts += 1;
              current.hostDetails.push(hostLabel);
              osMap.set(os, current);
            });

            const osEntries = Array.from(osMap.entries())
              .map(([os, values]) => ({ os, ...values }))
              .sort((a, b) => b.hosts - a.hosts || a.os.localeCompare(b.os, undefined, {
                numeric: true,
                sensitivity: "base"
              }));

            const osTreemap = document.getElementById("osTreemap");
            if (!osTreemap || osEntries.length === 0) {
              return;
            }

            const familyColorMap = {
              linux: "#0d6efd",
              windows: "#198754",
              bsd: "#fd7e14",
              macos: "#6f42c1",
              network: "#20c997",
              unknown: "#6c757d"
            };
            const familyLightColorMap = {
              linux: "#d7e7ff",
              windows: "#d6f0df",
              bsd: "#ffe5d0",
              macos: "#e2d9f3",
              network: "#d2f4ea",
              unknown: "#e9ecef"
            };
            const familyCounts = {};
            const familyHostDetails = {};
            const treemapLabels = ["Operating Systems"];
            const treemapParents = [""];
            const treemapValues = [osEntries.reduce((total, entry) => total + entry.hosts, 0)];
            const treemapCustomData = [["All OS families", String(treemapValues[0])]];
            const treemapHoverText = [];
            const treemapColors = ["#495057"];
            const treemapWidth = Math.min(1250, osTreemap.parentElement ? osTreemap.parentElement.clientWidth : 1250);
            const treemapHeight = Math.max(315, Math.round(treemapWidth * 0.336));

            osTreemap.style.width = `${treemapWidth}px`;
            osTreemap.style.height = `${treemapHeight}px`;
            osTreemap.style.margin = "0 auto";

            osEntries.forEach(entry => {
              const family = classifyOperatingSystemFamily(entry.os);
              familyCounts[family] = (familyCounts[family] || 0) + entry.hosts;
              familyHostDetails[family] = (familyHostDetails[family] || []).concat(entry.hostDetails || []);
            });

            treemapHoverText.push(`Operating Systems<br>Hosts: ${treemapValues[0]}<br>${formatHostDetails(osEntries.flatMap(entry => entry.hostDetails || []))}`);

            Object.entries(familyCounts)
              .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], undefined, {
                numeric: true,
                sensitivity: "base"
              }))
              .forEach(([family, count]) => {
                treemapLabels.push(family.toUpperCase());
                treemapParents.push("Operating Systems");
                treemapValues.push(count);
                treemapCustomData.push([family, String(count)]);
                treemapHoverText.push(`${family.toUpperCase()}<br>Hosts: ${count}<br>${formatHostDetails(familyHostDetails[family])}`);
                treemapColors.push(familyColorMap[family] || familyColorMap.unknown);
              });

            osEntries.forEach(entry => {
              const family = classifyOperatingSystemFamily(entry.os);
              treemapLabels.push(entry.os);
              treemapParents.push(family.toUpperCase());
              treemapValues.push(entry.hosts);
              treemapCustomData.push([family, String(entry.hosts)]);
              treemapHoverText.push(`${entry.os}<br>Hosts: ${entry.hosts}<br>${formatHostDetails(entry.hostDetails)}`);
              treemapColors.push(familyLightColorMap[family] || familyLightColorMap.unknown);
            });

            Plotly.newPlot("osTreemap", [{
              type: "treemap",
              labels: treemapLabels,
              parents: treemapParents,
              values: treemapValues,
              branchvalues: "total",
              textinfo: "label+value",
              customdata: treemapCustomData,
              hovertext: treemapHoverText,
              marker: {
                colors: treemapColors,
                line: {
                  color: "#ffffff",
                  width: 1
                }
              },
              tiling: {
                packing: "squarify"
              },
              hovertemplate: "%{hovertext}<extra></extra>"
            }], {
              title: "",
              width: treemapWidth,
              height: treemapHeight,
              margin: { t: 10, l: 10, r: 10, b: 10 }
            }, {
              displayModeBar: false,
              responsive: true
            });
          });
        ]]></script>
        <script><![CDATA[
          document.addEventListener("DOMContentLoaded", function() {
            const hostDivs = document.querySelectorAll("#matrixCount .host");
            const hosts = [];
            const portsSet = new Set();
            const servicesSet = new Set();
            const openServices = {};
            const matrixConfig = {
              displayModeBar: false,
              scrollZoom: false
            };

            hostDivs.forEach(hostDiv => {
              const host = hostDiv.getAttribute("data-host");
              hosts.push(host);
              openServices[host] = {};

              hostDiv.querySelectorAll("span.port").forEach(span => {
                const port = parseInt(span.getAttribute("data-port"), 10);
                const serviceName = span.getAttribute("data-service") || "";
                openServices[host][port] = serviceName;
                portsSet.add(port);
                servicesSet.add(serviceName);
              });
            });

            const ports = Array.from(portsSet).sort((a, b) => a - b);
            const portHostMatrix = document.getElementById("portHostMatrix");
            if (portHostMatrix) {
              const percentileInput = document.getElementById("portMatrixPercentile");
              const percentileValue = document.getElementById("portMatrixPercentileValue");
              const sortedHosts = [...hosts].sort((a, b) => a.localeCompare(b, undefined, {
                numeric: true,
                sensitivity: "base"
              }));
              const hostServiceCounts = Object.fromEntries(
                sortedHosts.map(host => [
                  host,
                  Object.values(openServices[host] || {}).filter(Boolean).length
                ])
              );
              const portHostCounts = Object.fromEntries(
                ports.map(port => [
                  port,
                  sortedHosts.reduce((count, host) => count + (openServices[host][port] ? 1 : 0), 0)
                ])
              );
              const hostCountValues = Object.values(hostServiceCounts);
              const portCountValues = Object.values(portHostCounts);
              const tileSize = getDynamicTileSize(ports.length, sortedHosts.length, {
                minSize: 14,
                maxSize: 36
              });
              const dynamicHeight = Math.max(600, sortedHosts.length * tileSize + 160);
              const dynamicWidth = Math.max(900, ports.length * tileSize + 180);
              portHostMatrix.style.height = dynamicHeight + "px";
              portHostMatrix.style.width = dynamicWidth + "px";
              portHostMatrix.style.margin = "0 auto";

              const layout = {
                title: "",
                xaxis: {
                  title: { text: "Port" },
                  side: "top",
                  type: "category",
                  tickangle: -45,
                  automargin: true,
                  ticks: "outside",
                  ticklen: 10,
                  tickcolor: "rgba(0,0,0,0.05)",
                  tickwidth: 1
                },
                yaxis: {
                  title: { text: "Host" },
                  type: "category",
                  autorange: "reversed",
                  automargin: true,
                  ticks: "outside",
                  ticklen: 10,
                  tickcolor: "rgba(0,0,0,0.05)",
                  tickwidth: 1
                },
                margin: { t: 80, l: 120, r: 50, b: 100 },
                dragmode: false,
                width: dynamicWidth,
                height: dynamicHeight
              };

              function renderPortHostMatrix(percentile) {
                const anomalyHostThreshold = calculatePercentile(hostCountValues, percentile);
                const anomalyPortThreshold = calculatePercentile(portCountValues, percentile);
                if (percentileValue) {
                  percentileValue.textContent = formatPercentileLabel(percentile);
                }

                const z = sortedHosts.map(host =>
                  ports.map(port => {
                    const serviceName = openServices[host][port];
                    if (!serviceName) {
                      return 0;
                    }

                    const portHostCount = portHostCounts[port] || 0;
                    const hostServiceCount = hostServiceCounts[host] || 0;
                    if (portHostCount <= anomalyPortThreshold && hostServiceCount <= anomalyHostThreshold) {
                      return 3;
                    }

                    return 1;
                  })
                );

                const zText = sortedHosts.map(host =>
                  ports.map(port => openServices[host][port] || "")
                );
                const hoverData = sortedHosts.map(host =>
                  ports.map(port => [
                    host,
                    String(port),
                    openServices[host][port] || "No open service",
                    openServices[host][port]
                      ? String(hostServiceCounts[host] || 0)
                      : "0",
                    openServices[host][port]
                      ? String(portHostCounts[port] || 0)
                      : "0",
                    openServices[host][port]
                      ? String(anomalyHostThreshold)
                      : "0",
                    openServices[host][port]
                      ? String(anomalyPortThreshold)
                      : "0",
                    openServices[host][port]
                      ? (() => {
                          const portHostCount = portHostCounts[port] || 0;
                          const hostServiceCount = hostServiceCounts[host] || 0;
                          if (portHostCount <= anomalyPortThreshold && hostServiceCount <= anomalyHostThreshold) {
                            return "Port anomaly";
                          }
                          return "Common port exposure";
                        })()
                      : "No open service"
                  ])
                );

                const data = [{
                  z: z,
                  x: ports.map(String),
                  y: sortedHosts,
                  text: zText,
                  customdata: hoverData,
                  type: "heatmap",
                  colorscale: [
                    [0, "#f3f4f6"],
                    [0.332, "#f3f4f6"],
                    [0.333, "#2ca02c"],
                    [0.999, "#2ca02c"],
                    [1, "#f59f00"]
                  ],
                  zmin: 0,
                  zmax: 3,
                  showscale: false,
                  xgap: 2,
                  ygap: 2,
                  hoverongaps: false,
                  hovertemplate: "Host: %{customdata[0]}<br>Port: %{customdata[1]}<br>Service: %{customdata[2]}<br>Open services on host: %{customdata[3]}<br>Hosts with port: %{customdata[4]}<br>Host threshold: %{customdata[5]} service(s)<br>Port threshold: %{customdata[6]} host(s)<br>Class: %{customdata[7]}<extra></extra>",
                  text: zText
                }];

                if (portHostMatrix.data) {
                  Plotly.react("portHostMatrix", data, layout, matrixConfig);
                  return;
                }

                Plotly.newPlot("portHostMatrix", data, layout, matrixConfig);
              }

              const initialPercentile = percentileInput ? Number.parseFloat(percentileInput.value) || 0.5 : 0.5;
              renderPortHostMatrix(initialPercentile);

              if (percentileInput) {
                percentileInput.addEventListener("input", () => {
                  renderPortHostMatrix(Number.parseFloat(percentileInput.value) || 0.5);
                });
              }
            }

            const protocolPortMatrix = document.getElementById("protocolPortMatrix");
            if (!protocolPortMatrix) {
              return;
            }

            const services = Array.from(servicesSet).sort();
            const z = services.map(service =>
              ports.map(port => {
                let count = 0;
                for (const host of hosts) {
                  if (openServices[host][port] === service) count++;
                }
                return count;
              })
            );

            const serviceTotals = z.map(row => row.reduce((a, b) => a + b, 0));
            const sortedIndices = serviceTotals
              .map((total, index) => ({ total, index }))
              .sort((a, b) => b.total - a.total)
              .map(item => item.index);

            const sortedServices = sortedIndices.map(index => services[index]);
            const sortedTotals = sortedIndices.map(index => serviceTotals[index]);
            const sortedZ = sortedIndices.map(index => z[index]);
            const heatmapTileSize = getDynamicTileSize(ports.length, sortedServices.length, {
              minSize: 14,
              maxSize: 36
            });
            const zText = sortedZ.map(row => row.map(value => value > 0 ? value.toString() : ""));
            const hoverData = sortedServices.map((service, index) =>
              ports.map(port => [String(port), service, String(sortedTotals[index])])
            );
            const yLabels = sortedServices.map((service, index) => `${service} (${sortedTotals[index]})`);

            const data = [{
              z: sortedZ,
              x: ports.map(String),
              y: yLabels,
              text: zText,
              customdata: hoverData,
              type: "heatmap",
              colorscale: "Portland",
              showscale: true,
              hoverongaps: false,
              hovertemplate: "Port: %{customdata[0]}<br>Service: %{customdata[1]}<br>Total: %{customdata[2]}<br>Occurrences: %{z}<extra></extra>",
              texttemplate: "%{text}",
              textfont: { color: "black", size: 12 }
            }];

            const dynamicHeight = Math.max(600, sortedServices.length * heatmapTileSize + 160);
            const dynamicWidth = Math.max(900, ports.length * heatmapTileSize + 260);
            protocolPortMatrix.style.height = dynamicHeight + "px";
            protocolPortMatrix.style.width = dynamicWidth + "px";
            protocolPortMatrix.style.margin = "0 auto";

            const layout = {
              title: "",
              xaxis: {
                title: { text: "Port" },
                side: "top",
                type: "category",
                tickangle: -45,
                automargin: true
              },
              yaxis: {
                title: { text: "Service" },
                automargin: true
              },
              margin: { t: 80, l: 200, r: 50, b: 100 },
              width: dynamicWidth,
              height: dynamicHeight,
              dragmode: false
            };

            Plotly.newPlot("protocolPortMatrix", data, layout, matrixConfig);

            const openPortsPerHostChart = document.getElementById("openPortsPerHostChart");
            if (openPortsPerHostChart) {
              const hostOverviewTable = document.getElementById("table-overview");
              const hostIssueCounts = new Map();

              if (hostOverviewTable) {
                const hostOverviewHeaders = Array.from(hostOverviewTable.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
                const addressColumnIndex = hostOverviewHeaders.indexOf("Address");
                const hostnameColumnIndex = hostOverviewHeaders.indexOf("Hostname");
                const issuesColumnIndex = hostOverviewHeaders.indexOf("Pot. Issues");

                if (addressColumnIndex !== -1 && issuesColumnIndex !== -1) {
                  hostOverviewTable.querySelectorAll("tbody tr").forEach(row => {
                    const cells = row.querySelectorAll("td");
                    if (cells.length <= Math.max(addressColumnIndex, issuesColumnIndex)) {
                      return;
                    }

                    const address = (cells[addressColumnIndex].textContent || "").trim();
                    const hostname = hostnameColumnIndex !== -1 && cells.length > hostnameColumnIndex
                      ? (cells[hostnameColumnIndex].textContent || "").trim()
                      : "";
                    const issues = Number.parseInt((cells[issuesColumnIndex].textContent || "").trim(), 10) || 0;

                    if (address) {
                      hostIssueCounts.set(address, issues);
                    }

                    if (address && hostname && hostname !== "N/A") {
                      hostIssueCounts.set(`${address} - ${hostname}`, issues);
                    }
                  });
                }
              }

              function getHostIssueCount(hostLabel) {
                if (hostIssueCounts.has(hostLabel)) {
                  return hostIssueCounts.get(hostLabel) || 0;
                }

                const separatorIndex = hostLabel.indexOf(" - ");
                if (separatorIndex === -1) {
                  return 0;
                }

                const address = hostLabel.slice(0, separatorIndex).trim();
                return hostIssueCounts.get(address) || 0;
              }

              const hostOpenPortCounts = hosts
                .map(host => ({
                  host,
                  tcp: Object.entries(openServices[host]).filter(([, service]) => service.startsWith("tcp:")).length,
                  udp: Object.entries(openServices[host]).filter(([, service]) => service.startsWith("udp:")).length,
                  issues: getHostIssueCount(host)
                }))
                .map(entry => ({
                  ...entry,
                  total: entry.tcp + entry.udp
                }))
                .sort((a, b) => b.total - a.total || a.host.localeCompare(b.host));
              const truncatedHosts = hostOpenPortCounts.map(entry => truncateLabel(entry.host));
              const maxIssueCount = Math.max(...hostOpenPortCounts.map(entry => entry.issues), 0);
              const maxOpenPortTotal = Math.max(...hostOpenPortCounts.map(entry => entry.total), 0);
              const xGuideValues = Array.from({ length: maxOpenPortTotal + 1 }, (_, value) => value);
              const xGuideLines = xGuideValues.map(value => ({
                type: "line",
                xref: "x",
                yref: "paper",
                x0: value,
                x1: value,
                y0: 0,
                y1: 1,
                layer: "above",
                line: {
                  color: value === 0 ? "rgba(0,0,0,0.18)" : "rgba(0,0,0,0.08)",
                  width: value === 0 ? 1.2 : 1
                }
              }));

              function hexToRgb(hex) {
                const normalized = (hex || "").replace("#", "");
                if (normalized.length !== 6) {
                  return { r: 108, g: 117, b: 125 };
                }

                return {
                  r: Number.parseInt(normalized.slice(0, 2), 16),
                  g: Number.parseInt(normalized.slice(2, 4), 16),
                  b: Number.parseInt(normalized.slice(4, 6), 16)
                };
              }

              function rgbToHex(rgb) {
                return `#${[rgb.r, rgb.g, rgb.b]
                  .map(value => clamp(Math.round(value), 0, 255).toString(16).padStart(2, "0"))
                  .join("")}`;
              }

              function blendHexColors(startHex, endHex, ratio) {
                const start = hexToRgb(startHex);
                const end = hexToRgb(endHex);
                const amount = clamp(ratio, 0, 1);

                return rgbToHex({
                  r: start.r + ((end.r - start.r) * amount),
                  g: start.g + ((end.g - start.g) * amount),
                  b: start.b + ((end.b - start.b) * amount)
                });
              }

              function getIssueColor(issues, lightHex, darkHex) {
                if (maxIssueCount <= 0) {
                  return blendHexColors(lightHex, darkHex, 0.55);
                }

                const normalized = issues / maxIssueCount;
                return blendHexColors(lightHex, darkHex, 0.28 + (normalized * 0.72));
              }

              const data = [{
                type: "bar",
                orientation: "h",
                y: truncatedHosts,
                x: hostOpenPortCounts.map(entry => entry.udp),
                text: hostOpenPortCounts.map(entry => entry.udp > 0 ? `UDP: ${entry.udp}` : ""),
                textposition: "inside",
                cliponaxis: false,
                customdata: hostOpenPortCounts.map(entry => [entry.host, String(entry.tcp), String(entry.udp), String(entry.total), String(entry.issues)]),
                marker: {
                  color: hostOpenPortCounts.map(entry => getIssueColor(entry.issues, "#ffe5b4", "#f59f00")),
                  line: {
                    color: hostOpenPortCounts.map(entry => getIssueColor(entry.issues, "#f3c677", "#d17d00")),
                    width: 1.2
                  },
                  pattern: {
                    shape: ""
                  }
                },
                textfont: {
                  color: "#ffffff"
                },
                hovertemplate: "%{customdata[0]}<br>TCP: %{customdata[1]}<br>UDP: %{customdata[2]}<br>Total open ports: %{customdata[3]}<br>Potential issues: %{customdata[4]}<extra></extra>",
                hoverlabel: {
                  bgcolor: "#6c757d",
                  bordercolor: "#495057",
                  font: {
                    color: "#ffffff"
                  }
                }
              }, {
                type: "bar",
                orientation: "h",
                y: truncatedHosts,
                x: hostOpenPortCounts.map(entry => entry.tcp),
                text: hostOpenPortCounts.map(entry => entry.tcp > 0 ? `TCP: ${entry.tcp}` : ""),
                textposition: "inside",
                insidetextanchor: "end",
                cliponaxis: false,
                customdata: hostOpenPortCounts.map(entry => [entry.host, String(entry.tcp), String(entry.udp), String(entry.total), String(entry.issues)]),
                marker: {
                  color: hostOpenPortCounts.map(entry => getIssueColor(entry.issues, "#dbe8ff", "#0d6efd")),
                  line: {
                    color: hostOpenPortCounts.map(entry => getIssueColor(entry.issues, "#9ec5fe", "#0a58ca")),
                    width: 1.2
                  },
                  pattern: {
                    shape: ""
                  }
                },
                textfont: {
                  color: "#ffffff"
                },
                hovertemplate: "%{customdata[0]}<br>TCP: %{customdata[1]}<br>UDP: %{customdata[2]}<br>Total open ports: %{customdata[3]}<br>Potential issues: %{customdata[4]}<extra></extra>",
                hoverlabel: {
                  bgcolor: "#6c757d",
                  bordercolor: "#495057",
                  font: {
                    color: "#ffffff"
                  }
                }
              }];

              const dynamicHeight = Math.max(320, hostOpenPortCounts.length * 28);
              const dynamicWidth = Math.max(900, Math.min(window.innerWidth - 40, 1400));
              openPortsPerHostChart.style.height = dynamicHeight + "px";
              openPortsPerHostChart.style.width = dynamicWidth + "px";
              openPortsPerHostChart.style.margin = "0 auto";

              const layout = {
                title: "",
                margin: { t: 20, l: 220, r: 60, b: 50 },
                width: dynamicWidth,
                height: dynamicHeight,
                xaxis: {
                  title: { text: "Open ports" },
                  automargin: true,
                  fixedrange: true,
                  range: [0, maxOpenPortTotal + 0.5],
                  showgrid: false,
                  zeroline: false,
                  rangemode: "tozero",
                  tickmode: "array",
                  tickvals: xGuideValues,
                  ticktext: xGuideValues.map(String),
                  showline: true,
                  linecolor: "rgba(0,0,0,0.25)",
                  linewidth: 1,
                  ticks: "outside",
                  ticklen: 6,
                  tickcolor: "rgba(0,0,0,0.2)"
                },
                yaxis: {
                  automargin: true,
                  fixedrange: true,
                  autorange: "reversed",
                  showgrid: false,
                  tickson: "boundaries",
                  ticks: "outside",
                  ticklen: 6,
                  tickcolor: "rgba(0,0,0,0.2)",
                  showline: true,
                  linecolor: "rgba(0,0,0,0.25)",
                  linewidth: 1
                },
                shapes: xGuideLines,
                barmode: "stack",
                showlegend: false,
                dragmode: false,
                bargap: 0.1
              };

              Plotly.newPlot("openPortsPerHostChart", data, layout, matrixConfig);
            }

            const hostServiceGraph = document.getElementById("hostServiceGraph");
            if (hostServiceGraph) {
              const sortedHosts = [...hosts].sort((a, b) => a.localeCompare(b, undefined, {
                numeric: true,
                sensitivity: "base"
              }));
              const sortedServicesForGraph = Array.from(servicesSet).sort((a, b) => a.localeCompare(b, undefined, {
                numeric: true,
                sensitivity: "base"
              }));

              const labels = [...sortedHosts, ...sortedServicesForGraph];
              const hostIndex = new Map(sortedHosts.map((host, index) => [host, index]));
              const serviceOffset = sortedHosts.length;
              const serviceIndex = new Map(sortedServicesForGraph.map((service, index) => [service, serviceOffset + index]));
              const source = [];
              const target = [];
              const value = [];

              sortedHosts.forEach(host => {
                const seenServices = new Set();
                Object.values(openServices[host]).forEach(service => {
                  if (!service || seenServices.has(service)) {
                    return;
                  }
                  seenServices.add(service);
                  source.push(hostIndex.get(host));
                  target.push(serviceIndex.get(service));
                  value.push(1);
                });
              });

              if (source.length > 0) {
                const dynamicHeight = Math.max(520, Math.max(sortedHosts.length, sortedServicesForGraph.length) * 24);
                const dynamicWidth = Math.max(1000, Math.min(window.innerWidth - 40, 1600));

                hostServiceGraph.style.height = dynamicHeight + "px";
                hostServiceGraph.style.width = dynamicWidth + "px";
                hostServiceGraph.style.margin = "0 auto";

                const data = [{
                  type: "sankey",
                  arrangement: "snap",
                  node: {
                    pad: 14,
                    thickness: 14,
                    line: {
                      color: "rgba(0,0,0,0.15)",
                      width: 1
                    },
                    label: labels,
                    color: labels.map((_, index) => index < serviceOffset ? "#6c757d" : "#0d6efd"),
                    hovertemplate: "%{label}<extra></extra>"
                  },
                  link: {
                    source: source,
                    target: target,
                    value: value,
                    color: "rgba(13,110,253,0.18)",
                    hovertemplate: "%{source.label} → %{target.label}<extra></extra>"
                  }
                }];

                const layout = {
                  title: "",
                  margin: { t: 20, l: 30, r: 30, b: 20 },
                  width: dynamicWidth,
                  height: dynamicHeight,
                  font: {
                    size: 12
                  }
                };

                Plotly.newPlot("hostServiceGraph", data, layout, {
                  displayModeBar: false,
                  responsive: true
                });
              }
            }
          });
        ]]></script>
  </xsl:template>
</xsl:stylesheet>
