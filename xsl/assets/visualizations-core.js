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

function renderServiceLedger(ledgerId, services, separatorText, options = {}) {
  const ledger = document.getElementById(ledgerId);
  if (!ledger) return;
  const { hostMap = new Map(), linkSingleHost = false } = options;

  ledger.textContent = "";
  (services || []).forEach(([service, count], index) => {
    if (index > 0) {
      const separator = document.createElement("span");
      separator.className = "service-ledger-separator";
      separator.textContent = separatorText;
      ledger.appendChild(separator);
    }

    const listItem = document.createElement("div");
    const title = document.createElement("span");
    const hosts = Array.from(hostMap.get(service) || []);
    const singleHostLink = linkSingleHost && hosts.length === 1 ? hosts[0] : "";
    const badge = singleHostLink
      ? document.createElement("a")
      : document.createElement("span");

    listItem.className = "service-ledger-item";
    listItem.setAttribute("role", "listitem");
    title.className = "service-ledger-name";
    title.textContent = service;
    badge.className = "badge";
    badge.textContent = String(count);
    badge.title = singleHostLink
      ? `Jump to ${singleHostLink}`
      : `${count} host${count === 1 ? "" : "s"}`;
    if (singleHostLink) {
      badge.href = `#onlinehosts-${singleHostLink.replace(/[.:]/g, "-")}`;
    }

    listItem.appendChild(title);
    listItem.appendChild(badge);
    ledger.appendChild(listItem);
  });
}

function renderServiceLedgers(sortedServices, hostMap) {
  const topServices = sortedServices.slice(0, 5);
  const bottomServices = sortedServices.length <= 5
    ? sortedServices.slice()
    : [...sortedServices]
      .sort((a, b) => a[1] - b[1] || a[0].localeCompare(b[0], undefined, {
        numeric: true,
        sensitivity: "base"
      }))
      .slice(0, 5);

  renderServiceLedger("topServicesLedger", topServices, ">", { hostMap });
  renderServiceLedger("bottomServicesLedger", bottomServices, "<", { hostMap, linkSingleHost: true });
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

function normalizeUniquenessService(service) {
  const normalized = (service || "").trim().toLowerCase();
  if (!normalized) {
    return "";
  }

  const separatorIndex = normalized.indexOf(":");
  const protocol = separatorIndex === -1 ? "" : normalized.slice(0, separatorIndex);
  let serviceName = separatorIndex === -1 ? normalized : normalized.slice(separatorIndex + 1);

  if (!serviceName || serviceName === "unknown") {
    return "";
  }

  if (serviceName === "ssl/http" || serviceName === "ssl/https" || serviceName === "https") {
    serviceName = "https";
  }

  return protocol ? `${protocol}:${serviceName}` : serviceName;
}

function formatUniquenessServiceLabel(serviceKey) {
  const normalized = normalizeUniquenessService(serviceKey);
  if (!normalized) {
    return "unknown";
  }

  const separatorIndex = normalized.indexOf(":");
  if (separatorIndex === -1) {
    return normalized;
  }

  const protocol = normalized.slice(0, separatorIndex).toUpperCase();
  const serviceName = normalized.slice(separatorIndex + 1);
  return `${serviceName} (${protocol})`;
}

function setHostUniquenessCell(cell, options = {}) {
  if (!cell) {
    return;
  }

  const {
    score = null,
    rawScore = 0,
    contributors = [],
    isUp = false,
    hasQualifyingServices = false
  } = options;

  cell.textContent = "";

  if (!isUp) {
    cell.dataset.order = "-1";
    cell.dataset.search = "N/A";

    const placeholder = document.createElement("span");
    placeholder.className = "text-muted";
    placeholder.textContent = "N/A";
    cell.appendChild(placeholder);
    return;
  }

  const normalizedScore = Number.isFinite(score) ? score : 0;
  const value = document.createElement("span");
  value.textContent = normalizedScore.toFixed(1);
  if (normalizedScore <= 0) {
    value.className = "text-muted";
  }

  if (contributors.length > 0) {
    value.title = `Relative rarity score within this scan. Raw score: ${rawScore.toFixed(2)}. Top contributors: ${contributors.join(", ")}`;
  } else if (hasQualifyingServices) {
    value.title = `Relative rarity score within this scan. Raw score: ${rawScore.toFixed(2)}. No standout services on this host.`;
  } else {
    value.title = "No qualifying named services on this host.";
  }

  cell.dataset.order = normalizedScore.toFixed(4);
  cell.dataset.search = normalizedScore.toFixed(1);
  cell.appendChild(value);
}

function getHostOverviewRows(hostOverviewTable) {
  if (!hostOverviewTable) {
    return [];
  }

  if (window.jQuery && $.fn.dataTable && $.fn.dataTable.isDataTable(hostOverviewTable)) {
    const tableApi = $(hostOverviewTable).DataTable();
    if (tableApi) {
      return tableApi.rows().nodes().toArray();
    }
  }

  return Array.from(hostOverviewTable.querySelectorAll("tbody tr"));
}

function buildHostUniquenessScoreMap(hostOverviewTable) {
  if (!hostOverviewTable) {
    return new Map();
  }

  const headers = Array.from(hostOverviewTable.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
  const addressColumnIndex = headers.indexOf("Address");
  if (addressColumnIndex === -1) {
    return new Map();
  }

  const rows = getHostOverviewRows(hostOverviewTable);
  if (rows.length === 0) {
    return new Map();
  }

  const upRows = rows.filter(row => (row.dataset.state || "").trim() === "up");
  const totalUpHosts = upRows.length;
  const hostServices = new Map();
  const serviceFrequency = new Map();

  document.querySelectorAll("#matrixCount .host").forEach(hostElement => {
    const address = (hostElement.dataset.address || "").trim();
    if (!address) {
      return;
    }

    const uniqueServices = new Map();

    hostElement.querySelectorAll(".port").forEach(portElement => {
      const confidence = Number.parseInt(portElement.dataset.conf || "", 10);
      if (Number.isFinite(confidence) && confidence <= 3) {
        return;
      }

      const serviceKey = normalizeUniquenessService(portElement.dataset.service || "");
      if (!serviceKey) {
        return;
      }

      if (!uniqueServices.has(serviceKey)) {
        uniqueServices.set(serviceKey, {
          key: serviceKey,
          label: formatUniquenessServiceLabel(serviceKey)
        });
      }
    });

    hostServices.set(address, uniqueServices);
    uniqueServices.forEach((_, serviceKey) => {
      serviceFrequency.set(serviceKey, (serviceFrequency.get(serviceKey) || 0) + 1);
    });
  });

  const hostRawScores = new Map();
  let maxRawScore = 0;

  upRows.forEach(row => {
    const cells = row.querySelectorAll("td");
    const address = (row.dataset.address || (cells.length > addressColumnIndex ? cells[addressColumnIndex].textContent : "") || "").trim();
    if (!address) {
      return;
    }
    const services = hostServices.get(address) || new Map();
    const contributors = [];
    let rawScore = 0;

    services.forEach(entry => {
      const frequency = serviceFrequency.get(entry.key) || 0;
      if (!frequency || totalUpHosts <= 1) {
        return;
      }

      const weight = Math.log2(totalUpHosts / frequency);
      if (!Number.isFinite(weight) || weight <= 0) {
        return;
      }

      rawScore += weight;
      contributors.push({
        label: entry.label,
        weight: weight
      });
    });

    contributors.sort((a, b) => b.weight - a.weight || a.label.localeCompare(b.label, undefined, {
      numeric: true,
      sensitivity: "base"
    }));

    hostRawScores.set(address, {
      rawScore,
      contributors: contributors.slice(0, 3).map(entry => `${entry.label} (${entry.weight.toFixed(2)})`),
      hasQualifyingServices: services.size > 0
    });
    maxRawScore = Math.max(maxRawScore, rawScore);
  });

  const hostScores = new Map();
  hostRawScores.forEach((scoreDetails, address) => {
    hostScores.set(address, {
      ...scoreDetails,
      score: maxRawScore > 0 ? (scoreDetails.rawScore / maxRawScore) * 100 : 0
    });
  });

  return hostScores;
}

function initializeHostUniquenessScores() {
  const hostOverviewTable = document.getElementById("table-overview");
  if (!hostOverviewTable) {
    return new Map();
  }

  const headers = Array.from(hostOverviewTable.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
  const addressColumnIndex = headers.indexOf("Address");
  const uniquenessColumnIndex = headers.indexOf("Rarity");
  if (addressColumnIndex === -1 || uniquenessColumnIndex === -1) {
    return new Map();
  }

  const rows = getHostOverviewRows(hostOverviewTable);
  if (rows.length === 0) {
    return new Map();
  }

  const hostScores = buildHostUniquenessScoreMap(hostOverviewTable);

  rows.forEach(row => {
    const cells = row.querySelectorAll("td");
    if (cells.length <= uniquenessColumnIndex) {
      return;
    }

    const cell = cells[uniquenessColumnIndex];
    const isUp = (row.dataset.state || "").trim() === "up";
    if (!isUp) {
      setHostUniquenessCell(cell, { isUp: false });
      return;
    }

    const address = (row.dataset.address || cells[addressColumnIndex].textContent || "").trim();
    const scoreDetails = hostScores.get(address) || {
      score: 0,
      rawScore: 0,
      contributors: [],
      hasQualifyingServices: false
    };

    setHostUniquenessCell(cell, {
      score: scoreDetails.score,
      rawScore: scoreDetails.rawScore,
      contributors: scoreDetails.contributors,
      isUp: true,
      hasQualifyingServices: scoreDetails.hasQualifyingServices
    });
  });

  if (window.jQuery && $.fn.dataTable && $.fn.dataTable.isDataTable(hostOverviewTable)) {
    const tableApi = $(hostOverviewTable).DataTable();
    if (tableApi) {
      tableApi.rows().invalidate("dom").draw(false);
      tableApi.columns.adjust();
      if (tableApi.fixedHeader && typeof tableApi.fixedHeader.adjust === "function") {
        tableApi.fixedHeader.adjust();
      }
    }
  }

  return hostScores;
}

function getCollapsiblePlotTargets(detailsElement) {
  return (detailsElement && detailsElement.dataset.plotTargets
    ? detailsElement.dataset.plotTargets.split(/\s+/)
    : [])
    .map(value => value.trim())
    .filter(Boolean);
}

function refreshVisualizationPlot(plotId) {
  const plotElement = document.getElementById(plotId);
  if (!plotElement || !window.Plotly || !plotElement.data) {
    return;
  }

  if (plotId === "osTreemap") {
    const parentWidth = plotElement.parentElement ? plotElement.parentElement.clientWidth : 0;
    const treemapWidth = Math.min(1250, Math.max(parentWidth || 0, 320));
    const treemapHeight = Math.max(315, Math.round(treemapWidth * 0.336));

    plotElement.style.width = `${treemapWidth}px`;
    plotElement.style.height = `${treemapHeight}px`;
    plotElement.style.margin = "0 auto";
    Plotly.relayout(plotElement, {
      width: treemapWidth,
      height: treemapHeight
    });
  } else if (plotId === "serviceChart") {
    plotElement.style.width = "100%";
    plotElement.style.margin = "0 auto";
    Plotly.relayout(plotElement, {
      autosize: true,
      height: 220
    });
  }

  Plotly.Plots.resize(plotElement);
}

function refreshCollapsibleVisualization(detailsElement) {
  getCollapsiblePlotTargets(detailsElement).forEach(refreshVisualizationPlot);
}

function getReportCssVar(name, fallback) {
  try {
    const value = window.getComputedStyle(document.documentElement).getPropertyValue(name);
    return (value || "").trim() || fallback;
  } catch (error) {
    return fallback;
  }
}

function getPlotLayoutTheme() {
  return {
    paper_bgcolor: getReportCssVar("--report-surface", "#f7f9fb"),
    plot_bgcolor: getReportCssVar("--report-surface", "#f7f9fb")
  };
}

function initializePlotExportButtons() {
  document.querySelectorAll("[data-plot-export]").forEach(button => {
    button.addEventListener("click", () => {
      const plotId = button.getAttribute("data-plot-export");
      const plotElement = plotId ? document.getElementById(plotId) : null;
      if (!plotElement || !window.Plotly) {
        return;
      }

      Plotly.downloadImage(plotElement, {
        format: "png",
        filename: `nmapview-${plotId}`,
        width: plotElement.clientWidth || undefined,
        height: plotElement.clientHeight || undefined,
        scale: 2
      });
    });
  });
}
