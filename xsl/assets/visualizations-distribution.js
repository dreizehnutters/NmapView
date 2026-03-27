document.addEventListener("DOMContentLoaded", function() {
  initializePlotExportButtons();
  const serviceChart = document.getElementById("serviceChart");
  if (serviceChart) {
    const serviceCounts = {};
    const serviceHosts = new Map();

    document.querySelectorAll("#serviceCounts .service").forEach(element => {
      const service = element.getAttribute("data-service");
      const port = element.getAttribute("data-portid");
      const protocol = element.getAttribute("data-porto");
      const address = (element.getAttribute("data-address") || "").trim();

      if (service && port) {
        const key = `${service} (${protocol}/${port})`;
        serviceCounts[key] = (serviceCounts[key] || 0) + 1;
        if (address) {
          if (!serviceHosts.has(key)) {
            serviceHosts.set(key, new Set());
          }
          serviceHosts.get(key).add(address);
        }
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
      height: 220,
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
        t: 24,
        b: 34,
        l: 50,
        r: 30
      },
      ...getPlotLayoutTheme()
    };

    Plotly.newPlot("serviceChart", traces, layout, {
      displayModeBar: false,
      responsive: true
    });

    renderServiceLedgers(sortedServices, serviceHosts);
  }

  const hostOverviewTable = document.getElementById("table-overview");
  const hostOverviewRows = Array.from(document.querySelectorAll("#table-overview tbody tr"));

  if (!hostOverviewTable || hostOverviewRows.length === 0) {
    return;
  }

  const hostOverviewHeaders = Array.from(hostOverviewTable.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
  const osColumnIndex = hostOverviewHeaders.indexOf("OS (est.)");
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
  const treemapColors = [getReportCssVar("--report-surface-muted", "#e6ebf0")];
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
    margin: { t: 10, l: 10, r: 10, b: 10 },
    ...getPlotLayoutTheme()
  }, {
    displayModeBar: false,
    responsive: true
  });
});
