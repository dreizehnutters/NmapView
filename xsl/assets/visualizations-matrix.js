function purgePlotlyElement(elementId) {
  const element = document.getElementById(elementId);
  if (!element) {
    return;
  }

  if (window.Plotly) {
    Plotly.purge(element);
  }
  element.innerHTML = "";
}

function getScopedMatrixHostDivs() {
  return Array.from(document.querySelectorAll("#matrixCount .host")).filter(hostDiv => {
    const address = (hostDiv.getAttribute("data-address") || "").trim();
    return !window.isHostInScope || window.isHostInScope(address);
  });
}

function buildScopedMatrixData() {
  const hostDivs = getScopedMatrixHostDivs();
  const hosts = [];
  const portsSet = new Set();
  const servicesSet = new Set();
  const openServices = {};

  hostDivs.forEach(hostDiv => {
    const host = hostDiv.getAttribute("data-host");
    if (!host) {
      return;
    }

    hosts.push(host);
    openServices[host] = {};

    hostDiv.querySelectorAll("span.port").forEach(span => {
      const port = parseInt(span.getAttribute("data-port"), 10);
      const serviceName = span.getAttribute("data-service") || "";
      if (!Number.isFinite(port)) {
        return;
      }

      openServices[host][port] = serviceName;
      portsSet.add(port);
      servicesSet.add(serviceName);
    });
  });

  return {
    hostDivs,
    hosts,
    openServices,
    ports: Array.from(portsSet).sort((a, b) => a - b),
    services: Array.from(servicesSet).sort()
  };
}

function renderPortHostMatrix(hosts, ports, openServices, matrixConfig) {
  const portHostMatrix = document.getElementById("portHostMatrix");
  if (!portHostMatrix) {
    return;
  }

  if (hosts.length === 0 || ports.length === 0) {
    purgePlotlyElement("portHostMatrix");
    return;
  }

  const fixedPercentile = 0.95;
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
  portHostMatrix.style.height = `${dynamicHeight}px`;
  portHostMatrix.style.width = `${dynamicWidth}px`;
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
    height: dynamicHeight,
    ...getPlotLayoutTheme()
  };

  const anomalyHostThreshold = calculatePercentile(hostCountValues, fixedPercentile);
  const anomalyPortThreshold = calculatePercentile(portCountValues, fixedPercentile);
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
      openServices[host][port] ? String(hostServiceCounts[host] || 0) : "0",
      openServices[host][port] ? String(portHostCounts[port] || 0) : "0",
      openServices[host][port] ? String(anomalyHostThreshold) : "0",
      openServices[host][port] ? String(anomalyPortThreshold) : "0",
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
    hovertemplate: "Host: %{customdata[0]}<br>Port: %{customdata[1]}<br>Service: %{customdata[2]}<br>Open services on host: %{customdata[3]}<br>Hosts with port: %{customdata[4]}<extra></extra>",
    text: zText
  }];

  if (portHostMatrix.data) {
    Plotly.react(portHostMatrix, data, layout, matrixConfig);
    return;
  }

  Plotly.newPlot(portHostMatrix, data, layout, matrixConfig);
}

function renderProtocolPortMatrix(hosts, ports, services, openServices, matrixConfig) {
  const protocolPortMatrix = document.getElementById("protocolPortMatrix");
  if (!protocolPortMatrix) {
    return;
  }

  if (hosts.length === 0 || ports.length === 0 || services.length === 0) {
    purgePlotlyElement("protocolPortMatrix");
    return;
  }

  const portCoverageCounts = Object.fromEntries(
    ports.map(port => [
      port,
      hosts.reduce((count, host) => count + (openServices[host][port] ? 1 : 0), 0)
    ])
  );
  const heatmapPorts = [...ports].sort((a, b) =>
    (portCoverageCounts[b] || 0) - (portCoverageCounts[a] || 0) || a - b
  );
  const z = services.map(service =>
    heatmapPorts.map(port => {
      let count = 0;
      for (const host of hosts) {
        if (openServices[host][port] === service) {
          count += 1;
        }
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
  }) * 1.3225;
  const zText = sortedZ.map(row => row.map(value => (value > 0 ? value.toString() : "")));
  const hoverData = sortedServices.map((service, index) =>
    heatmapPorts.map(port => [String(port), service, String(sortedTotals[index])])
  );
  const yLabels = sortedServices.map((service, index) => `${service} (${sortedTotals[index]})`);

  const data = [{
    z: sortedZ,
    x: heatmapPorts.map(String),
    y: yLabels,
    text: zText,
    customdata: hoverData,
    type: "heatmap",
    colorscale: "BuGn",
    showscale: false,
    hoverongaps: false,
    hovertemplate: "Port: %{customdata[0]}<br>Service: %{customdata[1]}<br>Total: %{customdata[2]}<br>Occurrences: %{z}<extra></extra>",
    texttemplate: "%{text}",
    textfont: { color: "black", size: 12 }
  }];

  const dynamicHeight = Math.max(600, sortedServices.length * heatmapTileSize + 160);
  const dynamicWidth = Math.max(900, heatmapPorts.length * heatmapTileSize + 260);
  protocolPortMatrix.style.height = `${dynamicHeight}px`;
  protocolPortMatrix.style.width = `${dynamicWidth}px`;
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
      automargin: true
    },
    margin: { t: 80, l: 200, r: 50, b: 100 },
    width: dynamicWidth,
    height: dynamicHeight,
    dragmode: false,
    ...getPlotLayoutTheme()
  };

  if (protocolPortMatrix.data) {
    Plotly.react(protocolPortMatrix, data, layout, matrixConfig);
    return;
  }

  Plotly.newPlot(protocolPortMatrix, data, layout, matrixConfig);
}

function renderOpenPortsPerHostChart(hosts, openServices, matrixConfig) {
  const openPortsPerHostChart = document.getElementById("openPortsPerHostChart");
  if (!openPortsPerHostChart) {
    return;
  }

  if (hosts.length === 0) {
    purgePlotlyElement("openPortsPerHostChart");
    return;
  }

  const hostOverviewTable = document.getElementById("table-overview");
  const hostUniquenessScores = buildHostUniquenessScoreMap(hostOverviewTable);
  const hostIssueCounts = new Map();

  if (hostOverviewTable) {
    const hostOverviewHeaders = Array.from(hostOverviewTable.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
    const addressColumnIndex = hostOverviewHeaders.indexOf("Address");
    const hostnameColumnIndex = hostOverviewHeaders.indexOf("Hostname");

    if (addressColumnIndex !== -1) {
      hostOverviewTable.querySelectorAll("tbody tr").forEach(row => {
        const cells = row.querySelectorAll("td");
        if (cells.length <= addressColumnIndex) {
          return;
        }

        const address = (row.dataset.address || cells[addressColumnIndex].textContent || "").trim();
        if (!address || (window.isHostInScope && !window.isHostInScope(address))) {
          return;
        }

        const hostname = hostnameColumnIndex !== -1 && cells.length > hostnameColumnIndex
          ? (cells[hostnameColumnIndex].textContent || "").trim()
          : "";
        const issues = Number.parseInt((row.dataset.issues || "").trim(), 10) || 0;

        hostIssueCounts.set(address, issues);
        if (hostname && hostname !== "N/A") {
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

  function getHostUniquenessDetails(hostLabel) {
    if (hostUniquenessScores.has(hostLabel)) {
      return hostUniquenessScores.get(hostLabel) || null;
    }

    const separatorIndex = hostLabel.indexOf(" - ");
    if (separatorIndex === -1) {
      return hostUniquenessScores.get(hostLabel) || null;
    }

    const address = hostLabel.slice(0, separatorIndex).trim();
    return hostUniquenessScores.get(address) || null;
  }

  const hostOpenPortCounts = hosts
    .map(host => ({
      host,
      tcp: Object.entries(openServices[host] || {}).filter(([, service]) => service.startsWith("tcp:")).length,
      udp: Object.entries(openServices[host] || {}).filter(([, service]) => service.startsWith("udp:")).length,
      issues: getHostIssueCount(host),
      uniquenessDetails: getHostUniquenessDetails(host)
    }))
    .map(entry => ({
      ...entry,
      total: entry.tcp + entry.udp,
      uniqueness: entry.uniquenessDetails && Number.isFinite(entry.uniquenessDetails.score)
        ? entry.uniquenessDetails.score
        : 0,
      uniquenessContributors: entry.uniquenessDetails && Array.isArray(entry.uniquenessDetails.contributors)
        ? entry.uniquenessDetails.contributors
        : []
    }))
    .sort((a, b) => b.total - a.total || a.host.localeCompare(b.host));

  if (hostOpenPortCounts.length === 0) {
    purgePlotlyElement("openPortsPerHostChart");
    return;
  }

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
    text: hostOpenPortCounts.map(entry => (entry.udp > 0 ? `UDP: ${entry.udp}` : "")),
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
    text: hostOpenPortCounts.map(entry => (entry.tcp > 0 ? `TCP: ${entry.tcp}` : "")),
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
  }, {
    type: "scatter",
    mode: "markers",
    y: truncatedHosts,
    x: hostOpenPortCounts.map(entry => entry.uniqueness),
    xaxis: "x2",
    customdata: hostOpenPortCounts.map(entry => [
      entry.host,
      String(entry.tcp),
      String(entry.udp),
      String(entry.total),
      String(entry.issues),
      entry.uniqueness.toFixed(1),
      entry.uniquenessContributors.length > 0
        ? entry.uniquenessContributors.join(", ")
        : "No standout services"
    ]),
    marker: {
      size: 10,
      symbol: "diamond",
      opacity: 0.95,
      color: "#3f5f74",
      line: {
        color: getReportCssVar("--report-surface", "#f7f9fb"),
        width: 1.5
      }
    },
    hovertemplate: "%{customdata[0]}<br>Total open ports: %{customdata[3]}<br>TCP: %{customdata[1]}<br>UDP: %{customdata[2]}<br>Potential issues: %{customdata[4]}<br>Rarity: %{customdata[5]}<br>Drivers: %{customdata[6]}<extra></extra>",
    hoverlabel: {
      bgcolor: "#43505c",
      bordercolor: "#2f3943",
      font: {
        color: "#ffffff"
      }
    },
    showlegend: false,
    cliponaxis: false
  }];

  const dynamicHeight = Math.max(260, hostOpenPortCounts.length * 30 + 42);
  const dynamicWidth = Math.max(1100, Math.min(window.innerWidth - 24, 1700));
  const yCategoryRange = [hostOpenPortCounts.length - 0.5, -0.5];
  openPortsPerHostChart.style.height = `${dynamicHeight}px`;
  openPortsPerHostChart.style.width = `${dynamicWidth}px`;
  openPortsPerHostChart.style.margin = "0 auto";

  const layout = {
    title: "",
    margin: { t: 34, l: 220, r: 90, b: 28 },
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
    xaxis2: {
      title: { text: "Rarity" },
      overlaying: "x",
      side: "top",
      range: [0, 100],
      automargin: true,
      fixedrange: true,
      showgrid: false,
      zeroline: false,
      tickmode: "array",
      tickvals: [0, 20, 40, 60, 80, 100],
      ticktext: ["0", "20", "40", "60", "80", "100"],
      showline: true,
      linecolor: "rgba(0,0,0,0.22)",
      linewidth: 1,
      ticks: "outside",
      ticklen: 6,
      tickcolor: "rgba(0,0,0,0.2)"
    },
    yaxis: {
      automargin: true,
      fixedrange: true,
      categoryorder: "array",
      categoryarray: truncatedHosts,
      range: yCategoryRange,
      showgrid: false,
      tickson: "labels",
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
    bargap: 0.24,
    ...getPlotLayoutTheme()
  };

  if (openPortsPerHostChart.data) {
    Plotly.react(openPortsPerHostChart, data, layout, matrixConfig);
    return;
  }

  Plotly.newPlot(openPortsPerHostChart, data, layout, matrixConfig);
}

function renderHostServiceGraph(hostDivs, hosts, matrixConfig) {
  const hostServiceGraph = document.getElementById("hostServiceGraph");
  if (!hostServiceGraph) {
    return;
  }

  if (hostDivs.length === 0 || hosts.length === 0) {
    purgePlotlyElement("hostServiceGraph");
    return;
  }

  const sortedHosts = [...hosts].sort((a, b) => a.localeCompare(b, undefined, {
    numeric: true,
    sensitivity: "base"
  }));
  const serviceGraphCounts = new Map();
  const hostServiceLabels = new Map();

  hostDivs.forEach(hostDiv => {
    const host = hostDiv.getAttribute("data-host");
    if (!host) {
      return;
    }

    const seenServiceLabels = new Set();
    hostDiv.querySelectorAll("span.port").forEach(span => {
      const graphLabel = (span.getAttribute("data-service-graph-label") || "").trim();
      if (!graphLabel || seenServiceLabels.has(graphLabel)) {
        return;
      }

      seenServiceLabels.add(graphLabel);
      serviceGraphCounts.set(graphLabel, (serviceGraphCounts.get(graphLabel) || 0) + 1);
    });

    hostServiceLabels.set(host, seenServiceLabels);
  });

  const sortedServicesForGraph = Array.from(serviceGraphCounts.entries())
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], undefined, {
      numeric: true,
      sensitivity: "base"
    }))
    .map(([service]) => service);

  const labels = [...sortedHosts, ...sortedServicesForGraph];
  const hostIndex = new Map(sortedHosts.map((host, index) => [host, index]));
  const serviceOffset = sortedHosts.length;
  const serviceIndex = new Map(sortedServicesForGraph.map((service, index) => [service, serviceOffset + index]));
  const source = [];
  const target = [];
  const value = [];

  sortedHosts.forEach(host => {
    const seenServices = hostServiceLabels.get(host) || new Set();
    Array.from(seenServices).forEach(service => {
      source.push(hostIndex.get(host));
      target.push(serviceIndex.get(service));
      value.push(1);
    });
  });

  if (source.length === 0) {
    purgePlotlyElement("hostServiceGraph");
    return;
  }

  const dynamicHeight = Math.max(520, Math.max(sortedHosts.length, sortedServicesForGraph.length) * 24);
  const dynamicWidth = Math.max(1000, Math.min(window.innerWidth - 40, 1600));
  hostServiceGraph.style.height = `${dynamicHeight}px`;
  hostServiceGraph.style.width = `${dynamicWidth}px`;
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
      color: labels.map((_, index) => (index < serviceOffset ? "#6c757d" : "#0d6efd")),
      hovertemplate: "%{label}<extra></extra>"
    },
    link: {
      source: source,
      target: target,
      value: value,
      color: "rgba(13,110,253,0.18)",
      hovertemplate: "%{source.label} -> %{target.label}<extra></extra>"
    }
  }];

  const layout = {
    title: "",
    margin: { t: 20, l: 30, r: 30, b: 20 },
    width: dynamicWidth,
    height: dynamicHeight,
    font: {
      size: 12
    },
    ...getPlotLayoutTheme()
  };

  if (hostServiceGraph.data) {
    Plotly.react(hostServiceGraph, data, layout, matrixConfig);
    return;
  }

  Plotly.newPlot(hostServiceGraph, data, layout, matrixConfig);
}

function renderMatrixVisualizations() {
  if (!window.Plotly) {
    return;
  }

  const matrixConfig = {
    displayModeBar: false,
    scrollZoom: false
  };
  const matrixData = buildScopedMatrixData();

  renderPortHostMatrix(matrixData.hosts, matrixData.ports, matrixData.openServices, matrixConfig);
  renderProtocolPortMatrix(matrixData.hosts, matrixData.ports, matrixData.services, matrixData.openServices, matrixConfig);
  renderOpenPortsPerHostChart(matrixData.hosts, matrixData.openServices, matrixConfig);
  renderHostServiceGraph(matrixData.hostDivs, matrixData.hosts, matrixConfig);
}

window.renderMatrixVisualizations = renderMatrixVisualizations;

document.addEventListener("DOMContentLoaded", function() {
  renderMatrixVisualizations();
});
