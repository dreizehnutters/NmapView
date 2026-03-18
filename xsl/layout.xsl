<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-head">
      <head>
        <meta name="referrer" content="no-referrer"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.1/b-3.2.3/b-colvis-3.2.3/b-html5-3.2.3/b-print-3.2.3/fh-4.0.2/datatables.min.css" rel="stylesheet" integrity="sha384-npHSxFxHOYzZ5rh7dTSWQz9iiFPD5EpGhraeLyrNOwAtnwNrZfEbDcA4aFwnYQKL" crossorigin="anonymous"/>
        <script src="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.1/b-3.2.3/b-colvis-3.2.3/b-html5-3.2.3/b-print-3.2.3/fh-4.0.2/datatables.min.js" integrity="sha384-AG5MJFbmBt6aryW6LS46cM1vt7UNBHkLZiCWbnKHdW3B+a3iZjlcZybzBx57ayaY" crossorigin="anonymous"/>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js" integrity="sha384-VFQrHzqBh5qiJIU0uGU5CIW3+OWpdGGJM9LBnGbuIH2mkICcFZ7lPd/AAtI7SNf7" crossorigin="anonymous"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js" integrity="sha384-/RlQG9uf0M2vcTw3CX7fbqgbj/h8wKxw7C3zu9/GxcBPRKOEcESxaxufwRXqzq6n" crossorigin="anonymous"/>
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
  </xsl:template>
  <xsl:template name="render-navbar">
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
  </xsl:template>
  <xsl:template name="render-summary">
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
  </xsl:template>
  <xsl:template name="render-footer">
        <hr class="my-3"/>
        <footer class="footer bg-light py-3">
          <div class="container">
            <p class="text-muted mb-0">
              If you have any questions, encounter a bug, or have suggestions for improvements, please don’t hesitate to <a href="https://github.com/dreizehnutters/NmapView">open an issue on GitHub</a>. Your feedback helps improve the tool for everyone.</p>
          </div>
        </footer>
  </xsl:template>
  <xsl:template name="render-scripts">
        <script><![CDATA[
          function appendText(parent, text) {
            parent.appendChild(document.createTextNode(text));
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

          function formatVulnersChunks() {
            document.querySelectorAll(".vulners-chunks").forEach(container => {
              const raw = container.getAttribute("data-raw") || "";
              if (!raw.trim()) {
                return;
              }

              const cleaned = raw.replace(/\r\n/g, "\n").trim();
              const chunks = cleaned.split(/\n\s*\n/).slice(0, 5);
              const fragment = document.createDocumentFragment();
              let hasLinks = false;

              chunks.forEach(chunk => {
                const lines = chunk.trim().split(/\n+/).map(line => line.trim());
                if (lines.length < 4) return;

                const id = lines[0];
                const type = lines[2];
                const score = lines[3];
                if (!id || !type) return;

                const wrapper = document.createElement("div");
                const label = document.createElement("strong");
                const link = document.createElement("a");

                wrapper.style.marginBottom = "0.5em";
                label.textContent = `CVSS: ${score}`;
                link.href = `https://vulners.com/${type}/${id}`;
                link.target = "_blank";
                link.rel = "noopener noreferrer";
                link.textContent = id;

                wrapper.appendChild(label);
                appendText(wrapper, " - ");
                wrapper.appendChild(link);
                fragment.appendChild(wrapper);
                hasLinks = true;
              });

              container.textContent = "";
              if (hasLinks) {
                container.appendChild(fragment);
                return;
              }

              const emptyState = document.createElement("em");
              emptyState.style.color = "#999";
              emptyState.textContent = "No valid Vulners links found";
              container.appendChild(emptyState);
            });
          }

          function formatInventoryLists() {
            document.querySelectorAll("td.port-list").forEach(td => {
              const raw = td.getAttribute("data-ports");
              if (!raw) return;

              const ports = raw.split(",").map(port => port.trim());
              const uniquePorts = [...new Set(ports)].sort((a, b) => Number(a) - Number(b));
              const container = td.querySelector(".display-ports");
              if (container) {
                container.textContent = uniquePorts.join(", ");
              }
            });

            document.querySelectorAll("td.host-list").forEach(td => {
              const raw = td.getAttribute("data-hosts");
              if (!raw) return;

              const hosts = raw.split(",").map(host => host.trim());
              const uniqueHosts = [...new Set(hosts)];
              const container = td.querySelector(".display-hosts");
              if (!container) return;

              container.textContent = "";
              uniqueHosts.forEach((ip, index) => {
                if (index > 0) {
                  appendText(container, ", ");
                }

                const anchor = document.createElement("a");
                anchor.href = `#onlinehosts-${ip.replace(/[.:]/g, "-")}`;
                anchor.textContent = ip;
                container.appendChild(anchor);
              });
            });
          }

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
                  const headers = dt.columns().header().toArray().map(h => $(h).text().trim());

                  const data = dt.rows({ search: 'applied' }).nodes().toArray().map(row => {
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
              dom: '<"d-flex justify-content-between align-items-center mb-2"lfB>rtip',
              stateSave: true,
              buttons: buttons
            });
          }

        ]]></script>
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

            renderTopServices(sortedServices);
        });
        </script>
        <script>
          document.addEventListener("DOMContentLoaded", function() {
            formatVulnersChunks();
            formatInventoryLists();
          });
        </script>

        <script><![CDATA[
          document.addEventListener("DOMContentLoaded", function() {
            const hostDivs = document.querySelectorAll("#matrixCount .host");
            const hosts = [];
            const portsSet = new Set();
            const servicesSet = new Set();
            const openServices = {};

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
            const matrixConfig = {
              displayModeBar: false,
              scrollZoom: false
            };

            const portHostMatrix = document.getElementById("portHostMatrix");
            if (portHostMatrix) {
              const z = hosts.map(host =>
                ports.map(port => openServices[host][port] ? 1 : 0)
              );

              const zText = hosts.map(host =>
                ports.map(port => openServices[host][port] || "")
              );

              const data = [{
                z: z,
                x: ports.map(String),
                y: hosts,
                text: zText,
                type: "heatmap",
                colorscale: [[0, "white"], [1, "#2ca02c"]],
                showscale: false,
                hoverongaps: false,
                hoverinfo: "x+y+text",
                text: zText
              }];

              const dynamicHeight = Math.max(600, hosts.length * 20);
              portHostMatrix.style.height = dynamicHeight + "px";

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
                width: window.innerWidth * 0.95,
                height: dynamicHeight
              };

              Plotly.newPlot("portHostMatrix", data, layout, matrixConfig);
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
            const zText = sortedZ.map(row => row.map(value => value > 0 ? value.toString() : ""));
            const yLabels = sortedServices.map((service, index) => `${service} (${sortedTotals[index]})`);

            const data = [{
              z: sortedZ,
              x: ports.map(String),
              y: yLabels,
              text: zText,
              type: "heatmap",
              colorscale: "Portland",
              showscale: true,
              hoverongaps: false,
              hoverinfo: "x+y+text",
              texttemplate: "%{text}",
              textfont: { color: "black", size: 12 }
            }];

            const dynamicHeight = Math.max(600, sortedServices.length * 20);
            protocolPortMatrix.style.height = dynamicHeight + "px";

            const horizontalLines = yLabels.map((_, index) => ({
              type: "line",
              xref: "paper",
              x0: 0,
              x1: 1,
              yref: "y",
              y0: index + 0.5,
              y1: index + 0.5,
              line: {
                color: "rgba(0,0,0,0.2)",
                width: 1
              }
            }));

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
              width: window.innerWidth * 0.95,
              height: dynamicHeight,
              dragmode: false,
              shapes: horizontalLines
            };

            Plotly.newPlot("protocolPortMatrix", data, layout, matrixConfig);
          });
        ]]></script>

        <script>console.log("Made by dreizehnutters")</script>
  </xsl:template>
</xsl:stylesheet>
