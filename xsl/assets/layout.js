function appendText(parent, text) {
  parent.appendChild(document.createTextNode(text));
}

function initializeAboutDialog() {
  const trigger = document.getElementById("aboutDialogTrigger");
  const dialog = document.getElementById("aboutDialog");
  if (!trigger || !dialog) {
    return;
  }

  let returnFocusTarget = trigger;

  function openDialog() {
    returnFocusTarget = document.activeElement instanceof HTMLElement ? document.activeElement : trigger;
    if (typeof dialog.showModal === "function") {
      dialog.showModal();
    } else {
      dialog.setAttribute("open", "open");
    }
  }

  function closeDialog() {
    if (typeof dialog.close === "function") {
      dialog.close();
    } else {
      dialog.removeAttribute("open");
    }

    if (returnFocusTarget && typeof returnFocusTarget.focus === "function") {
      returnFocusTarget.focus();
    }
  }

  trigger.addEventListener("click", event => {
    event.preventDefault();
    openDialog();
  });

  dialog.querySelectorAll("[data-dialog-close='aboutDialog']").forEach(button => {
    button.addEventListener("click", closeDialog);
  });

  dialog.addEventListener("click", event => {
    if (event.target !== dialog) {
      return;
    }

    const rect = dialog.getBoundingClientRect();
    const insideDialog = rect.top <= event.clientY &&
      event.clientY <= rect.bottom &&
      rect.left <= event.clientX &&
      event.clientX <= rect.right;

    if (!insideDialog) {
      closeDialog();
    }
  });

  dialog.addEventListener("close", () => {
    if (returnFocusTarget && typeof returnFocusTarget.focus === "function") {
      returnFocusTarget.focus();
    }
  });
}

async function copyTextToClipboard(text) {
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return;
  }

  const input = document.createElement("textarea");
  input.value = text;
  input.setAttribute("readonly", "");
  input.style.position = "absolute";
  input.style.left = "-9999px";
  document.body.appendChild(input);
  input.select();
  document.execCommand("copy");
  document.body.removeChild(input);
}

let clipboardFeedbackTimer = null;

function showClipboardFeedback(message, isError = false) {
  if (!message) {
    return;
  }

  let feedback = document.getElementById("clipboardFeedback");
  if (!feedback) {
    feedback = document.createElement("div");
    feedback.id = "clipboardFeedback";
    feedback.className = "clipboard-feedback";
    feedback.setAttribute("aria-live", "polite");
    document.body.appendChild(feedback);
  }

  feedback.textContent = message;
  feedback.classList.toggle("is-error", isError);
  feedback.classList.add("is-visible");

  if (clipboardFeedbackTimer) {
    window.clearTimeout(clipboardFeedbackTimer);
  }

  clipboardFeedbackTimer = window.setTimeout(() => {
    feedback.classList.remove("is-visible");
  }, 1400);
}

async function copyTextWithFeedback(text, successMessage, emptyMessage = "Nothing to copy") {
  const normalizedText = String(text || "");
  if (!normalizedText.trim()) {
    showClipboardFeedback(emptyMessage, true);
    return false;
  }

  try {
    await copyTextToClipboard(normalizedText);
    showClipboardFeedback(successMessage || "Copied");
    return true;
  } catch (error) {
    showClipboardFeedback("Copy failed", true);
    return false;
  }
}

function getHostScopeState() {
  if (!window.nmapViewHostScopeState) {
    window.nmapViewHostScopeState = {
      allHosts: new Set(),
      selectedHosts: new Set(),
      pendingSelectedHosts: new Set(),
      dirty: false,
      redrawInProgress: false,
      dataTableFilterRegistered: false
    };
  }

  return window.nmapViewHostScopeState;
}

function normalizeHostAddress(address) {
  return String(address || "").trim();
}

function isHostInScope(address) {
  const normalizedAddress = normalizeHostAddress(address);
  if (!normalizedAddress) {
    return false;
  }

  const state = getHostScopeState();
  if (state.allHosts.size === 0) {
    return true;
  }

  return state.selectedHosts.has(normalizedAddress);
}

function getDataTableExportColumnSelector() {
  return ":visible:not(.not-export)";
}

function isRowIncludedInCurrentExportScope(row) {
  if (!row) {
    return true;
  }

  const address = normalizeHostAddress(row.dataset ? row.dataset.address : "");
  if (!address) {
    return true;
  }

  return isHostInScope(address);
}

function getDataTableExportRowSelector() {
  return function (_rowIndex, _rowData, rowNode) {
    return isRowIncludedInCurrentExportScope(rowNode);
  };
}

function getTableRows(tableId, options = {}) {
  const {
    searchApplied = false,
    requireAddress = false
  } = options;
  const table = document.getElementById(tableId);
  if (!table) {
    return [];
  }

  let rows = [];
  if (window.jQuery && $.fn.dataTable && $.fn.dataTable.isDataTable(table)) {
    const tableApi = $(table).DataTable();
    if (tableApi) {
      rows = tableApi.rows(searchApplied ? { search: "applied" } : undefined).nodes().toArray();
    }
  }

  if (rows.length === 0) {
    rows = Array.from(table.querySelectorAll("tbody tr"));
  }

  if (requireAddress) {
    rows = rows.filter(row => normalizeHostAddress(row.dataset.address));
  }

  return rows;
}

function initializeCpeCopy() {
  document.querySelectorAll(".cpe-copy").forEach(element => {
    element.addEventListener("click", async () => {
      const cpe = element.getAttribute("data-cpe");
      if (!cpe) return;

      try {
        await copyTextToClipboard(cpe);
        const previousTitle = element.getAttribute("title") || "";
        element.setAttribute("title", "Copied");
        element.classList.add("copied");
        window.setTimeout(() => {
          element.setAttribute("title", previousTitle || "Click to copy CPE");
          element.classList.remove("copied");
        }, 1200);
      } catch (error) {
        element.setAttribute("title", "Copy failed");
        window.setTimeout(() => {
          element.setAttribute("title", "Click to copy CPE");
        }, 1200);
      }
    });
  });
}

function parseCertificateExpiry(rawValue) {
  const trimmed = (rawValue || "").trim();
  const match = trimmed.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2}))?$/);
  if (!match) {
    return null;
  }

  const [, year, month, day, hour, minute, second = "00"] = match;
  const timestamp = Date.UTC(
    Number(year),
    Number(month) - 1,
    Number(day),
    Number(hour),
    Number(minute),
    Number(second)
  );
  return Number.isNaN(timestamp) ? null : timestamp;
}

function formatCertificateDayCount(days) {
  if (days === 0) {
    return "today";
  }

  const absoluteDays = Math.abs(days);
  const dayLabel = absoluteDays === 1 ? "day" : "days";
  return days > 0 ? `in ${absoluteDays} ${dayLabel}` : `${absoluteDays} ${dayLabel} ago`;
}

function formatCertificateLifetimeYears(years) {
  const roundedYears = years >= 10 ? Math.round(years * 10) / 10 : Math.round(years * 100) / 100;
  return `${roundedYears} year${roundedYears === 1 ? "" : "s"}`;
}

function buildCertificateExpiryBadge(rawValidFrom, rawExpiry) {
  const dayMs = 24 * 60 * 60 * 1000;
  const msPerYear = 365.2425 * dayMs;
  const normalizedExpiry = String(rawExpiry || "").trim();
  const expiryTimestamp = parseCertificateExpiry(normalizedExpiry);
  if (expiryTimestamp === null) {
    return null;
  }

  const normalizedValidFrom = String(rawValidFrom || "").trim();
  const validFromTimestamp = parseCertificateExpiry(normalizedValidFrom);
  const now = Date.now();
  const daysRemaining = Math.ceil((expiryTimestamp - now) / dayMs);
  const validityYears = validFromTimestamp !== null
    ? (expiryTimestamp - validFromTimestamp) / msPerYear
    : null;
  const isLongLived = validityYears !== null && validityYears >= 10;
  let statusText = "Valid";
  let statusClass = "is-valid";

  if (expiryTimestamp < now) {
    statusText = "Expired";
    statusClass = "is-expired";
  } else if (daysRemaining <= 30) {
    statusText = "Expiring soon";
    statusClass = "is-expiring";
  } else if (isLongLived) {
    statusText = "10y+ lifetime";
    statusClass = "is-long-lived";
  }

  const badge = document.createElement("span");
  badge.className = `certificate-expiry-badge ${statusClass}`;
  badge.textContent = statusText;
  badge.title = isLongLived
    ? `${normalizedValidFrom} to ${normalizedExpiry} (${formatCertificateLifetimeYears(validityYears)})`
    : `${normalizedExpiry} (${formatCertificateDayCount(daysRemaining)})`;
  return badge;
}

function initializeCertificateExpiryAlerts() {
  document.querySelectorAll(".certificate-expiry-value").forEach(element => {
    if (element.querySelector(".certificate-expiry-badge")) {
      return;
    }

    const rawExpiry = (element.textContent || "").trim();
    const rawValidFrom = (element.getAttribute("data-valid-from") || "").trim();
    const badge = buildCertificateExpiryBadge(rawValidFrom, rawExpiry);
    if (badge) {
      element.appendChild(badge);
    }
  });
}

function formatVulnersChunks() {
  document.querySelectorAll(".vulners-chunks").forEach(container => {
    const raw = container.getAttribute("data-raw") || "";
    if (!raw.trim()) {
      return;
    }

    const cleaned = raw.replace(/\r\n/g, "\n").trim();
    const lines = cleaned
      .split("\n")
      .map(line => line.trim())
      .filter(Boolean);
    const entries = [];

    lines.forEach(line => {
      if (!line.includes("\t")) {
        return;
      }

      const parts = line.split("\t").map(part => part.trim()).filter(Boolean);
      if (parts.length < 3) {
        return;
      }

      const [id, score, url] = parts;
      if (!id || !score || !url) {
        return;
      }

      const urlMatch = url.match(/^https:\/\/vulners\.com\/([^/]+)\/(.+)$/);
      if (!urlMatch) {
        return;
      }

      entries.push({
        id,
        score: Number(score),
        scoreText: score,
        href: url
      });
    });

    container.textContent = "";
    if (entries.length > 0) {
      entries.sort((a, b) => b.score - a.score || a.id.localeCompare(b.id, undefined, {
        numeric: true,
        sensitivity: "base"
      }));
      const visibleEntries = entries.slice(0, 5);

      const details = document.createElement("details");
      const summary = document.createElement("summary");
      const list = document.createElement("div");

      details.className = "vulners-details";
      summary.className = "vulners-summary";
      list.className = "vulners-list";

      const findingLabel = entries.length === 1 ? "finding" : "findings";
      summary.textContent = `${entries.length} ${findingLabel}, top CVSS ${entries[0].scoreText}`;

      visibleEntries.forEach(entry => {
        const wrapper = document.createElement("div");
        const label = document.createElement("strong");
        const link = document.createElement("a");

        wrapper.style.marginBottom = "0.5em";
        label.textContent = `CVSS: ${entry.scoreText}`;
        link.href = entry.href;
        link.target = "_blank";
        link.rel = "noopener noreferrer";
        link.textContent = entry.id;

        wrapper.appendChild(label);
        appendText(wrapper, " - ");
        wrapper.appendChild(link);
        list.appendChild(wrapper);
      });

      if (entries.length > visibleEntries.length) {
        const more = document.createElement("div");
        more.style.color = "#6c757d";
        more.textContent = `Showing top ${visibleEntries.length} of ${entries.length} findings`;
        list.appendChild(more);
      }

      details.appendChild(summary);
      details.appendChild(list);
      container.appendChild(details);
      return;
    }

    const emptyState = document.createElement("em");
    emptyState.style.color = "#999";
    emptyState.textContent = "No valid Vulners links found";
    container.appendChild(emptyState);
  });
}

function buildServiceInventoryVariantLabel(product, version) {
  const normalizedProduct = (product || "").trim();
  const normalizedVersion = (version || "").trim();

  if (!normalizedProduct) {
    return "Unknown product/version";
  }

  if (!normalizedVersion) {
    return `${normalizedProduct} (version unknown)`;
  }

  return `${normalizedProduct} ${normalizedVersion}`;
}

function buildServiceInventoryProductGroup(product) {
  const normalizedProduct = (product || "").trim();
  return normalizedProduct || "Unknown product/version";
}

function buildServiceInventoryHostLabel(hostname, address) {
  const normalizedHostname = (hostname || "").trim();
  const normalizedAddress = (address || "").trim();
  return normalizedHostname ? `${normalizedHostname} - ${normalizedAddress}` : normalizedAddress;
}

function compareInventoryText(left, right) {
  return (left || "").localeCompare(right || "", undefined, {
    numeric: true,
    sensitivity: "base"
  });
}

function compareInventoryPortLabels(left, right) {
  const [leftPort, leftProtocol] = String(left || "").split("/");
  const [rightPort, rightProtocol] = String(right || "").split("/");
  return Number(leftPort) - Number(rightPort) || compareInventoryText(leftProtocol, rightProtocol);
}

function formatEndpointBrowserHost(address) {
  const normalizedAddress = String(address || "").trim();
  if (!normalizedAddress) {
    return "";
  }

  return normalizedAddress.includes(":") &&
    !normalizedAddress.startsWith("[") &&
    !normalizedAddress.endsWith("]")
    ? `[${normalizedAddress}]`
    : normalizedAddress;
}

function inferEndpointBrowserScheme(serviceName, protocol) {
  const normalizedService = String(serviceName || "").trim().toLowerCase();
  const normalizedProtocol = String(protocol || "").trim().toLowerCase();

  if (normalizedService.startsWith("ssl/") || normalizedService.includes("https")) {
    return "https";
  }

  return normalizedProtocol === "udp" ? "http" : "http";
}

function createBrowserEndpointLink(address, port, protocol, serviceName, text, className = "endpoint-link") {
  const normalizedAddress = String(address || "").trim();
  const normalizedPort = String(port || "").trim();
  const normalizedProtocol = String(protocol || "").trim().toLowerCase();
  const linkText = String(text || normalizedPort).trim();

  if (!normalizedAddress || !normalizedPort) {
    const fallback = document.createElement("span");
    fallback.textContent = linkText;
    return fallback;
  }

  const link = document.createElement("a");
  const browserHost = formatEndpointBrowserHost(normalizedAddress);
  const browserScheme = inferEndpointBrowserScheme(serviceName, normalizedProtocol);

  link.className = className;
  link.href = `${browserScheme}://${browserHost}:${normalizedPort}`;
  link.target = "_blank";
  link.rel = "noopener noreferrer";
  link.textContent = linkText;
  return link;
}

function formatInventoryPortList(portSet) {
  return Array.from(portSet || []).sort(compareInventoryPortLabels).join(", ");
}

function compareInventoryScriptRecords(left, right) {
  return compareInventoryPortLabels(left.portLabel, right.portLabel) ||
    compareInventoryText(left.id, right.id) ||
    compareInventoryText(left.output, right.output);
}

function compareInventoryHttpRecords(left, right) {
  return compareInventoryPortLabels(left.portLabel, right.portLabel);
}

function appendServiceInventoryDetailRow(container, label, value) {
  const normalizedValue = String(value || "").trim();
  if (!normalizedValue) {
    return;
  }

  const row = document.createElement("div");
  const rowLabel = document.createElement("span");
  const rowValue = document.createElement("span");

  row.className = "service-inventory-http-row";
  rowLabel.className = "service-inventory-http-label";
  rowValue.className = "service-inventory-http-value";
  rowLabel.textContent = `${label}:`;
  rowValue.textContent = normalizedValue;
  row.appendChild(rowLabel);
  row.appendChild(rowValue);
  container.appendChild(row);
}

function shouldSuppressRawHttpScript(scriptId, hasHttpDetails) {
  if (!hasHttpDetails) {
    return false;
  }

  return [
    "http-title",
    "http-server-header",
    "http-headers",
    "fingerprint-strings"
  ].includes(String(scriptId || "").trim());
}

function parseVulnersEntries(raw) {
  const cleaned = String(raw || "").replace(/\r\n/g, "\n").trim();
  if (!cleaned) {
    return [];
  }

  const entries = [];
  cleaned
    .split("\n")
    .map(line => line.trim())
    .filter(Boolean)
    .forEach(line => {
      if (!line.includes("\t")) {
        return;
      }

      const parts = line.split("\t").map(part => part.trim()).filter(Boolean);
      if (parts.length < 3) {
        return;
      }

      const [id, score, url] = parts;
      if (!id || !score || !url || !/^https:\/\/vulners\.com\/[^/]+\/.+$/.test(url)) {
        return;
      }

      entries.push({
        id,
        score: Number(score),
        scoreText: score,
        href: url
      });
    });

  return entries.sort((a, b) => b.score - a.score || compareInventoryText(a.id, b.id));
}

function formatServiceInventoryScriptOutput(scriptRecord) {
  const output = String(scriptRecord && scriptRecord.output ? scriptRecord.output : "").replace(/\r\n/g, "\n");
  if (String(scriptRecord && scriptRecord.id ? scriptRecord.id : "").trim() !== "ssh-hostkey") {
    return output;
  }

  return output
    .split("\n")
    .filter(line => !/^\s*(ssh-rsa|ssh-dss|ssh-ed25519|ecdsa-sha2-[^\s]+|sk-ssh-ed25519[^\s]*|sk-ecdsa-sha2-[^\s]+)\s+/i.test(line))
    .map(line => line.replace(/^\s+/, ""))
    .join("\n")
    .trim();
}

function formatInventoryHostCount(count) {
  return `${count} Host${count === 1 ? "" : "s"}`;
}

function formatInventoryVariantSummary(variants) {
  const knownVariantCount = variants.filter(variant => !variant.isUnknown).length;
  const hasUnknown = variants.some(variant => variant.isUnknown);

  if (knownVariantCount === 0) {
    return "Unknown";
  }

  return `${knownVariantCount} Variant${knownVariantCount === 1 ? "" : "s"}${hasUnknown ? " + Unknown" : ""}`;
}

let serviceInventoryExportRows = [];
const serviceInventoryExportColumns = [
  "Service",
  "Bucket",
  "Host",
  "Port(s)",
  "HTTP Title",
  "HTTP Server",
  "HTTP Location",
  "HTTP Stack",
  "HTTP Powered-By",
  "Vulners",
  "NSE Scripts"
];

function buildServiceInventoryVulnersSummary(vulnersRecords) {
  return vulnersRecords
    .flatMap(record => record.entries.map(entry => {
      const suffix = record.portLabel ? ` (${record.portLabel})` : "";
      return `${entry.id}${suffix} [CVSS ${entry.scoreText}]`;
    }))
    .join("; ");
}

function buildServiceInventoryScriptSummary(scriptRecords, hostDisplayLabel) {
  return scriptRecords.map(scriptRecord => {
    return scriptRecord.portLabel
      ? `${scriptRecord.id} (${hostDisplayLabel} | ${scriptRecord.portLabel})`
      : `${scriptRecord.id} (${hostDisplayLabel})`;
  }).join("; ");
}

function normalizeServiceInventorySearchValue(value) {
  return String(value || "")
    .replace(/https?:\/\//gi, "")
    .replace(/\s+/g, " ")
    .trim();
}

function buildDataTableJsonExportAction(exportName) {
  return function (e, dt) {
    const visibleColumns = dt.columns(getDataTableExportColumnSelector());
    const headerIndexes = visibleColumns.indexes().toArray();
    const headers = visibleColumns.header().toArray().map(h => $(h).text().trim());

    const data = dt.rows({ search: 'applied' }).nodes().toArray()
      .filter(row => isRowIncludedInCurrentExportScope(row))
      .map(row => {
        const obj = {};
        headerIndexes.forEach((columnIndex, i) => {
          const cell = $(row).find('th, td').get(columnIndex);
          obj[headers[i]] = cell ? $(cell).text().trim() : '';
        });
        return obj;
      });

    const json = JSON.stringify(data, null, 2);
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${exportName}.json`;
    a.click();
    URL.revokeObjectURL(url);
  };
}

function getScopedDataTableRows(dt) {
  if (!dt) {
    return [];
  }

  return dt.rows({ search: 'applied' }).nodes().toArray()
    .filter(row => isRowIncludedInCurrentExportScope(row));
}

function buildVisibleDataTableClipboardText(dt) {
  if (!dt) {
    return { text: "", rowCount: 0 };
  }

  const normalizeCell = value => String(value || "").replace(/\r?\n/g, " ").trim();
  const visibleColumns = dt.columns(getDataTableExportColumnSelector());
  const headerIndexes = visibleColumns.indexes().toArray();
  const header = visibleColumns.header().toArray().map(cell => normalizeCell($(cell).text()));
  const body = getScopedDataTableRows(dt).map(row =>
    headerIndexes.map(columnIndex => {
      const cell = $(row).find('th, td').get(columnIndex);
      return normalizeCell(cell ? $(cell).text() : "");
    })
  );
  const lines = [];

  if (header.length > 0) {
    lines.push(header.join("\t"));
  }

  body.forEach(row => {
    lines.push((Array.isArray(row) ? row : []).map(normalizeCell).join("\t"));
  });

  return {
    text: lines.join("\n"),
    rowCount: body.length
  };
}

async function copyVisibleDataTableRows(dt, rowLabel = "row") {
  const { text, rowCount } = buildVisibleDataTableClipboardText(dt);
  await copyTextWithFeedback(
    text,
    `Copied ${rowCount} ${rowLabel}${rowCount === 1 ? "" : "s"}`,
    "Nothing to copy"
  );
}

function formatServiceInventoryRowsAsDelimited(rows, delimiter = "\t") {
  const lines = [
    serviceInventoryExportColumns.join(delimiter),
    ...rows.map(row => serviceInventoryExportColumns.map(column => {
      const value = String(row[column] || "").replace(/\r?\n/g, " ").trim();
      return delimiter === ";"
        ? `"${value.replace(/"/g, '""')}"`
        : value;
    }).join(delimiter))
  ];
  return lines.join("\n");
}

function sanitizeServiceInventoryFilename(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "service";
}

function buildServiceVariantAnchorId(serviceName, variantLabel) {
  return `servicevariant-${sanitizeServiceInventoryFilename(serviceName)}-${sanitizeServiceInventoryFilename(variantLabel)}`;
}

function initializeServiceInventoryNestedTable(tableElement) {
  if (!tableElement || !(window.jQuery && $.fn.dataTable)) {
    return;
  }

  if ($.fn.dataTable.isDataTable(tableElement)) {
    const existing = $(tableElement).DataTable();
    const existingWrapper = existing.table().container();
    if (existingWrapper) {
      existingWrapper.classList.add("service-inventory-host-table-wrapper");
    }
    existing.columns.adjust();
    return existing;
  }

  const exportName = tableElement.getAttribute("data-export-name") || "nmapview-service-details";
  const api = $(tableElement).DataTable({
    paging: false,
    searching: true,
    info: true,
    ordering: true,
    order: [[0, 'asc'], [1, 'asc']],
    stateSave: false,
    autoWidth: false,
    dom: '<"d-flex justify-content-between align-items-center mb-2"fB>rti',
    buttons: [
      {
        extend: 'colvis',
        text: 'Columns',
        className: 'btn btn-light'
      },
      {
        extend: 'collection',
        text: 'Copy',
        className: 'btn btn-light',
        buttons: [
          {
            text: 'All',
            action: async function (e, dt) {
              await copyVisibleDataTableRows(dt);
            }
          },
          {
            text: 'IP:Ports',
            action: async function (e, dt) {
              const endpoints = [];

              dt.rows({ search: 'applied' }).nodes().toArray().forEach(row => {
                const address = (row.getAttribute('data-address') || '').trim();
                const rawPorts = (row.getAttribute('data-ports') || '').trim();
                if (!address || !rawPorts) {
                  return;
                }

                rawPorts
                  .split(',')
                  .map(port => port.trim())
                  .filter(Boolean)
                  .forEach(portLabel => {
                    const [port] = portLabel.split('/');
                    if (port) {
                      endpoints.push(`${address}:${port}`);
                    }
                  });
              });

              const uniqueEndpoints = [...new Set(endpoints)];
              await copyTextWithFeedback(
                uniqueEndpoints.join('\n'),
                `Copied ${uniqueEndpoints.length} IP:Port entr${uniqueEndpoints.length === 1 ? "y" : "ies"}`
              );
            }
          },
          {
            text: 'IPs',
            action: async function (e, dt) {
              const addresses = [];

              dt.rows({ search: 'applied' }).nodes().toArray().forEach(row => {
                const address = (row.getAttribute('data-address') || '').trim();
                if (address) {
                  addresses.push(address);
                }
              });

              const uniqueAddresses = [...new Set(addresses)]
                .sort((left, right) => left.localeCompare(right, undefined, {
                  numeric: true,
                  sensitivity: 'base'
                }));

              await copyTextWithFeedback(
                uniqueAddresses.join('\n'),
                `Copied ${uniqueAddresses.length} IP${uniqueAddresses.length === 1 ? "" : "s"}`
              );
            }
          },
          {
            text: 'Ports',
            action: async function (e, dt) {
              const ports = [];

              dt.rows({ search: 'applied' }).nodes().toArray().forEach(row => {
                const rawPorts = (row.getAttribute('data-ports') || '').trim();
                if (!rawPorts) {
                  return;
                }

                rawPorts
                  .split(',')
                  .map(port => port.trim())
                  .filter(Boolean)
                  .forEach(portLabel => {
                    const [port] = portLabel.split('/');
                    if (port) {
                      ports.push(port);
                    }
                  });
              });

              const uniquePorts = [...new Set(ports)]
                .sort((left, right) => Number(left) - Number(right) || left.localeCompare(right, undefined, {
                  numeric: true,
                  sensitivity: 'base'
                }));

              await copyTextWithFeedback(
                uniquePorts.join(','),
                `Copied ${uniquePorts.length} port${uniquePorts.length === 1 ? "" : "s"}`
              );
            }
          }
        ]
      },
      {
        extend: 'csvHtml5',
        text: 'CSV',
        filename: exportName,
        fieldSeparator: ';',
        exportOptions: { rows: getDataTableExportRowSelector(), columns: getDataTableExportColumnSelector(), orthogonal: 'export' },
        className: 'btn btn-light'
      },
      {
        extend: 'excelHtml5',
        text: 'Excel',
        filename: exportName,
        autoFilter: true,
        exportOptions: { rows: getDataTableExportRowSelector(), columns: getDataTableExportColumnSelector(), orthogonal: 'export' },
        className: 'btn btn-light'
      },
      {
        text: 'JSON',
        className: 'btn btn-light',
        action: buildDataTableJsonExportAction(exportName)
      }
    ]
  });
  const wrapper = api.table().container();
  if (wrapper) {
    wrapper.classList.add("service-inventory-host-table-wrapper");
  }
  return api;
}

function initializeServiceInventoryNestedTables() {
  document.querySelectorAll(".service-inventory-service-details").forEach(details => {
    const nestedTable = details.querySelector(".service-inventory-host-table");
    if (!nestedTable) {
      return;
    }

    const ensureInitialized = () => {
      const api = initializeServiceInventoryNestedTable(nestedTable);
      if (api && typeof api.columns?.adjust === "function") {
        api.columns.adjust();
      }
    };

    ensureInitialized();

    details.addEventListener("toggle", () => {
      if (details.open) {
        ensureInitialized();
      }
    });
  });
}

function buildServiceInventoryTable() {
  const tableBody = document.getElementById("serviceInventoryTableBody");
  const entries = Array.from(document.querySelectorAll("#serviceInventoryData .service-inventory-entry"));
  if (!tableBody || entries.length === 0) {
    return;
  }

  const services = new Map();

  entries.forEach(entry => {
    const service = (entry.getAttribute("data-service") || "").trim();
    const address = (entry.getAttribute("data-address") || "").trim();
    const hostname = (entry.getAttribute("data-hostname") || "").trim();
    const product = entry.getAttribute("data-product") || "";
    const version = entry.getAttribute("data-version") || "";
    const port = (entry.getAttribute("data-port") || "").trim();
    const protocol = (entry.getAttribute("data-protocol") || "").trim();
    const portLabel = port && protocol ? `${port}/${protocol}` : "";
    const variantLabel = buildServiceInventoryVariantLabel(product, version);
    const extraInfo = (entry.getAttribute("data-extra-info") || "").trim();

    if (!service || !address || !isHostInScope(address)) {
      return;
    }

    if (!services.has(service)) {
      services.set(service, {
        name: service,
        hosts: new Map(),
        ports: new Set(),
        variants: new Map()
      });
    }

    const serviceRecord = services.get(service);
    serviceRecord.hosts.set(address, { address, hostname });
    if (portLabel) {
      serviceRecord.ports.add(portLabel);
    }

    if (!serviceRecord.variants.has(variantLabel)) {
      serviceRecord.variants.set(variantLabel, {
        label: variantLabel,
        productGroup: buildServiceInventoryProductGroup(product),
        isUnknown: variantLabel === "Unknown product/version",
        hosts: new Map(),
        ports: new Set()
      });
    }

    const variantRecord = serviceRecord.variants.get(variantLabel);
    if (!variantRecord.hosts.has(address)) {
      variantRecord.hosts.set(address, {
        address,
        hostname,
        ports: new Set(),
        extraInfoRecords: new Map(),
        scripts: new Map(),
        httpDetails: new Map(),
        vulners: new Map()
      });
    }
    const variantHostRecord = variantRecord.hosts.get(address);
    if (!variantHostRecord.hostname && hostname) {
      variantHostRecord.hostname = hostname;
    }
    if (portLabel) {
      variantHostRecord.ports.add(portLabel);
      variantRecord.ports.add(portLabel);
    }
    if (extraInfo) {
      const extraInfoKey = portLabel || `${service}|${address}|extra-info`;
      if (!variantHostRecord.extraInfoRecords.has(extraInfoKey)) {
        variantHostRecord.extraInfoRecords.set(extraInfoKey, {
          portLabel: portLabel || "",
          value: extraInfo
        });
      }
    }

    const httpTitle = (entry.getAttribute("data-http-title") || "").trim();
    const httpLocation = (entry.getAttribute("data-http-location") || "").trim();
    const httpServer = (entry.getAttribute("data-http-server") || "").trim();
    const httpStack = (entry.getAttribute("data-http-stack") || "").trim();
    const httpPoweredBy = (entry.getAttribute("data-http-powered-by") || "").trim();
    const rawVulners = (entry.getAttribute("data-vulners") || "").trim();
    if ([httpTitle, httpLocation, httpServer, httpStack, httpPoweredBy].some(Boolean)) {
      const httpKey = portLabel || `${service}|${address}`;
      if (!variantHostRecord.httpDetails.has(httpKey)) {
        variantHostRecord.httpDetails.set(httpKey, {
          portLabel: portLabel || "",
          title: httpTitle,
          location: httpLocation,
          server: httpServer,
          stack: httpStack,
          poweredBy: httpPoweredBy
        });
      }
    }
    const vulnersEntries = parseVulnersEntries(rawVulners);
    if (vulnersEntries.length > 0) {
      const vulnersKey = portLabel || `${service}|${address}|vulners`;
      if (!variantHostRecord.vulners.has(vulnersKey)) {
        variantHostRecord.vulners.set(vulnersKey, {
          portLabel: portLabel || "",
          entries: vulnersEntries
        });
      }
    }

    Array.from(entry.querySelectorAll(".service-inventory-script")).forEach(scriptEntry => {
      const scriptId = (scriptEntry.getAttribute("data-id") || "").trim();
      const scriptOutput = (scriptEntry.textContent || "").trim();
      const scriptPort = (scriptEntry.getAttribute("data-port") || "").trim();
      const scriptProtocol = (scriptEntry.getAttribute("data-protocol") || "").trim();
      const scriptPortLabel = scriptPort && scriptProtocol ? `${scriptPort}/${scriptProtocol}` : portLabel;
      const scriptValidFrom = (scriptEntry.getAttribute("data-valid-from") || "").trim();
      const scriptValidTo = (scriptEntry.getAttribute("data-valid-to") || "").trim();
      const scriptSelfSigned = (scriptEntry.getAttribute("data-self-signed") || "").trim() === "true";

      if (!scriptId || !scriptOutput) {
        return;
      }

      const scriptKey = `${scriptPortLabel}::${scriptId}::${scriptOutput}`;
      if (!variantHostRecord.scripts.has(scriptKey)) {
        variantHostRecord.scripts.set(scriptKey, {
          id: scriptId,
          output: scriptOutput,
          portLabel: scriptPortLabel || "",
          validFrom: scriptValidFrom,
          validTo: scriptValidTo,
          selfSigned: scriptSelfSigned
        });
      }
    });
  });

  const sortedServices = Array.from(services.values()).sort((left, right) => {
    return right.hosts.size - left.hosts.size || compareInventoryText(left.name, right.name);
  });

  serviceInventoryExportRows = [];
  tableBody.textContent = "";
  let nestedTableIndex = 0;

  sortedServices.forEach(serviceRecord => {
    const row = document.createElement("tr");
    const hostsCell = document.createElement("td");
    const serviceDetails = document.createElement("details");
    const serviceSummary = document.createElement("summary");
    const serviceLine = document.createElement("div");
    const serviceTitle = document.createElement("span");
    const serviceMeta = document.createElement("span");
    const serviceBody = document.createElement("div");
    const hostTable = document.createElement("table");
    const hostTableHead = document.createElement("thead");
    const hostTableHeadRow = document.createElement("tr");
    const hostTableBucketHeader = document.createElement("th");
    const hostTableHostHeader = document.createElement("th");
    const hostTablePortsHeader = document.createElement("th");
    const hostTableServiceHeader = document.createElement("th");
    const hostTableBody = document.createElement("tbody");
    const variants = Array.from(serviceRecord.variants.values()).sort((left, right) => {
      if (left.isUnknown !== right.isUnknown) {
        return left.isUnknown ? 1 : -1;
      }
      return compareInventoryText(left.productGroup, right.productGroup) || compareInventoryText(left.label, right.label);
    });
    const searchTerms = new Set();

    serviceDetails.className = "service-inventory-service-details";
    serviceSummary.className = "service-inventory-service-summary";
    serviceLine.className = "service-inventory-summary-line";
    serviceTitle.className = "service-inventory-service-title";
    serviceMeta.className = "service-inventory-service-meta";
    serviceBody.className = "service-inventory-service-body";
    hostTable.className = "service-inventory-host-table";
    hostTable.id = `serviceInventoryNestedTable${nestedTableIndex += 1}`;
    hostTable.setAttribute("data-export-name", `nmapview-service-${sanitizeServiceInventoryFilename(serviceRecord.name)}`);
    hostTableBucketHeader.className = "service-inventory-host-bucket-column";
    hostTableHostHeader.className = "service-inventory-host-column";
    hostTablePortsHeader.className = "service-inventory-host-ports-column";
    hostTableServiceHeader.className = "service-inventory-host-service-column";

    hostsCell.className = "service-inventory-hosts-cell";
    hostsCell.dataset.order = String(serviceRecord.hosts.size);
    searchTerms.add(normalizeServiceInventorySearchValue(serviceRecord.name));

    serviceTitle.textContent = serviceRecord.name;
    serviceMeta.textContent = `${formatInventoryHostCount(serviceRecord.hosts.size)} • ${formatInventoryVariantSummary(variants)}`;
    serviceLine.appendChild(serviceTitle);
    serviceLine.appendChild(serviceMeta);
    serviceSummary.appendChild(serviceLine);
    hostTableBucketHeader.textContent = "Product";
    hostTableHostHeader.textContent = "Host";
    hostTablePortsHeader.textContent = "Port(s)";
    hostTableServiceHeader.textContent = "Details";
    hostTableHeadRow.appendChild(hostTableBucketHeader);
    hostTableHeadRow.appendChild(hostTableHostHeader);
    hostTableHeadRow.appendChild(hostTablePortsHeader);
    hostTableHeadRow.appendChild(hostTableServiceHeader);
    hostTableHead.appendChild(hostTableHeadRow);

    let previousProductGroup = "";
    let previousVariantLabel = "";
    const serviceScopedExportRows = [];

    variants.forEach(variantRecord => {
      searchTerms.add(normalizeServiceInventorySearchValue(variantRecord.label));
      searchTerms.add(normalizeServiceInventorySearchValue(variantRecord.productGroup));
      const variantAnchorId = buildServiceVariantAnchorId(serviceRecord.name, variantRecord.label);
      let variantAnchorAssigned = false;
      const hosts = Array.from(variantRecord.hosts.values()).sort((left, right) => {
        const leftLabel = buildServiceInventoryHostLabel(left.hostname, left.address);
        const rightLabel = buildServiceInventoryHostLabel(right.hostname, right.address);
        return compareInventoryText(leftLabel, rightLabel);
      });

      hosts.forEach(hostRecord => {
        const row = document.createElement("tr");
        const bucketCell = document.createElement("td");
        const bucketLabel = document.createElement("a");
        const hostCell = document.createElement("td");
        const portsCell = document.createElement("td");
        const serviceCell = document.createElement("td");
        const link = document.createElement("a");
        const portLabels = Array.from(hostRecord.ports || []).sort(compareInventoryPortLabels);
        const extraInfoRecords = Array.from(hostRecord.extraInfoRecords ? hostRecord.extraInfoRecords.values() : [])
          .sort((left, right) => compareInventoryPortLabels(left.portLabel, right.portLabel) || compareInventoryText(left.value, right.value));
        const httpDetails = Array.from(hostRecord.httpDetails ? hostRecord.httpDetails.values() : [])
          .sort(compareInventoryHttpRecords);
        const vulnersRecords = Array.from(hostRecord.vulners ? hostRecord.vulners.values() : [])
          .sort((left, right) => compareInventoryPortLabels(left.portLabel, right.portLabel));
        const scriptRecords = Array.from(hostRecord.scripts ? hostRecord.scripts.values() : [])
          .sort(compareInventoryScriptRecords);
        const hostDisplayLabel = buildServiceInventoryHostLabel(hostRecord.hostname, hostRecord.address);
        const filteredScriptRecords = scriptRecords.filter(scriptRecord =>
          scriptRecord.id !== "vulners" &&
          !shouldSuppressRawHttpScript(scriptRecord.id, httpDetails.length > 0)
        );
        const primaryHttpRecord = httpDetails[0] || {};
        const hostSearchTerms = [
          hostDisplayLabel,
          hostRecord.address,
          hostRecord.hostname,
          ...portLabels,
          ...extraInfoRecords.map(record => record.value),
          ...httpDetails.flatMap(record => [
            record.title,
            record.server,
            record.location,
            record.stack,
            record.poweredBy
          ]),
          ...filteredScriptRecords.map(record => record.id)
        ];

        row.setAttribute("data-address", hostRecord.address);
        row.setAttribute("data-ports", portLabels.join(","));
        hostSearchTerms
          .map(normalizeServiceInventorySearchValue)
          .filter(Boolean)
          .forEach(term => searchTerms.add(term));

        link.className = "service-inventory-host-link";
        link.href = `#onlinehosts-${hostRecord.address.replace(/[.:]/g, "-")}`;
        link.textContent = hostDisplayLabel;
        if (!variantAnchorAssigned) {
          row.id = variantAnchorId;
          variantAnchorAssigned = true;
        }
        if (variantRecord.productGroup !== previousProductGroup) {
          row.classList.add("service-inventory-product-separator");
          previousProductGroup = variantRecord.productGroup;
        } else if (variantRecord.label !== previousVariantLabel) {
          row.classList.add("service-inventory-variant-separator");
        }
        previousVariantLabel = variantRecord.label;
        bucketLabel.className = "service-inventory-bucket-label";
        bucketLabel.href = `#${variantAnchorId}`;
        bucketLabel.textContent = variantRecord.label;
        bucketCell.appendChild(bucketLabel);
        hostCell.appendChild(link);
        if (portLabels.length > 0) {
          portLabels.forEach((portLabel, index) => {
            const [port, protocol] = String(portLabel || "").split("/");
            if (index > 0) {
              portsCell.appendChild(document.createTextNode(", "));
            }
            portsCell.appendChild(createBrowserEndpointLink(
              hostRecord.address,
              port,
              protocol || "",
              serviceRecord.name,
              portLabel
            ));
          });
        }
        if (extraInfoRecords.length > 0 || httpDetails.length > 0 || vulnersRecords.length > 0 || filteredScriptRecords.length > 0) {
          const detailsGroup = document.createElement("details");
          const detailsSummary = document.createElement("summary");
          const detailsBody = document.createElement("div");
          const hiddenScriptCount = filteredScriptRecords.length;
          const hiddenDetailCount = extraInfoRecords.length +
            httpDetails.length +
            vulnersRecords.length +
            hiddenScriptCount;

          detailsGroup.className = "service-inventory-script-group-details";
          detailsSummary.className = "service-inventory-script-group-summary";
          detailsBody.className = "service-inventory-script-group-body";
          detailsSummary.textContent = hiddenScriptCount > 0
            ? `Show Details (${hiddenScriptCount} script${hiddenScriptCount === 1 ? "" : "s"})`
            : `Show Details (${hiddenDetailCount})`;

          if (extraInfoRecords.length > 0) {
            const extraInfoContainer = document.createElement("div");
            extraInfoContainer.className = "service-inventory-extra-info-details";

            extraInfoRecords.forEach(extraInfoRecord => {
              const extraInfoBlock = document.createElement("div");
              extraInfoBlock.className = "service-inventory-extra-info-block";

              if (extraInfoRecord.portLabel) {
                const extraInfoPortLabel = document.createElement("div");
                extraInfoPortLabel.className = "service-inventory-extra-info-port-label";
                extraInfoPortLabel.textContent = `Extra Info (${extraInfoRecord.portLabel})`;
                extraInfoBlock.appendChild(extraInfoPortLabel);
              }

              const extraInfoValue = document.createElement("div");
              extraInfoValue.className = "service-inventory-extra-info-value";
              extraInfoValue.textContent = extraInfoRecord.value;
              extraInfoBlock.appendChild(extraInfoValue);
              extraInfoContainer.appendChild(extraInfoBlock);
            });

            detailsBody.appendChild(extraInfoContainer);
          }

          if (httpDetails.length > 0) {
            const httpDetailsContainer = document.createElement("div");
            httpDetailsContainer.className = "service-inventory-http-details";

            httpDetails.forEach(httpRecord => {
              const httpBlock = document.createElement("div");
              httpBlock.className = "http-details-block service-inventory-http-block";

              if (httpRecord.portLabel) {
                const httpPortLabel = document.createElement("div");
                httpPortLabel.className = "service-inventory-http-port-label";
                httpPortLabel.textContent = `HTTP (${httpRecord.portLabel})`;
                httpBlock.appendChild(httpPortLabel);
              }

              appendServiceInventoryDetailRow(httpBlock, "Title", httpRecord.title);
              appendServiceInventoryDetailRow(httpBlock, "Server", httpRecord.server);
              appendServiceInventoryDetailRow(httpBlock, "Location", httpRecord.location);
              appendServiceInventoryDetailRow(httpBlock, "Stack", httpRecord.stack);
              appendServiceInventoryDetailRow(httpBlock, "Powered-By", httpRecord.poweredBy);
              httpDetailsContainer.appendChild(httpBlock);
            });

            detailsBody.appendChild(httpDetailsContainer);
          }

          if (vulnersRecords.length > 0) {
            const vulnersContainer = document.createElement("div");
            const vulnersSummary = document.createElement("div");
            const vulnersList = document.createElement("div");
            const flattenedVulners = vulnersRecords.flatMap(record =>
              record.entries.map(entry => ({
                ...entry,
                portLabel: record.portLabel
              }))
            );
            const totalFindings = flattenedVulners.length;
            const topFinding = flattenedVulners[0];

            vulnersContainer.className = "service-inventory-vulners";
            vulnersSummary.className = "service-inventory-vulners-summary";
            vulnersList.className = "service-inventory-vulners-list";
            vulnersSummary.textContent = topFinding
              ? `Vulners: ${totalFindings} finding${totalFindings === 1 ? "" : "s"}, top CVSS ${topFinding.scoreText}`
              : `Vulners: ${totalFindings} finding${totalFindings === 1 ? "" : "s"}`;

            flattenedVulners.slice(0, 3).forEach(entry => {
              const item = document.createElement("div");
              const score = document.createElement("strong");
              const link = document.createElement("a");

              item.className = "service-inventory-vulners-item";
              score.textContent = `CVSS ${entry.scoreText}`;
              link.href = entry.href;
              link.target = "_blank";
              link.rel = "noopener noreferrer";
              link.textContent = entry.portLabel ? `${entry.id} (${entry.portLabel})` : entry.id;
              item.appendChild(score);
              item.appendChild(link);
              vulnersList.appendChild(item);
            });

            if (totalFindings > 3) {
              const more = document.createElement("div");
              more.className = "service-inventory-vulners-more";
              more.textContent = `Showing a compact subset of ${totalFindings} findings`;
              vulnersList.appendChild(more);
            }

            vulnersContainer.appendChild(vulnersSummary);
            vulnersContainer.appendChild(vulnersList);
            detailsBody.appendChild(vulnersContainer);
          }

          if (filteredScriptRecords.length > 0) {
            const scriptList = document.createElement("div");

            scriptList.className = "service-inventory-script-list";

            filteredScriptRecords.forEach(scriptRecord => {
            const scriptItem = document.createElement("details");
            const scriptLabel = document.createElement("summary");
            const scriptOutput = document.createElement("pre");

            scriptItem.className = "service-inventory-script-item-details";
            scriptLabel.className = "service-inventory-script-item-summary";
            scriptOutput.className = "service-inventory-script-output";
            scriptLabel.textContent = scriptRecord.portLabel
              ? `${scriptRecord.id} (${hostDisplayLabel} | ${scriptRecord.portLabel})`
              : `${scriptRecord.id} (${hostDisplayLabel})`;
            if (scriptRecord.id === "ssl-cert" && scriptRecord.validTo) {
              const expiryBadge = buildCertificateExpiryBadge(scriptRecord.validFrom, scriptRecord.validTo);
              if (expiryBadge) {
                scriptLabel.appendChild(expiryBadge);
              }
            }
            if (scriptRecord.id === "ssl-cert" && scriptRecord.selfSigned) {
              const selfSignedBadge = document.createElement("span");
              selfSignedBadge.className = "certificate-expiry-badge is-self-signed";
              selfSignedBadge.textContent = "Self-signed";
              selfSignedBadge.title = "Certificate subject and issuer match";
              scriptLabel.appendChild(selfSignedBadge);
            }
            scriptOutput.textContent = formatServiceInventoryScriptOutput(scriptRecord);
            scriptItem.appendChild(scriptLabel);
            scriptItem.appendChild(scriptOutput);
            scriptList.appendChild(scriptItem);
            });

            scriptList.classList.add("service-inventory-script-group-body");
            detailsBody.appendChild(scriptList);
          }

          detailsGroup.appendChild(detailsSummary);
          detailsGroup.appendChild(detailsBody);
          serviceCell.appendChild(detailsGroup);
        }

        const exportRow = {
          "Service": serviceRecord.name,
          "Bucket": variantRecord.label,
          "Host": hostDisplayLabel,
          "Port(s)": formatInventoryPortList(hostRecord.ports),
          "HTTP Title": primaryHttpRecord.title || "",
          "HTTP Server": primaryHttpRecord.server || "",
          "HTTP Location": primaryHttpRecord.location || "",
          "HTTP Stack": primaryHttpRecord.stack || "",
          "HTTP Powered-By": primaryHttpRecord.poweredBy || "",
          "Vulners": buildServiceInventoryVulnersSummary(vulnersRecords),
          "NSE Scripts": buildServiceInventoryScriptSummary(filteredScriptRecords, hostDisplayLabel)
        };
        serviceInventoryExportRows.push(exportRow);
        serviceScopedExportRows.push(exportRow);
        row.appendChild(bucketCell);
        row.appendChild(hostCell);
        row.appendChild(portsCell);
        row.appendChild(serviceCell);
        hostTableBody.appendChild(row);
      });
    });

    hostTable.appendChild(hostTableHead);
    hostTable.appendChild(hostTableBody);
    serviceBody.appendChild(hostTable);
    serviceDetails.appendChild(serviceSummary);
    serviceDetails.appendChild(serviceBody);
    hostsCell.appendChild(serviceDetails);
    hostsCell.dataset.search = Array.from(searchTerms).join(" ");

    row.appendChild(hostsCell);
    tableBody.appendChild(row);
  });
}

function initializeNavbarToggle() {
  const menu = document.getElementById("navbarNav");
  if (!menu) return;
  menu.hidden = false;
  window.requestAnimationFrame(syncDataTableFixedHeaders);
}

function initializeSectionNav() {
  const navLinks = Array.from(document.querySelectorAll("#navbarNav .navbar-nav.me-auto .nav-link[href^='#']"));
  if (navLinks.length === 0) {
    return;
  }

  const sections = navLinks
    .map(link => {
      const hash = link.getAttribute("href");
      if (!hash) {
        return null;
      }

      const section = document.querySelector(hash);
      if (!section) {
        return null;
      }

      return { link, hash, section };
    })
    .filter(Boolean);

  if (sections.length === 0) {
    return;
  }

  function setActiveLink(hash) {
    let normalizedHash = hash;
    if (hash && hash.startsWith("#onlinehosts-")) {
      normalizedHash = "#onlinehosts";
    } else if (hash && hash.startsWith("#servicevariant-")) {
      normalizedHash = "#serviceinventory";
    }
    sections.forEach(({ link, hash: sectionHash }) => {
      const isActive = sectionHash === normalizedHash;
      link.classList.toggle("is-active", isActive);
      if (isActive) {
        link.setAttribute("aria-current", "page");
      } else {
        link.removeAttribute("aria-current");
      }
    });
  }

  const observer = new IntersectionObserver(entries => {
    const visibleEntries = entries
      .filter(entry => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio);

    if (visibleEntries.length === 0) {
      return;
    }

    const activeSection = sections.find(({ section }) => section === visibleEntries[0].target);
    if (activeSection) {
      setActiveLink(activeSection.hash);
    }
  }, {
    rootMargin: "-25% 0px -55% 0px",
    threshold: [0.2, 0.35, 0.5]
  });

  sections.forEach(({ section }) => observer.observe(section));

  navLinks.forEach(link => {
    link.addEventListener("click", () => {
      const hash = link.getAttribute("href");
      if (hash) {
        setActiveLink(hash);
      }
    });
  });

  setActiveLink(window.location.hash || sections[0].hash);
}

function isEditableShortcutTarget(target) {
  if (!(target instanceof HTMLElement)) {
    return false;
  }

  const tagName = target.tagName;
  return target.isContentEditable ||
    tagName === "INPUT" ||
    tagName === "TEXTAREA" ||
    tagName === "SELECT";
}

function getSectionSearchInput(selector) {
  const tableElement = selector ? document.querySelector(selector) : null;
  if (!tableElement) {
    return null;
  }

  const wrapper = tableElement.closest(".dt-container, .dataTables_wrapper");
  if (!wrapper) {
    return null;
  }

  return wrapper.querySelector(".dataTables_filter input, .dt-search input");
}

function focusActiveSectionSearch() {
  const activeLink = document.querySelector("#navbarNav .navbar-nav.me-auto .nav-link[aria-current='page']");
  const activeHash = activeLink ? activeLink.getAttribute("href") : "";
  const selectorBySection = {
    "#scannedhosts": "#table-overview",
    "#openservices": "#table-services",
    "#serviceinventory": "#service-inventory"
  };
  const searchInput = getSectionSearchInput(selectorBySection[activeHash || ""]);
  if (!searchInput) {
    return false;
  }

  searchInput.focus();
  if (typeof searchInput.select === "function") {
    searchInput.select();
  }
  return true;
}

function initializeSlashSearchShortcut() {
  document.addEventListener("keydown", event => {
    if (event.key !== "/" || event.ctrlKey || event.metaKey || event.altKey) {
      return;
    }

    if (isEditableShortcutTarget(event.target)) {
      return;
    }

    if (focusActiveSectionSearch()) {
      event.preventDefault();
    }
  });
}

function openLinkedHost(hash) {
  if (!hash || !hash.startsWith("#onlinehosts-")) {
    return null;
  }

  const target = document.querySelector(hash);
  if (!target) {
    return null;
  }

  const hostEntry = target.closest("details");
  if (hostEntry) {
    hostEntry.open = true;
  }

  return target;
}

function openLinkedServiceVariant(hash) {
  if (!hash || !hash.startsWith("#servicevariant-")) {
    return null;
  }

  const target = document.querySelector(hash);
  if (!target) {
    return null;
  }

  openAncestorDetails(target);
  return target;
}

function openAncestorDetails(target) {
  let current = target ? target.parentElement : null;
  while (current) {
    if (current.tagName === "DETAILS") {
      current.open = true;
    }
    current = current.parentElement;
  }
}

function getReportScrollTop(target) {
  if (!target) {
    return 0;
  }

  const headerOffset = 60;
  const top = target.getBoundingClientRect().top + window.pageYOffset - headerOffset;
  return Math.max(0, top);
}

function scrollToReportTarget(target) {
  if (!target) {
    return;
  }

  window.scrollTo(0, getReportScrollTop(target));
}

function pinReportToSummaryView() {
  const summary = document.getElementById("summary");
  if (summary) {
    scrollToReportTarget(summary);
    return;
  }

  window.scrollTo(0, 0);
}

function navigateToInitialHash() {
  const hash = window.location.hash;
  if (!hash || hash === "#summary") {
    return;
  }

  const hostTarget = openLinkedHost(hash);
  if (hostTarget) {
    scrollToReportTarget(hostTarget);
    return;
  }

  const serviceVariantTarget = openLinkedServiceVariant(hash);
  if (serviceVariantTarget) {
    scrollToReportTarget(serviceVariantTarget);
    return;
  }

  const target = document.querySelector(hash);
  if (target) {
    openAncestorDetails(target);
    scrollToReportTarget(target);
  }
}

function setReportLoadingOverlayVisible(isVisible, titleText = "Preparing Report") {
  const overlay = document.getElementById("reportLoadingOverlay");
  const title = document.getElementById("reportLoadingTitleText");
  if (!overlay) {
    return;
  }

  if (title) {
    title.textContent = titleText;
  }

  overlay.classList.toggle("is-hidden", !isVisible);
  overlay.setAttribute("aria-hidden", isVisible ? "false" : "true");
}

function finalizeReportInitialization() {
  window.requestAnimationFrame(() => {
    window.requestAnimationFrame(() => {
      document.body.classList.remove("report-initializing");
      setReportLoadingOverlayVisible(false);
      navigateToInitialHash();
    });
  });
}

function getDataTableHeaderOffset() {
  const navbar = document.getElementById("mainNavbar");
  return navbar ? Math.ceil(navbar.getBoundingClientRect().height) : 0;
}

function getHostOverviewTableRows() {
  return getTableRows("table-overview", { requireAddress: true });
}

function getVisibleHostOverviewRows() {
  return getTableRows("table-overview", { searchApplied: true, requireAddress: true });
}

function setEquals(left, right) {
  if (left.size !== right.size) {
    return false;
  }

  for (const value of left) {
    if (!right.has(value)) {
      return false;
    }
  }

  return true;
}

function syncHostScopeSummary() {
  const summary = document.getElementById("hostScopeSummary");
  if (!summary) {
    return;
  }

  const state = getHostScopeState();
  const selectedCount = state.pendingSelectedHosts.size;
  const totalCount = state.allHosts.size;
  summary.textContent = `${selectedCount} of ${totalCount} host${totalCount === 1 ? "" : "s"} selected${state.dirty ? " · apply pending" : ""}`;
}

function syncHostScopeApplyButton() {
  const button = document.getElementById("applyHostScopeButton");
  if (!button) {
    return;
  }

  const state = getHostScopeState();
  button.disabled = !state.dirty || state.redrawInProgress;
}

function syncHostScopeCheckboxesAndRows() {
  const state = getHostScopeState();
  getHostOverviewTableRows().forEach(row => {
    const address = normalizeHostAddress(row.dataset.address);
    const checkbox = row.querySelector(".host-scope-checkbox");
    const isSelected = !address || state.pendingSelectedHosts.has(address);

    row.classList.toggle("host-scope-excluded", Boolean(address) && !isSelected);
    if (checkbox) {
      checkbox.checked = isSelected;
    }
  });

  syncHostScopeSummary();
  syncHostScopeApplyButton();
}

function registerHostScopeDataTableFilter() {
  const state = getHostScopeState();
  if (state.dataTableFilterRegistered || !(window.jQuery && $.fn.dataTable)) {
    return;
  }

  $.fn.dataTable.ext.search.push((settings, _searchData, dataIndex) => {
    const tableId = settings && settings.nTable ? settings.nTable.id : "";
    if (tableId !== "table-services") {
      return true;
    }

    const row = settings.aoData && settings.aoData[dataIndex] ? settings.aoData[dataIndex].nTr : null;
    const address = row ? normalizeHostAddress(row.dataset.address) : "";
    return !address || isHostInScope(address);
  });

  state.dataTableFilterRegistered = true;
}

function recalculateOpenServiceHostCounts() {
  const table = document.getElementById("table-services");
  if (!table) {
    return;
  }

  const headers = Array.from(table.querySelectorAll("thead th")).map(header => (header.textContent || "").trim());
  const countColumnIndex = headers.indexOf("Count");
  if (countColumnIndex === -1) {
    return;
  }

  const selectedCounts = new Map();
  const rows = getTableRows("table-services", { requireAddress: true });

  rows.forEach(row => {
    if (!isHostInScope(row.dataset.address)) {
      return;
    }

    const key = `${row.dataset.portid || ""}|${row.dataset.protocol || ""}`;
    selectedCounts.set(key, (selectedCounts.get(key) || 0) + 1);
  });

  rows.forEach(row => {
    const cells = row.querySelectorAll("td");
    if (cells.length <= countColumnIndex) {
      return;
    }

    const key = `${row.dataset.portid || ""}|${row.dataset.protocol || ""}`;
    const count = selectedCounts.get(key) || 0;
    cells[countColumnIndex].dataset.order = String(count);
    cells[countColumnIndex].textContent = String(count);
  });
}

function refreshOpenServicesForHostScope() {
  const tableElement = document.getElementById("table-services");
  if (!tableElement) {
    return;
  }

  recalculateOpenServiceHostCounts();

  if (window.jQuery && $.fn.dataTable && $.fn.dataTable.isDataTable(tableElement)) {
    const tableApi = $(tableElement).DataTable();
    if (tableApi) {
      tableApi.rows().invalidate("dom").draw(false);
      tableApi.columns.adjust();
      if (tableApi.fixedHeader && typeof tableApi.fixedHeader.adjust === "function") {
        tableApi.fixedHeader.adjust();
      }
    }
  }
}

function updateHostDetailsVisibility() {
  const hostEntries = document.querySelectorAll("#onlinehosts-list details.host-entry");
  hostEntries.forEach(entry => {
    const address = normalizeHostAddress(entry.dataset.address);
    const isSelected = !address || isHostInScope(address);
    entry.hidden = !isSelected;
    if (!isSelected) {
      entry.open = false;
    }
  });
}

function refreshServiceInventoryForHostScope() {
  const tableElement = document.getElementById("service-inventory");
  if (!tableElement) {
    return;
  }

  let searchValue = "";
  let orderValue = null;

  if (window.jQuery && $.fn.dataTable && $.fn.dataTable.isDataTable(tableElement)) {
    const tableApi = $(tableElement).DataTable();
    if (tableApi) {
      searchValue = tableApi.search();
      orderValue = tableApi.order();
      tableApi.destroy();
    }
  }

  buildServiceInventoryTable();
  initializeServiceInventoryToggle();
  initializeServiceInventoryNestedTables();

  const tableApi = initializeDataTable("#service-inventory");
  if (tableApi) {
    if (searchValue) {
      tableApi.search(searchValue);
    }
    if (Array.isArray(orderValue) && orderValue.length > 0) {
      tableApi.order(orderValue);
    }
    tableApi.draw(false);
  }
}

function updateSummaryForHostScope() {
  const selectedHostRows = getHostOverviewTableRows()
    .filter(row => isHostInScope(row.dataset.address));
  const selectedUpCount = selectedHostRows
    .filter(row => normalizeHostAddress(row.dataset.state) === "up")
    .length;
  const selectedDownCount = selectedHostRows.length - selectedUpCount;
  const selectedOpenServiceRows = getTableRows("table-services", { requireAddress: true })
    .filter(row => isHostInScope(row.dataset.address));
  const selectedInventoryEntries = Array.from(document.querySelectorAll("#serviceInventoryData .service-inventory-entry"))
    .filter(entry => isHostInScope(entry.dataset.address));
  const selectedMatrixHosts = Array.from(document.querySelectorAll("#matrixCount .host"))
    .filter(entry => isHostInScope(entry.dataset.address));

  const uniqueServices = new Set();
  const httpBuckets = new Set();
  const portProtocolCounts = new Map();
  const rareServices = new Set();

  selectedMatrixHosts.forEach(host => {
    host.querySelectorAll(".port").forEach(portElement => {
      const serviceKey = normalizeUniquenessService(portElement.dataset.service || "");
      const portKey = `${normalizeHostAddress(portElement.dataset.port)}|${serviceKey.split(":")[0] || ""}`;
      if (!serviceKey) {
        return;
      }

      uniqueServices.add(serviceKey);
      portProtocolCounts.set(portKey, (portProtocolCounts.get(portKey) || 0) + 1);
    });
  });

  selectedInventoryEntries.forEach(entry => {
    const service = normalizeHostAddress(entry.getAttribute("data-service"));
    const product = normalizeHostAddress(entry.getAttribute("data-product"));
    const version = normalizeHostAddress(entry.getAttribute("data-version"));
    const looksHttp = service.toLowerCase().includes("http") ||
      normalizeHostAddress(entry.getAttribute("data-http-title")) !== "" ||
      normalizeHostAddress(entry.getAttribute("data-http-location")) !== "" ||
      normalizeHostAddress(entry.getAttribute("data-http-server")) !== "" ||
      normalizeHostAddress(entry.getAttribute("data-http-stack")) !== "" ||
      normalizeHostAddress(entry.getAttribute("data-http-powered-by")) !== "";

    if (looksHttp && service) {
      httpBuckets.add(`${service}|${product}|${product ? version : ""}`);
    }
  });

  selectedMatrixHosts.forEach(host => {
    host.querySelectorAll(".port").forEach(portElement => {
      const serviceKey = normalizeUniquenessService(portElement.dataset.service || "");
      const portKey = `${normalizeHostAddress(portElement.dataset.port)}|${serviceKey.split(":")[0] || ""}`;
      if (serviceKey && (portProtocolCounts.get(portKey) || 0) === 1) {
        rareServices.add(serviceKey);
      }
    });
  });

  const openPortsValue = document.getElementById("summaryOpenPortsValue");
  const uniqueServicesValue = document.getElementById("summaryUniqueServicesValue");
  const rareServicesValue = document.getElementById("summaryRareServicesValue");
  const httpBucketsValue = document.getElementById("summaryHttpBucketsValue");
  const upHostsBar = document.getElementById("summaryUpHostsBar");
  const downHostsBar = document.getElementById("summaryDownHostsBar");
  const totalSelectedHosts = selectedHostRows.length;
  const upWidth = totalSelectedHosts > 0 ? (selectedUpCount / totalSelectedHosts) * 100 : 0;
  const downWidth = totalSelectedHosts > 0 ? (selectedDownCount / totalSelectedHosts) * 100 : 0;

  if (openPortsValue) {
    openPortsValue.textContent = String(selectedOpenServiceRows.length);
  }
  if (uniqueServicesValue) {
    uniqueServicesValue.textContent = String(uniqueServices.size);
  }
  if (rareServicesValue) {
    rareServicesValue.textContent = String(rareServices.size);
  }
  if (httpBucketsValue) {
    httpBucketsValue.textContent = String(httpBuckets.size);
  }
  if (upHostsBar) {
    upHostsBar.style.width = `${upWidth}%`;
    upHostsBar.setAttribute("aria-valuenow", String(Math.round(upWidth)));
    upHostsBar.textContent = `${selectedUpCount} Hosts up`;
  }
  if (downHostsBar) {
    downHostsBar.style.width = `${downWidth}%`;
    downHostsBar.setAttribute("aria-valuenow", String(Math.round(downWidth)));
    downHostsBar.textContent = `${selectedDownCount} Hosts down`;
  }
}

function applyHostScopeSelection() {
  setReportLoadingOverlayVisible(true, "Updating Report");
  syncHostScopeCheckboxesAndRows();
  updateHostDetailsVisibility();
  initializeHostToggle();

  window.requestAnimationFrame(() => {
    refreshOpenServicesForHostScope();
    updateSummaryForHostScope();
    initializeHostUniquenessScores();

    window.requestAnimationFrame(() => {
      refreshServiceInventoryForHostScope();

      window.requestAnimationFrame(() => {
        if (typeof window.renderServiceDistributionVisualizations === "function") {
          window.renderServiceDistributionVisualizations();
        }

        if (typeof window.renderMatrixVisualizations === "function") {
          window.renderMatrixVisualizations();
        }

        syncDataTableFixedHeaders();
        const state = getHostScopeState();
        state.redrawInProgress = false;
        syncHostScopeApplyButton();
        setReportLoadingOverlayVisible(false, "Preparing Report");
      });
    });
  });
}

function initializeHostScopeControls() {
  const controls = document.getElementById("hostScopeControls");
  const table = document.getElementById("table-overview");
  if (!controls || !table || table.dataset.hostScopeInitialized === "true") {
    return;
  }

  const state = getHostScopeState();
  const rows = getHostOverviewTableRows();
  const addresses = rows
    .map(row => normalizeHostAddress(row.dataset.address))
    .filter(Boolean);

  state.allHosts = new Set(addresses);
  state.selectedHosts = new Set(addresses);
  state.pendingSelectedHosts = new Set(addresses);
  state.dirty = false;
  registerHostScopeDataTableFilter();
  syncHostScopeCheckboxesAndRows();

  table.addEventListener("change", event => {
    const checkbox = event.target.closest(".host-scope-checkbox");
    if (!checkbox) {
      return;
    }

    const address = normalizeHostAddress(checkbox.dataset.address);
    if (!address) {
      return;
    }

    if (checkbox.checked) {
      state.pendingSelectedHosts.add(address);
    } else {
      state.pendingSelectedHosts.delete(address);
    }

    state.dirty = !setEquals(state.pendingSelectedHosts, state.selectedHosts);
    syncHostScopeCheckboxesAndRows();
  });

  const selectVisibleButton = document.getElementById("selectVisibleHostsButton");
  if (selectVisibleButton) {
    selectVisibleButton.addEventListener("click", () => {
      getVisibleHostOverviewRows().forEach(row => {
        const address = normalizeHostAddress(row.dataset.address);
        if (address) {
          state.pendingSelectedHosts.add(address);
        }
      });
      state.dirty = !setEquals(state.pendingSelectedHosts, state.selectedHosts);
      syncHostScopeCheckboxesAndRows();
    });
  }

  const clearVisibleButton = document.getElementById("clearVisibleHostsButton");
  if (clearVisibleButton) {
    clearVisibleButton.addEventListener("click", () => {
      getVisibleHostOverviewRows().forEach(row => {
        const address = normalizeHostAddress(row.dataset.address);
        if (address) {
          state.pendingSelectedHosts.delete(address);
        }
      });
      state.dirty = !setEquals(state.pendingSelectedHosts, state.selectedHosts);
      syncHostScopeCheckboxesAndRows();
    });
  }

  const applyButton = document.getElementById("applyHostScopeButton");
  if (applyButton) {
    applyButton.addEventListener("click", () => {
      if (state.redrawInProgress) {
        return;
      }

      state.selectedHosts = new Set(state.pendingSelectedHosts);
      state.dirty = false;
      state.redrawInProgress = true;
      syncHostScopeCheckboxesAndRows();
      applyHostScopeSelection();
    });
  }

  table.dataset.hostScopeInitialized = "true";
}

function initializeHostToggle() {
  const toggle = document.getElementById("toggle-all-hosts");
  const hostList = document.getElementById("onlinehosts-list");
  if (!toggle || !hostList) return;

  function getVisibleHostEntries() {
    return Array.from(hostList.querySelectorAll("details.host-entry"))
      .filter(entry => !entry.hidden);
  }

  function syncLabel() {
    const hostEntries = getVisibleHostEntries();
    toggle.hidden = hostEntries.length === 0;
    if (hostEntries.length === 0) {
      return;
    }
    const allOpen = hostEntries.every(entry => entry.open);
    toggle.setAttribute("aria-expanded", allOpen ? "true" : "false");
    toggle.setAttribute("title", allOpen ? "Collapse all visible host details" : "Expand all visible host details");
  }

  window.refreshHostToggleLabel = syncLabel;

  if (toggle.dataset.hostToggleInitialized !== "true") {
    toggle.addEventListener("click", () => {
      const hostEntries = getVisibleHostEntries();
      if (hostEntries.length === 0) {
        return;
      }
      const shouldOpen = !hostEntries.every(entry => entry.open);
      hostEntries.forEach(entry => {
        entry.open = shouldOpen;
      });
      syncLabel();
    });
    toggle.dataset.hostToggleInitialized = "true";
  }

  Array.from(hostList.querySelectorAll("details.host-entry")).forEach(entry => {
    if (entry.dataset.hostToggleBound === "true") {
      return;
    }

    entry.addEventListener("toggle", () => {
      if (typeof window.refreshHostToggleLabel === "function") {
        window.refreshHostToggleLabel();
      }
    });
    entry.dataset.hostToggleBound = "true";
  });

  syncLabel();
}

function initializeServiceInventoryToggle() {
  const toggle = document.getElementById("toggle-all-service-inventory");
  const tableBody = document.getElementById("serviceInventoryTableBody");
  if (!toggle || !tableBody) return;

  function getServiceEntries() {
    return Array.from(tableBody.querySelectorAll("details.service-inventory-service-details"));
  }

  function syncLabel() {
    const serviceEntries = getServiceEntries();
    toggle.hidden = serviceEntries.length === 0;
    if (serviceEntries.length === 0) {
      return;
    }
    const allOpen = serviceEntries.every(entry => entry.open);
    toggle.setAttribute("aria-expanded", allOpen ? "true" : "false");
    toggle.setAttribute("title", allOpen ? "Collapse all visible service details" : "Expand all visible service details");
  }

  window.refreshServiceInventoryToggleLabel = syncLabel;

  if (toggle.dataset.serviceInventoryToggleInitialized !== "true") {
    toggle.addEventListener("click", () => {
      const serviceEntries = getServiceEntries();
      if (serviceEntries.length === 0) {
        return;
      }
      const shouldOpen = !serviceEntries.every(entry => entry.open);
      serviceEntries.forEach(entry => {
        entry.open = shouldOpen;
      });
      syncLabel();
    });
    toggle.dataset.serviceInventoryToggleInitialized = "true";
  }

  Array.from(tableBody.querySelectorAll("details.service-inventory-service-details")).forEach(entry => {
    if (entry.dataset.serviceInventoryToggleBound === "true") {
      return;
    }

    entry.addEventListener("toggle", () => {
      if (typeof window.refreshServiceInventoryToggleLabel === "function") {
        window.refreshServiceInventoryToggleLabel();
      }
    });
    entry.dataset.serviceInventoryToggleBound = "true";
  });

  syncLabel();
}

function syncDataTableFixedHeaders() {
  if (!(window.jQuery && $.fn.dataTable)) {
    return;
  }

  const tables = $.fn.dataTable.tables({ visible: true });
  if (!tables || tables.length === 0) {
    return;
  }

  const headerOffset = getDataTableHeaderOffset();

  Array.from(tables).forEach(table => {
    const api = $(table).DataTable();
    if (!api || !api.fixedHeader) {
      return;
    }

    if (typeof api.fixedHeader.headerOffset === "function") {
      api.fixedHeader.headerOffset(headerOffset);
    }

    if (typeof api.fixedHeader.adjust === "function") {
      api.fixedHeader.adjust();
    }
  });
}

function normalizeIpv6SortValue(address) {
  let value = (address || "").trim().toLowerCase();
  if (!value) {
    return "";
  }

  const zoneIndex = value.indexOf("%");
  if (zoneIndex !== -1) {
    value = value.slice(0, zoneIndex);
  }

  if (value.includes(".")) {
    const lastColonIndex = value.lastIndexOf(":");
    const ipv4Part = lastColonIndex === -1 ? value : value.slice(lastColonIndex + 1);

    if (/^\d{1,3}(\.\d{1,3}){3}$/.test(ipv4Part)) {
      const octets = ipv4Part.split(".").map(part => Number.parseInt(part, 10));
      if (octets.every(octet => Number.isInteger(octet) && octet >= 0 && octet <= 255)) {
        const high = ((octets[0] << 8) | octets[1]).toString(16);
        const low = ((octets[2] << 8) | octets[3]).toString(16);
        value = `${lastColonIndex === -1 ? "" : value.slice(0, lastColonIndex)}:${high}:${low}`;
      }
    }
  }

  const parts = value.split("::");
  if (parts.length > 2) {
    return `z-${value}`;
  }

  const left = parts[0] ? parts[0].split(":").filter(Boolean) : [];
  const right = parts.length === 2 && parts[1] ? parts[1].split(":").filter(Boolean) : [];
  const missingGroups = 8 - (left.length + right.length);

  if ((parts.length === 1 && left.length !== 8) || missingGroups < 0) {
    return `z-${value}`;
  }

  const expanded = parts.length === 2
    ? [...left, ...Array.from({ length: missingGroups }, () => "0"), ...right]
    : left;

  if (expanded.length !== 8) {
    return `z-${value}`;
  }

  return `6-${expanded.map(part => part.padStart(4, "0")).join(":")}`;
}

function normalizeIpSortValue(rawValue) {
  const value = (rawValue || "").trim().replace(/^\[/, "").replace(/\]$/, "");
  if (!value || value.toLowerCase() === "n/a") {
    return "";
  }

  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(value)) {
    const octets = value.split(".").map(part => Number.parseInt(part, 10));
    if (octets.every(octet => Number.isInteger(octet) && octet >= 0 && octet <= 255)) {
      return `4-${octets.map(octet => String(octet).padStart(3, "0")).join(".")}`;
    }
  }

  if (value.includes(":")) {
    return normalizeIpv6SortValue(value);
  }

  return `z-${value.toLowerCase()}`;
}

function applyAddressSortKeys(tableElement) {
  if (!tableElement) {
    return;
  }

  const headers = Array.from(tableElement.querySelectorAll("thead th")).map(header => ($(header).text() || '').trim());
  const addressColumnIndex = headers.indexOf("Address");
  if (addressColumnIndex === -1) {
    return;
  }

  tableElement.querySelectorAll("tbody tr").forEach(row => {
    const cells = row.querySelectorAll("td");
    if (cells.length <= addressColumnIndex) {
      return;
    }

    const addressCell = cells[addressColumnIndex];
    const addressText = (addressCell.textContent || "").trim();
    const sortValue = normalizeIpSortValue(addressText);
    if (sortValue) {
      addressCell.dataset.order = sortValue;
    }
  });
}

function unescapeRegex(text) {
  return (text || "").replace(/\\([.*+?^${}()|[\]\\])/g, "$1");
}

function extractExactSearchValue(searchValue) {
  const match = /^\^([\s\S]*)\$$/.exec(searchValue || "");
  return match ? unescapeRegex(match[1]) : "";
}

function isSignificantServiceValue(service) {
  const normalized = (service || "").trim().toLowerCase();
  return normalized !== "" && normalized !== "unknown" && normalized !== "ssl/unknown";
}

function syncDataTableSearchInputState(table, wrapper) {
  if (!table || !wrapper) {
    return;
  }

  const searchInput = wrapper.querySelector(".dataTables_filter input, .dt-search input");
  if (!searchInput) {
    return;
  }

  const hasActiveSearch = String(table.search() || "").trim() !== "";
  searchInput.classList.toggle("datatable-filter-active", hasActiveSearch);
}

function resolveDataTableResetScrollTarget(table, selector) {
  const sectionIdsBySelector = {
    "#table-services": "openservices",
    "#table-overview": "scannedhosts",
    "#service-inventory": "serviceinventory"
  };

  const mappedSectionId = sectionIdsBySelector[selector];
  if (mappedSectionId) {
    const mappedSection = document.getElementById(mappedSectionId);
    if (mappedSection) {
      return mappedSection;
    }
  }

  const tableNode = table && typeof table.table === "function" ? table.table().node() : null;
  const tableWrapper = tableNode ? tableNode.closest(".table-responsive") : null;
  let current = tableWrapper || tableNode;
  while (current) {
    let sibling = current.previousElementSibling;
    while (sibling) {
      if (/^H[1-6]$/.test(sibling.tagName)) {
        return sibling;
      }
      sibling = sibling.previousElementSibling;
    }
    current = current.parentElement;
  }

  return tableNode;
}

function resetDataTableExpandedState(selector) {
  if (selector !== "#service-inventory") {
    return;
  }

  const serviceInventoryTableBody = document.getElementById("serviceInventoryTableBody");
  if (!serviceInventoryTableBody) {
    return;
  }

  serviceInventoryTableBody.querySelectorAll("details[open]").forEach(details => {
    details.open = false;
  });
}

function initializeDataTableResetButton(table, wrapper, selector, defaultOrder) {
  if (!table || !wrapper) {
    return;
  }

  const resetContainer = wrapper.querySelector(".datatable-footer-end");
  if (!resetContainer || resetContainer.querySelector(".datatable-reset-button")) {
    return;
  }

  const resetButton = document.createElement("button");
  resetButton.type = "button";
  resetButton.className = "btn btn-outline-secondary btn-sm datatable-reset-button";
  resetButton.textContent = "Reset";
  resetButton.setAttribute("aria-label", "Reset table filters and sort order");
  resetContainer.appendChild(resetButton);

  resetButton.addEventListener("click", () => {
    const searchInput = wrapper.querySelector(".dataTables_filter input, .dt-search input");
    if (searchInput) {
      searchInput.value = "";
      searchInput.classList.remove("datatable-filter-active");
    }

    const serviceFilter = wrapper.querySelector(".datatable-inline-filter .form-select");
    if (serviceFilter) {
      serviceFilter.value = "";
      serviceFilter.classList.remove("datatable-filter-active");
      serviceFilter.dispatchEvent(new Event("change", { bubbles: true }));
    }

    table.search("");
    table.columns().search("");
    table.order((defaultOrder || [[0, "desc"]]).map(([columnIndex, direction]) => [Number(columnIndex), direction]));
    table.page("first").draw();
    resetDataTableExpandedState(selector);

    const resetScrollTarget = resolveDataTableResetScrollTarget(table, selector);
    if (resetScrollTarget) {
      window.requestAnimationFrame(() => {
        window.scrollTo({
          top: getReportScrollTop(resetScrollTarget),
          behavior: "smooth"
        });
      });
    }
  });
}

function initializeServiceDropdownFilter(table, tableElement, options = {}) {
  if (!table || !tableElement) {
    return;
  }

  const tableLabel = options.tableLabel || "services";

  const wrapper = table.table().container();
  if (!wrapper) {
    return;
  }

  const headers = Array.from(tableElement.querySelectorAll("thead th")).map(header => ($(header).text() || "").trim());
  const serviceColumnIndex = headers.indexOf("Service");
  const productColumnIndex = headers.indexOf("Product");
  const versionColumnIndex = headers.indexOf("Version");
  if (serviceColumnIndex === -1 || productColumnIndex === -1 || versionColumnIndex === -1) {
    return;
  }

  const searchContainer = wrapper.querySelector(".dataTables_filter, .dt-search");
  if (!searchContainer) {
    return;
  }

  const serviceCounts = new Map();

  table
    .column(serviceColumnIndex, { search: "none", order: "index" })
    .data()
    .toArray()
    .map(value => $("<div>").html(value).text().trim())
    .filter(isSignificantServiceValue)
    .forEach(service => {
      serviceCounts.set(service, (serviceCounts.get(service) || 0) + 1);
    });

  const serviceEntries = Array.from(serviceCounts.entries())
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], undefined, {
      numeric: true,
      sensitivity: "base"
    }));
  const services = serviceEntries.map(([service]) => service);

  if (services.length === 0) {
    return;
  }

  const filterId = `${tableElement.id || "table-services"}-service-filter`;
  const container = document.createElement("div");
  const label = document.createElement("label");
  const select = document.createElement("select");
  const defaultOrder = [[0, "desc"]];
  let activeServiceFilter = "";
  let lastUnfilteredOrder = defaultOrder;

  container.className = "datatable-inline-filter";
  label.className = "datatable-inline-filter-label";
  label.htmlFor = filterId;
  label.textContent = "Service";
  select.className = "form-select form-select-sm";
  select.id = filterId;
  select.setAttribute("aria-label", `Filter ${tableLabel} by service name`);

  const allOption = document.createElement("option");
  allOption.value = "";
  allOption.textContent = "All services";
  select.appendChild(allOption);

  serviceEntries.forEach(([service, count]) => {
    const option = document.createElement("option");
    option.value = service;
    option.textContent = `${service} (${count})`;
    select.appendChild(option);
  });

  container.appendChild(label);
  container.appendChild(select);
  searchContainer.appendChild(container);

  const loadedState = typeof table.state === "function" ? table.state.loaded() : null;
  const loadedColumnSearch = loadedState && Array.isArray(loadedState.columns) && loadedState.columns[serviceColumnIndex]
    ? loadedState.columns[serviceColumnIndex].search.search
    : "";
  const currentColumnSearch = table.column(serviceColumnIndex).search();
  const initialServiceFilter = extractExactSearchValue(loadedColumnSearch || currentColumnSearch);
  const initialOrder = loadedState && Array.isArray(loadedState.order) && loadedState.order.length > 0
    ? loadedState.order
    : table.order();

  if (!initialServiceFilter && Array.isArray(initialOrder) && initialOrder.length > 0) {
    lastUnfilteredOrder = initialOrder.map(([columnIndex, direction]) => [Number(columnIndex), direction]);
  }

  function applyServiceFilter(service) {
    activeServiceFilter = service || "";
    select.classList.toggle("datatable-filter-active", activeServiceFilter !== "");

    if (activeServiceFilter) {
      table
        .column(serviceColumnIndex)
        .search(`^${escapeRegex(activeServiceFilter)}$`, true, false);
      table
        .order([
          [productColumnIndex, "asc"],
          [versionColumnIndex, "asc"]
        ])
        .draw();
      return;
    }

    table
      .column(serviceColumnIndex)
      .search("");
    table
      .order(lastUnfilteredOrder)
      .draw();
  }

  table.on("order.dt", function () {
    if (activeServiceFilter) {
      return;
    }
    const currentOrder = table.order();
    if (Array.isArray(currentOrder) && currentOrder.length > 0) {
      lastUnfilteredOrder = currentOrder.map(([columnIndex, direction]) => [Number(columnIndex), direction]);
    }
  });

  select.addEventListener("change", event => {
    applyServiceFilter(event.target.value);
  });

  if (initialServiceFilter && services.includes(initialServiceFilter)) {
    select.value = initialServiceFilter;
    applyServiceFilter(initialServiceFilter);
  } else {
    select.classList.remove("datatable-filter-active");
  }
}

function initializeDataTable(selector) {
  const exportNames = {
    "#table-services": "nmapview-open-services",
    "#table-overview": "nmapview-scanned-hosts",
    "#service-inventory": "nmapview-service-inventory"
  };
  const exportName = exportNames[selector] || "nmapview-table-export";
  const defaultOrders = {
    "#table-services": [[2, "asc"], [1, "asc"]],
    "#service-inventory": [[0, "desc"]]
  };
  const buttons = [];

  if (selector !== '#service-inventory') {
    buttons.push(
      {
        extend: 'colvis',
        text: 'Columns',
        className: 'btn btn-light'
      },
      {
        extend: 'csvHtml5',
        text: 'CSV',
        filename: exportName,
        fieldSeparator: ';',
        exportOptions: { columns: getDataTableExportColumnSelector(), orthogonal: 'export' },
        className: 'btn btn-light'
      },
      {
        extend: 'excelHtml5',
        text: 'Excel',
        filename: exportName,
        autoFilter: true,
        exportOptions: { columns: getDataTableExportColumnSelector(), orthogonal: 'export' },
        className: 'btn btn-light'
      },
      {
        text: 'JSON',
        className: 'btn btn-light',
        action: function (e, dt, node, config) {
          const visibleColumns = dt.columns(getDataTableExportColumnSelector());
          const headerIndexes = visibleColumns.indexes().toArray();
          const headers = visibleColumns.header().toArray().map(h => $(h).text().trim());

          const data = dt.rows({ search: 'applied' }).nodes().toArray()
            .filter(row => isRowIncludedInCurrentExportScope(row))
            .map(row => {
            const obj = {};
            headerIndexes.forEach((columnIndex, i) => {
              const cell = $(row).find('td').get(columnIndex);
              obj[headers[i]] = cell ? $(cell).text().trim() : '';
            });
            return obj;
          });

          const json = JSON.stringify(data, null, 2);
          const blob = new Blob([json], { type: 'application/json' });
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = `${exportName}.json`;
          a.click();
          URL.revokeObjectURL(url);
        }
      }
    );

    if (selector !== '#table-services' && selector !== '#table-overview') {
      buttons.splice(1, 0, {
        extend: 'copyHtml5',
        text: 'Copy',
        title: exportName,
        exportOptions: { rows: getDataTableExportRowSelector(), columns: getDataTableExportColumnSelector(), orthogonal: 'export' },
        className: 'btn btn-light'
      });
    }
  }

  if (selector === '#table-services') {
    buttons.push({
      extend: 'collection',
      text: 'Copy',
      className: 'btn btn-light',
      buttons: [
        {
          text: 'All',
          action: async function (e, dt) {
            await copyVisibleDataTableRows(dt);
          }
        },
        {
          text: 'IPs',
          action: async function (e, dt) {
            const addresses = [];

            getScopedDataTableRows(dt).forEach(row => {
              const cells = $(row).find('td');
              const address = ($(cells.get(1)).text() || '').trim();

              if (address) {
                addresses.push(address);
              }
            });

            const uniqueAddresses = [...new Set(addresses)]
              .sort((left, right) => left.localeCompare(right, undefined, {
                numeric: true,
                sensitivity: 'base'
              }));

            await copyTextWithFeedback(
              uniqueAddresses.join('\n'),
              `Copied ${uniqueAddresses.length} IP${uniqueAddresses.length === 1 ? "" : "s"}`
            );
          }
        },
        {
          text: 'Ports',
          action: async function (e, dt) {
            const ports = [];

            getScopedDataTableRows(dt).forEach(row => {
              const cells = $(row).find('td');
              const port = ($(cells.get(2)).text() || '').trim();

              if (port) {
                ports.push(port);
              }
            });

            const uniquePorts = [...new Set(ports)]
              .sort((left, right) => Number(left) - Number(right) || left.localeCompare(right, undefined, {
                numeric: true,
                sensitivity: 'base'
              }));

            await copyTextWithFeedback(
              uniquePorts.join(','),
              `Copied ${uniquePorts.length} port${uniquePorts.length === 1 ? "" : "s"}`
            );
          }
        },
        {
          text: 'IP:Ports',
          action: async function (e, dt) {
            const endpoints = [];

            getScopedDataTableRows(dt).forEach(row => {
              const cells = $(row).find('td');
              const address = ($(cells.get(1)).text() || '').trim();
              const port = ($(cells.get(2)).text() || '').trim();

              if (address && port) {
                endpoints.push(`${address}:${port}`);
              }
            });

            const uniqueEndpoints = [...new Set(endpoints)];
            await copyTextWithFeedback(
              uniqueEndpoints.join('\n'),
              `Copied ${uniqueEndpoints.length} IP:Port entr${uniqueEndpoints.length === 1 ? "y" : "ies"}`
            );
          }
        }
      ]
    });
  }

  if (selector === '#table-overview') {
    buttons.push({
      extend: 'collection',
      text: 'Copy',
      className: 'btn btn-light',
      buttons: [
        {
          text: 'All',
          action: async function (e, dt) {
            await copyVisibleDataTableRows(dt);
          }
        },
        {
          text: 'IPs',
          action: async function (e, dt) {
            const addresses = [];

            getScopedDataTableRows(dt).forEach(row => {
              const cells = $(row).find('td');
              const address = ($(cells.get(4)).text() || '').trim();

              if (address && address.toLowerCase() !== 'n/a') {
                addresses.push(address);
              }
            });

            const uniqueAddresses = [...new Set(addresses)]
              .sort((left, right) => left.localeCompare(right, undefined, {
                numeric: true,
                sensitivity: 'base'
              }));

            await copyTextWithFeedback(
              uniqueAddresses.join('\n'),
              `Copied ${uniqueAddresses.length} IP${uniqueAddresses.length === 1 ? "" : "s"}`
            );
          }
        },
        {
          text: 'Hostnames',
          action: async function (e, dt) {
            const hostnames = [];

            getScopedDataTableRows(dt).forEach(row => {
              const cells = $(row).find('td');
              const hostname = ($(cells.get(5)).text() || '').trim();

              if (hostname && hostname.toLowerCase() !== 'n/a') {
                hostnames.push(hostname);
              }
            });

            const uniqueHostnames = [...new Set(hostnames)]
              .sort((left, right) => left.localeCompare(right, undefined, {
                numeric: true,
                sensitivity: 'base'
              }));

            await copyTextWithFeedback(
              uniqueHostnames.join('\n'),
              `Copied ${uniqueHostnames.length} hostname${uniqueHostnames.length === 1 ? "" : "s"}`
            );
          }
        }
      ]
    });
  }

  const columnDefs = [
    { targets: [0], orderable: true }
  ];

  const tableElement = document.querySelector(selector);
  if (tableElement) {
    applyAddressSortKeys(tableElement);

    const headers = Array.from(tableElement.querySelectorAll("thead th")).map(header => ($(header).text() || '').trim());
    [
      "Port",
      "Port Hosts",
      "Count",
      "Host Count",
      "Uptime (est.)",
      "Hops",
      "Rarity",
      "TCP Ports",
      "UDP Ports"
    ].forEach(headerName => {
      const columnIndex = headers.indexOf(headerName);
      if (columnIndex !== -1) {
        columnDefs.push({ targets: [columnIndex], type: 'num' });
      }
    });

    if (selector === '#service-inventory') {
      const hostDetailsColumnIndex = headers.indexOf("Host Details");
      if (hostDetailsColumnIndex !== -1) {
        columnDefs.push({ targets: [hostDetailsColumnIndex], type: 'num' });
      }
    }

    if (selector === '#table-overview') {
      const scopeColumnIndex = Array.from(tableElement.querySelectorAll("thead th"))
        .findIndex(header => header.classList.contains("host-scope-column"));
      if (scopeColumnIndex !== -1) {
        columnDefs.push({ targets: [scopeColumnIndex], orderable: false, searchable: false });
      }
    }

  }

  const table = $(selector).DataTable({
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    order: defaultOrders[selector] || [[0, 'desc']],
    columnDefs: columnDefs,
    dom: '<"datatable-toolbar"<"datatable-toolbar-start"l><"datatable-toolbar-center"f><"datatable-toolbar-end"B>>rt<"datatable-footer"<"datatable-footer-start"ip><"datatable-footer-end">>',
    stateSave: false,
    buttons: buttons,
    fixedHeader: {
      header: true,
      headerOffset: getDataTableHeaderOffset()
    }
  });

  const wrapper = table.table().container();
  if (wrapper) {
    const searchInput = wrapper.querySelector(".dataTables_filter input, .dt-search input");
    if (searchInput) {
      const syncSearchState = () => syncDataTableSearchInputState(table, wrapper);
      searchInput.addEventListener("input", syncSearchState);
      table.on("search.dt", syncSearchState);
      syncSearchState();
    }

    initializeDataTableResetButton(table, wrapper, selector, defaultOrders[selector] || [[0, "desc"]]);
  }

  if (selector === '#table-services') {
    initializeServiceDropdownFilter(table, tableElement, {
      tableLabel: "Open Services"
    });
  }

  window.requestAnimationFrame(syncDataTableFixedHeaders);
  return table;
}

function initializeDensityToggle() {
  const body = document.body;
  const buttons = Array.from(document.querySelectorAll("[data-density]"));
  if (!body || buttons.length === 0) {
    return;
  }

  const storageKey = "nmapview-table-density";

  function syncButtons(density) {
    buttons.forEach(button => {
      const isActive = button.getAttribute("data-density") === density;
      button.classList.toggle("btn-secondary", isActive);
      button.classList.toggle("btn-outline-secondary", !isActive);
      button.setAttribute("aria-pressed", isActive ? "true" : "false");
    });
  }

  function applyDensity(density) {
    const normalized = density === "dense" ? "dense" : "comfortable";
    body.classList.remove("report-density-comfortable", "report-density-dense");
    body.classList.add(`report-density-${normalized}`);
    syncButtons(normalized);
    try {
      window.localStorage.setItem(storageKey, normalized);
    } catch (error) {
    }

    if (window.jQuery && $.fn.dataTable) {
      const tables = $.fn.dataTable.tables({ visible: true });
      if (tables && tables.length > 0) {
        new $.fn.dataTable.Api(tables).columns.adjust();
      }
      syncDataTableFixedHeaders();
    }
  }

  const savedDensity = (() => {
    try {
      return window.localStorage.getItem(storageKey);
    } catch (error) {
      return null;
    }
  })();

  applyDensity(savedDensity || "comfortable");

  buttons.forEach(button => {
    button.addEventListener("click", () => {
      applyDensity(button.getAttribute("data-density"));
    });
  });
}

function escapeRegex(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function unwrapHighlight(node) {
  const parent = node.parentNode;
  if (!parent) return;

  while (node.firstChild) {
    parent.insertBefore(node.firstChild, node);
  }
  parent.removeChild(node);
}

function clearKeywordHighlights() {
  document.querySelectorAll("mark.keyword-highlight-mark").forEach(unwrapHighlight);
}

function parseHighlightTerms(raw) {
  return [...new Set(
    (raw || "")
      .split(",")
      .map(term => term.trim())
      .filter(Boolean)
  )];
}

function normalizeHighlightWildcard(pattern) {
  let normalized = "";

  for (let index = 0; index < pattern.length; index++) {
    const character = pattern[index];
    const previousCharacter = index > 0 ? pattern[index - 1] : "";

    if (character === "*" && previousCharacter !== "\\") {
      normalized += ".*";
      continue;
    }

    normalized += character;
  }

  return normalized;
}

function isRegexHighlightTerm(term) {
  return (
    /^\/.+\/$/.test(term) ||
    /^\^/.test(term) ||
    /\$$/.test(term) ||
    /(^|[^\\])\*/.test(term) ||
    /\\[dDsSwWbB]/.test(term) ||
    /(^|[^\\])[\[\]\(\)\|\+\?\{\}]/.test(term)
  );
}

function getHighlightPatternSource(term) {
  if (!isRegexHighlightTerm(term)) {
    return escapeRegex(term);
  }

  const source = /^\/.+\/$/.test(term)
    ? term.slice(1, -1)
    : normalizeHighlightWildcard(term);

  try {
    new RegExp(source, "i");
    return source;
  } catch (error) {
    return escapeRegex(term);
  }
}

function buildHighlightRegex(rawTerms) {
  const terms = parseHighlightTerms(rawTerms);
  if (terms.length === 0) {
    return null;
  }

  const sources = terms.map(getHighlightPatternSource);
  return new RegExp(`(${sources.join("|")})`, "gi");
}

function highlightTextNode(textNode, regex) {
  const text = textNode.nodeValue;
  if (!text || !regex.test(text)) {
    regex.lastIndex = 0;
    return 0;
  }

  regex.lastIndex = 0;
  const fragment = document.createDocumentFragment();
  let lastIndex = 0;
  let matchCount = 0;
  let match;

  while ((match = regex.exec(text)) !== null) {
    const matchText = match[0];
    const matchIndex = match.index;

    if (matchIndex > lastIndex) {
      fragment.appendChild(document.createTextNode(text.slice(lastIndex, matchIndex)));
    }

    const mark = document.createElement("mark");
    mark.className = "keyword-highlight-mark";
    mark.textContent = matchText;
    fragment.appendChild(mark);
    lastIndex = matchIndex + matchText.length;
    matchCount++;
  }

  if (lastIndex < text.length) {
    fragment.appendChild(document.createTextNode(text.slice(lastIndex)));
  }

  textNode.parentNode.replaceChild(fragment, textNode);
  regex.lastIndex = 0;
  return matchCount;
}

function highlightKeywords(rawTerms) {
  clearKeywordHighlights();

  const regex = buildHighlightRegex(rawTerms);
  if (!regex) {
    return 0;
  }

  const container = document.getElementById("reportContent");
  if (!container) {
    return 0;
  }

  const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, {
    acceptNode(node) {
      const parent = node.parentElement;
      if (!parent) return NodeFilter.FILTER_REJECT;

      if (parent.closest(".keyword-highlight-controls")) {
        return NodeFilter.FILTER_REJECT;
      }

      const tagName = parent.tagName;
      if (["SCRIPT", "STYLE", "NOSCRIPT", "TEXTAREA", "INPUT", "MARK"].includes(tagName)) {
        return NodeFilter.FILTER_REJECT;
      }

      if (!node.nodeValue || !node.nodeValue.trim()) {
        return NodeFilter.FILTER_REJECT;
      }

      return NodeFilter.FILTER_ACCEPT;
    }
  });

  const textNodes = [];
  let currentNode;
  while ((currentNode = walker.nextNode())) {
    textNodes.push(currentNode);
  }

  let matchCount = 0;
  textNodes.forEach(node => {
    matchCount += highlightTextNode(node, regex);
  });

  if (matchCount > 0) {
    document.querySelectorAll("mark.keyword-highlight-mark").forEach(mark => {
      const hostEntry = mark.closest("details.host-entry");
      if (hostEntry) {
        hostEntry.open = true;
      }
    });

    const firstMatch = document.querySelector("mark.keyword-highlight-mark");
    if (firstMatch) {
      firstMatch.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  return matchCount;
}

function initializeKeywordHighlighter() {
  const input = document.getElementById("keywordHighlightInput");
  const highlightButton = document.getElementById("highlightKeywordsButton");
  const resetButton = document.getElementById("resetHighlightsButton");
  if (!input || !highlightButton || !resetButton) return;

  highlightButton.addEventListener("click", () => {
    highlightKeywords(input.value);
  });

  resetButton.addEventListener("click", () => {
    clearKeywordHighlights();
    input.focus();
  });

  input.addEventListener("keydown", event => {
    if (event.key === "Enter") {
      event.preventDefault();
      highlightKeywords(input.value);
    }
  });
}
