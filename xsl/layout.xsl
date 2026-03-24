<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template name="render-head">
      <head>
        <meta name="referrer" content="no-referrer"/>
        <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Crect width='64' height='64' rx='14' fill='%23f7f9fb'/%3E%3Ccircle cx='27' cy='27' r='15' fill='none' stroke='%2324313d' stroke-width='6'/%3E%3Cpath d='M38 38 L52 52' stroke='%2324313d' stroke-width='6' stroke-linecap='round'/%3E%3C/svg%3E"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.css" rel="stylesheet" crossorigin="anonymous"/>
        <script src="https://cdn.datatables.net/v/bs5/jq-3.7.0/jszip-3.10.1/dt-2.3.7/b-3.2.6/b-colvis-3.2.6/b-html5-3.2.6/b-print-3.2.6/fh-4.0.5/datatables.min.js" crossorigin="anonymous"/>
        <xsl:call-template name="render-visualization-head-assets"/>
        <style>
          :root {
            --report-page-bg: #eef2f5;
            --report-surface: #f7f9fb;
            --report-surface-muted: #e6ebf0;
            --report-surface-hover: #edf3f8;
            --report-border: #cfd8e3;
            --report-border-strong: #bcc8d6;
            --report-shadow: 0 0.35rem 1rem rgba(72, 94, 116, 0.08);
          }

          html,
          body {
            background: var(--report-page-bg);
          }

          body {
            color: #24313d;
          }

          body.report-initializing {
            overflow: hidden;
            height: 100vh;
          }

          .report-loading-overlay {
            position: fixed;
            inset: 0;
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
            background: rgba(238, 242, 245, 0.72);
            backdrop-filter: blur(6px);
            transition: opacity 0.2s ease, visibility 0.2s ease;
          }

          .report-loading-overlay-no-blur {
            background: rgba(238, 242, 245, 0.36);
            backdrop-filter: none;
          }

          .report-loading-overlay.is-hidden {
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
          }

          .report-loading-card {
            min-width: min(100%, 18rem);
            padding: 1rem 1.1rem;
            border: 1px solid var(--report-border);
            border-radius: 0.8rem;
            background: var(--report-surface);
            box-shadow: var(--report-shadow);
            text-align: center;
          }

          .report-loading-title {
            margin: 0;
            font-size: 0.98rem;
            font-weight: 700;
            color: #24313d;
          }

          .report-loading-dots {
            display: inline-flex;
            align-items: center;
            gap: 0.16rem;
            margin-left: 0.18rem;
            vertical-align: middle;
          }

          .report-loading-dot {
            width: 0.26rem;
            height: 0.26rem;
            border-radius: 999px;
            background: currentColor;
            opacity: 0.22;
            animation: report-loading-dot-pulse 1.05s infinite ease-in-out;
          }

          .report-loading-dot:nth-child(2) {
            animation-delay: 0.16s;
          }

          .report-loading-dot:nth-child(3) {
            animation-delay: 0.32s;
          }

          @keyframes report-loading-dot-pulse {
            0%,
            80%,
            100% {
              opacity: 0.22;
              transform: translateY(0);
            }

            40% {
              opacity: 0.9;
              transform: translateY(-0.08rem);
            }
          }

          @media (prefers-reduced-motion: reduce) {
            .report-loading-dot {
              animation: none;
              opacity: 0.55;
              transform: none;
            }
          }

          #reportContent {
            width: 100%;
            max-width: 100%;
            min-width: 0;
            padding-top: 5.5rem;
          }

          a {
            text-decoration: none !important;
          }

          .host-list {
            display: grid;
            gap: 1rem;
          }

          .service-inventory-hosts-cell {
            min-width: 18rem;
          }

          .service-inventory-name-column,
          .service-inventory-name-cell {
            width: 8.5rem;
            max-width: 10rem;
            white-space: normal;
            overflow-wrap: anywhere;
          }

          .service-inventory-count-column {
            width: 7.25rem;
            white-space: nowrap;
          }

          #service-inventory tbody tr > td {
            --service-inventory-row-bg: #edf2f6;
            --service-inventory-row-bg-muted: #dbe4ec;
            --service-inventory-row-bg-soft: rgba(219, 228, 236, 0.8);
          }

          #service-inventory.table-striped > tbody > tr:nth-of-type(odd) > td {
            --service-inventory-row-bg: #fbfcfd;
            --service-inventory-row-bg-muted: #f2f5f8;
            --service-inventory-row-bg-soft: rgba(242, 245, 248, 0.92);
          }

          .service-inventory-service-details {
            border: 1px solid var(--report-border);
            border-radius: 0.55rem;
            background: var(--service-inventory-row-bg);
            overflow: hidden;
          }

          .service-inventory-service-summary {
            cursor: pointer;
            list-style: none;
            padding: 0.55rem 0.7rem;
            display: flex;
            align-items: flex-start;
            gap: 0.45rem;
          }

          .service-inventory-service-summary::-webkit-details-marker {
            display: none;
          }

          .service-inventory-service-summary::before {
            content: "▸";
            color: #3f5f74;
            font-size: 0.95rem;
            line-height: 1.2;
            flex: 0 0 auto;
            transform-origin: center;
            transition: transform 0.16s ease;
          }

          .service-inventory-service-details[open] .service-inventory-service-summary::before {
            transform: rotate(90deg);
          }

          .service-inventory-service-summary {
            background: var(--service-inventory-row-bg-muted);
          }

          .service-inventory-summary-line {
            display: flex;
            flex-wrap: wrap;
            gap: 0.25rem 0.7rem;
            align-items: baseline;
          }

          .service-inventory-service-meta {
            color: #5b6977;
            font-size: 0.92rem;
            overflow-wrap: anywhere;
          }

          .service-inventory-service-body {
            padding: 0.55rem 0.7rem 0.7rem;
          }

          .service-inventory-host-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
          }

          .service-inventory-host-table th,
          .service-inventory-host-table td {
            padding: 0.35rem 0.45rem;
            border-top: 1px solid rgba(188, 200, 214, 0.7);
            vertical-align: top;
            text-align: left;
          }

          .service-inventory-host-table thead th {
            border-top: 0;
            color: #5b6977;
            font-size: 0.82rem;
            font-weight: 600;
            background: var(--service-inventory-row-bg-soft);
          }

          .service-inventory-host-table tbody tr:first-child td {
            border-top: 0;
          }

          .service-inventory-host-table tbody tr.service-inventory-product-separator td {
            border-top: 0.22rem solid var(--report-border-strong);
          }

          .service-inventory-host-table tbody tr.service-inventory-variant-separator td {
            border-top: 0.14rem solid rgba(188, 200, 214, 0.95);
          }

          .service-inventory-host-bucket-column {
            width: 30%;
          }

          .service-inventory-host-column {
            width: 26%;
          }

          .service-inventory-host-ports-column {
            width: 22%;
          }

          .service-inventory-host-service-column {
            width: 22%;
          }

          .service-inventory-host-link {
            color: #0a58ca;
            overflow-wrap: anywhere;
          }

          .service-inventory-empty {
            margin: 0;
            color: #6c757d;
          }

          .host-entry {
            border: 1px solid var(--report-border);
            border-radius: 0.5rem;
            background: var(--report-surface);
            box-shadow: 0 0.125rem 0.4rem rgba(72, 94, 116, 0.08);
            overflow: hidden;
          }

          .host-entry-summary {
            cursor: pointer;
            list-style: none;
            padding: 1rem 1.25rem;
            background: var(--report-surface-muted);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.75rem;
          }

          .host-entry-summary::-webkit-details-marker {
            display: none;
          }

          .host-entry-summary::before {
            content: "+";
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.5rem;
            height: 1.5rem;
            border-radius: 999px;
            background: #0d6efd;
            color: #fff;
            font-weight: 700;
            flex: 0 0 auto;
          }

          .host-entry[open] .host-entry-summary::before {
            content: "-";
          }

          .host-entry-anchor {
            display: block;
            position: relative;
            top: -4rem;
            visibility: hidden;
            width: 0;
            height: 0;
          }

          .host-entry-label {
            flex: 1 1 auto;
          }

          .host-entry-body {
            padding: 1.25rem;
          }

          .certificate-block {
            display: grid;
            gap: 0.2rem;
            max-width: 20rem;
          }

          .certificate-row {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.3;
          }

          .certificate-label {
            font-weight: 600;
          }

          .certificate-value {
            display: inline;
          }

          .certificate-expiry-value {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            flex-wrap: wrap;
            max-width: 100%;
          }

          .certificate-expiry-row {
            display: flex;
            align-items: flex-start;
            gap: 0.35rem;
            white-space: normal;
            overflow: visible;
            text-overflow: clip;
          }

          .certificate-expiry-row .certificate-label {
            flex: 0 0 auto;
          }

          .certificate-expiry-row .certificate-expiry-value {
            flex: 1 1 auto;
            min-width: 0;
          }

          .certificate-expiry-badge {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.15rem 0.55rem;
            font-size: 0.72rem;
            font-style: normal;
            font-weight: 700;
            letter-spacing: 0.01em;
            line-height: 1.2;
            white-space: nowrap;
            border: 1px solid transparent;
          }

          .certificate-expiry-badge.is-valid {
            background: #e8f5e9;
            border-color: #b7dfbd;
            color: #1f6f43;
          }

          .certificate-expiry-badge.is-expiring {
            background: #fff3cd;
            border-color: #f3d58a;
            color: #8a5a00;
          }

          .certificate-expiry-badge.is-expired {
            background: #f8d7da;
            border-color: #ecb5bc;
            color: #a61e2f;
          }

          .certificate-expiry-badge.is-long-lived {
            background: #fff0db;
            border-color: #e9c896;
            color: #8a5a00;
          }

          .http-title-block {
            max-width: 20rem;
          }

          .http-title-value {
            display: block;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .web-http-column {
            min-width: 22rem;
          }

          .web-cert-column {
            min-width: 16rem;
          }

          .http-details-block {
            display: grid;
            gap: 0.2rem;
            max-width: 26rem;
          }

          .service-extra-http {
            margin-top: 0.35rem;
          }

          .summary-command {
            margin: 1rem 0 0;
            border: 1px solid var(--report-border);
            border-radius: 0.5rem;
            background: rgba(247, 249, 251, 0.84);
          }

          .summary-command summary {
            cursor: pointer;
            padding: 0.75rem 1rem;
            color: #6c757d;
            font-size: 0.95rem;
            font-weight: 600;
          }

          .summary-command pre {
            margin: 0;
            padding: 0 1rem 1rem;
            font-size: 0.9rem;
            background: transparent;
            border: 0;
            color: #495057;
            white-space: pre-wrap;
            word-wrap: break-word;
          }

          .summary-progress {
            height: 1.75rem;
            font-size: 0.95rem;
            overflow: visible;
          }

          .summary-progress .progress-bar {
            font-weight: 600;
            white-space: nowrap;
            overflow: visible;
            padding: 0 0.45rem;
            min-width: max-content;
            justify-content: center;
          }

          .summary-progress .progress-bar.bg-warning {
            color: #212529;
          }

          .summary-card-link {
            display: block;
            color: inherit;
          }

          .summary-card-link:hover,
          .summary-card-link:focus-visible {
            color: inherit;
          }

          .summary-card {
            border: 1px solid var(--report-border);
            border-radius: 0.85rem;
            background: var(--report-surface);
            height: 100%;
            padding: 1rem;
            transition: transform 0.16s ease, box-shadow 0.16s ease, border-color 0.16s ease;
          }

          .summary-card-label {
            color: #5f6e7d;
            font-size: 0.84rem;
            font-weight: 600;
            letter-spacing: 0.01em;
            line-height: 1.3;
          }

          .summary-card-value {
            margin-top: 0.2rem;
            font-size: 1.85rem;
            font-weight: 600;
            line-height: 1.15;
            color: #24313d;
          }

          .summary-card.is-clickable {
            cursor: pointer;
          }

          .summary-card-link:hover .summary-card,
          .summary-card-link:focus-visible .summary-card {
            transform: translateY(-1px);
            box-shadow: 0 0.45rem 1rem rgba(72, 94, 116, 0.12);
            border-color: var(--report-border-strong);
          }

          .summary-toolbar {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 1rem;
            margin-top: 1rem;
            align-items: center;
          }

          .summary-note {
            display: inline-flex;
            align-items: flex-start;
            gap: 0.5rem;
            margin-top: 0.85rem;
            color: #5f6e7d;
            font-size: 0.9rem;
            line-height: 1.45;
          }

          .summary-note-icon {
            display: inline-block;
            color: #3f5f74;
            font-size: 0.95rem;
            font-weight: 600;
            flex: 0 0 auto;
            line-height: 1;
            margin-top: 0.1rem;
          }

          .density-controls {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
          }

          .density-controls-label {
            font-size: 0.82rem;
            font-weight: 600;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            color: #6c757d;
            white-space: nowrap;
          }

          .density-toggle-group .btn {
            min-width: 7rem;
          }

          body.report-density-comfortable .table {
            font-size: 0.95rem;
            line-height: 1.4;
          }

          body.report-density-comfortable .table > :not(caption) > * > * {
            padding-top: 0.75rem;
            padding-bottom: 0.75rem;
          }

          body.report-density-dense .table {
            font-size: 0.86rem;
            line-height: 1.2;
          }

          body.report-density-dense .table > :not(caption) > * > * {
            padding-top: 0.3rem;
            padding-bottom: 0.3rem;
            padding-left: 0.45rem;
            padding-right: 0.45rem;
          }

          body.report-density-dense .table .badge {
            font-size: 0.72rem;
          }

          body.report-density-dense .host-entry-summary {
            padding: 0.8rem 1rem;
            font-size: 0.95rem;
          }

          body.report-density-dense .service-inventory-service-summary {
            padding: 0.45rem 0.6rem;
          }

          body.report-density-dense .service-inventory-service-body {
            padding: 0.45rem 0.6rem 0.6rem;
          }

          body.report-density-dense .host-entry-body {
            padding: 0.8rem;
          }

          body.report-density-dense .summary-command summary {
            padding: 0.55rem 0.85rem;
            font-size: 0.85rem;
          }

          body.report-density-dense .summary-command pre {
            padding: 0 0.85rem 0.85rem;
            font-size: 0.82rem;
          }

          .vulners-summary {
            cursor: pointer;
            color: #495057;
            font-weight: 600;
          }

          .vulners-summary::-webkit-details-marker {
            display: none;
          }

          .vulners-list {
            margin-top: 0.5rem;
          }

          .cpe-copy {
            cursor: copy;
          }

          .cpe-copy.copied {
            color: #0a58ca !important;
          }

          .keyword-highlight-controls {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            align-items: center;
            margin-top: 1rem;
          }

          .keyword-highlight-controls .form-control {
            flex: 1 1 20rem;
            min-width: 16rem;
          }

          .keyword-highlight-controls .btn-warning {
            background-color: #e9ecef;
            border-color: #ced4da;
            color: #212529;
          }

          .keyword-highlight-controls .btn-warning:hover,
          .keyword-highlight-controls .btn-warning:focus,
          .keyword-highlight-controls .btn-warning:active {
            background-color: #dde1e5;
            border-color: #c6cbd1;
            color: #212529;
          }

          .keyword-highlight-mark {
            background: #fff3a3;
            color: inherit;
            padding: 0 0.15em;
            border-radius: 0.2rem;
          }

          .datatable-inline-filter {
            display: inline-flex;
            align-items: center;
            gap: 0.55rem;
            margin-left: 0.85rem;
          }

          .datatable-inline-filter-label {
            margin: 0;
            font-size: 0.88rem;
            font-weight: 600;
            color: #495057;
            white-space: nowrap;
          }

          .datatable-inline-filter .form-select {
            min-width: 11rem;
          }

          .datatable-filter-active {
            border-color: #198754 !important;
            box-shadow: 0 0 0 0.18rem rgba(25, 135, 84, 0.16);
          }

          .dtfh-floatingparenthead {
            z-index: 1020 !important;
          }

          .dtfh-floatingparenthead table {
            margin-top: 0 !important;
            background: var(--report-surface);
          }

          #mainNavbar {
            border-bottom: 1px solid var(--report-border);
            background: rgba(247, 249, 251, 0.94) !important;
            backdrop-filter: saturate(140%) blur(10px);
          }

          #summary,
          #scannedhosts,
          #openservices,
          #serviceinventory,
          #webtlsservices,
          #onlinehosts {
            scroll-margin-top: 5.5rem;
          }

          #reportContent > hr.my-4 {
            margin-top: 3.35rem !important;
            margin-bottom: 1.35rem !important;
            border: 0;
            height: 2px;
            border-radius: 999px;
            opacity: 1;
            background: linear-gradient(90deg, rgba(120, 144, 168, 0), rgba(120, 144, 168, 0.52), rgba(173, 186, 200, 0.48), rgba(120, 144, 168, 0.52), rgba(120, 144, 168, 0));
            box-shadow: 0 0 0 1px rgba(110, 132, 154, 0.06), 0 0.35rem 0.9rem rgba(110, 132, 154, 0.10);
          }

          #reportContent > h2.bg-light.rounded,
          #summary.bg-light,
          footer.footer.bg-light {
            background: var(--report-surface) !important;
          }

          #summary {
            border: 1px solid var(--report-border);
            box-shadow: var(--report-shadow);
            margin-top: 0 !important;
            margin-bottom: 3rem !important;
          }

          #reportContent > h2.bg-light.rounded {
            border: 1px solid var(--report-border);
            box-shadow: 0 0.15rem 0.56rem rgba(72, 94, 116, 0.075);
          }

          .section-heading-title {
            display: block;
            color: #24313d;
            font-weight: 600;
            line-height: 1.2;
          }

          .section-heading-subtitle {
            display: block;
            margin-top: 0.35rem;
            color: #637282;
            font-size: 0.92rem;
            font-weight: 400;
            line-height: 1.4;
          }

          .table {
            --bs-table-bg: var(--report-surface);
            --bs-table-striped-bg: #eef3f7;
            --bs-table-hover-bg: var(--report-surface-hover);
            --bs-table-border-color: var(--report-border);
            color: #24313d;
          }

          .table-light,
          .table > thead.table-light,
          .table > thead.table-light > tr > th,
          .table > thead.table-light > tr > td {
            --bs-table-bg: var(--report-surface-muted);
            --bs-table-border-color: var(--report-border);
            background: var(--report-surface-muted) !important;
            color: #24313d;
          }

          .table-responsive {
            background: transparent;
            border: 0;
            border-radius: 0;
            box-shadow: none;
          }

          .table-responsive > .dt-container,
          .table-responsive > table {
            background: var(--report-surface);
            border: 1px solid var(--report-border);
            border-radius: 0.75rem;
            box-shadow: var(--report-shadow);
          }

          .table-responsive > .dt-container {
            padding: 0.85rem 0.9rem 0.7rem;
          }

          .table-responsive > .dt-container .table {
            margin-bottom: 0.75rem;
          }

          .table-responsive > .dt-container .d-flex.justify-content-between.align-items-center.mb-2 {
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-bottom: 0.85rem !important;
          }

          .keyword-highlight-controls .form-control {
            background: var(--report-surface);
            border-color: var(--report-border);
          }

          .navbar-version-link {
            display: flex;
            align-items: center;
            height: 100%;
            margin-right: 0.35rem;
          }

          #mainNavbar .container-fluid {
            display: flex;
            align-items: center;
            overflow-x: auto;
            scrollbar-width: thin;
            gap: 0.75rem;
            flex-wrap: nowrap;
          }

          #navbarNav .navbar-nav.me-auto .nav-link {
            display: inline-flex;
            align-items: center;
            min-height: 3.45rem;
            padding: 0.75rem 1.2rem;
            border-radius: 0.75rem;
            font-weight: 500;
          }

          #navbarNav .navbar-nav.me-auto .nav-link:hover,
          #navbarNav .navbar-nav.me-auto .nav-link:focus-visible {
            background: rgba(13, 110, 253, 0.08);
          }

          #navbarNav .navbar-nav.me-auto .nav-link.is-active {
            background: rgba(13, 110, 253, 0.14);
            color: #0a58ca;
            box-shadow: inset 0 0 0 1px rgba(13, 110, 253, 0.12);
          }

          #navbarNav {
            width: 100%;
            display: flex !important;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            flex-wrap: nowrap;
            min-width: max-content;
          }

          #navbarNav .navbar-nav {
            flex-direction: row;
            flex-wrap: nowrap;
            gap: 0.25rem;
            min-width: max-content;
          }

          @media (max-width: 991.98px) {
            #mainNavbar .container-fluid {
              gap: 0.5rem;
            }

            #navbarNav {
              gap: 0.5rem;
            }

            #navbarNav .navbar-nav.me-auto .nav-link {
              min-height: 2.75rem;
              padding: 0.45rem 0.8rem;
              font-size: 0.92rem;
              border-radius: 0.6rem;
            }

            #navbarNav .navbar-nav.ms-auto .nav-link {
              padding: 0.35rem 0.55rem;
            }

          }

          <xsl:call-template name="render-visualization-styles"/>
        </style>
        <title>NmapView Report - Interactive Nmap Scan Summary</title>
      </head>
  </xsl:template>
  <xsl:template name="render-loading-overlay">
        <div id="reportLoadingOverlay" class="report-loading-overlay report-loading-overlay-no-blur" role="status" aria-live="polite" aria-label="Loading report">
          <div class="report-loading-card">
            <p class="report-loading-title">Preparing Report<span class="report-loading-dots" aria-hidden="true"><span class="report-loading-dot"/><span class="report-loading-dot"/><span class="report-loading-dot"/></span></p>
          </div>
        </div>
  </xsl:template>
  <xsl:template name="render-navbar">
        <nav id="mainNavbar" class="navbar navbar-light bg-light fixed-top">
          <div class="container-fluid">
            <div id="navbarNav">
              <ul class="navbar-nav me-auto">
                <li class="nav-item">
                  <a class="nav-link" href="#summary">Summary</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#scannedhosts">Host Overview</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#openservices">Open Services</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#serviceinventory">Service Summary</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#webtlsservices">Web/TLS Services</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#onlinehosts">Host Details</a>
                </li>
              </ul>
              <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                  <a class="nav-link navbar-version-link" href="https://github.com/dreizehnutters/NmapView">NmapView v3.2</a>
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
          <xsl:variable name="recorded-hosts" select="count(/nmaprun/host)"/>
          <xsl:variable name="runstats-total-hosts" select="number(/nmaprun/runstats/hosts/@total)"/>
          <xsl:variable name="total-hosts">
            <xsl:choose>
              <xsl:when test="$recorded-hosts &gt; 0">
                <xsl:value-of select="$recorded-hosts"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$runstats-total-hosts"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="up-hosts">
            <xsl:choose>
              <xsl:when test="$recorded-hosts &gt; 0">
                <xsl:value-of select="count(/nmaprun/host[status/@state='up'])"/>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="down-hosts">
            <xsl:choose>
              <xsl:when test="$recorded-hosts &gt; 0">
                <xsl:value-of select="count(/nmaprun/host[status/@state='down'])"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$runstats-total-hosts"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="open-ports" select="count(/nmaprun/host/ports/port[state/@state='open'])"/>
          <xsl:variable name="unique-services" select="count(//host/ports/port[state/@state='open' and service/@name]
            [generate-id() = generate-id(
              key('serviceGroup',
                concat(
                  substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),
                  service/@name,
                  '-',
                  @protocol
                )
              )[1]
            )])"/>
          <xsl:variable name="web-tls-endpoints" select="count(/nmaprun/host/ports/port[(@protocol='tcp') and (state/@state='open') and (starts-with(service/@name, 'http') or script[@id='ssl-cert'])])"/>
          <xsl:variable name="duration-seconds" select="number(/nmaprun/runstats/finished/@time) - number(/nmaprun/@start)"/>
          <xsl:variable name="duration-hours" select="floor($duration-seconds div 3600)"/>
          <xsl:variable name="duration-minutes" select="floor(($duration-seconds mod 3600) div 60)"/>
          <xsl:variable name="duration-remainder-seconds" select="floor($duration-seconds mod 60)"/>
          <div id="summary" class="bg-light p-4 rounded shadow-sm">
            <div class="row g-3 mb-4">
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#scannedhosts">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Hosts scanned</div>
                    <div class="summary-card-value">
                      <xsl:value-of select="$total-hosts"/>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#openservices">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Open ports</div>
                    <div class="summary-card-value">
                      <xsl:value-of select="$open-ports"/>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#serviceinventory">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Unique services</div>
                    <div class="summary-card-value">
                      <xsl:value-of select="$unique-services"/>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col-6 col-lg-3">
                <a class="summary-card-link" href="#webtlsservices">
                  <div class="summary-card is-clickable">
                    <div class="summary-card-label">Web/TLS endpoints</div>
                    <div class="summary-card-value">
                      <xsl:value-of select="$web-tls-endpoints"/>
                    </div>
                  </div>
                </a>
              </div>
            </div>
            <div class="progress summary-progress">
              <div class="progress-bar bg-success" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <xsl:attribute name="style">
                  <xsl:text>width:</xsl:text>
                  <xsl:choose>
                    <xsl:when test="$total-hosts &gt; 0">
                      <xsl:value-of select="$up-hosts div $total-hosts * 100"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>%;</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$up-hosts"/> Hosts up
              </div>
              <div class="progress-bar bg-warning" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <xsl:attribute name="style">
                  <xsl:text>width:</xsl:text>
                  <xsl:choose>
                    <xsl:when test="$total-hosts &gt; 0">
                      <xsl:value-of select="$down-hosts div $total-hosts * 100"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>%;</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$down-hosts"/> Hosts down
              </div>
            </div>
            <details class="summary-command">
              <summary>Nmap Version: <xsl:value-of select="/nmaprun/@version"/><xsl:text> | </xsl:text>Scan Duration: <xsl:value-of select="/nmaprun/@startstr"/> - <xsl:value-of select="/nmaprun/runstats/finished/@timestr"/><xsl:text> (</xsl:text><xsl:if test="$duration-hours &gt; 0"><xsl:value-of select="$duration-hours"/><xsl:text>h </xsl:text></xsl:if><xsl:if test="$duration-minutes &gt; 0 or $duration-hours &gt; 0"><xsl:value-of select="$duration-minutes"/><xsl:text>m </xsl:text></xsl:if><xsl:value-of select="$duration-remainder-seconds"/><xsl:text>s)</xsl:text></summary>
              <pre>
                <xsl:attribute name="text">
                  <xsl:value-of select="/nmaprun/@args"/>
                </xsl:attribute>
                <xsl:value-of select="/nmaprun/@args"/>
              </pre>
            </details>
            <div class="summary-note">
              <span class="summary-note-icon">ⓘ</span>
              <span>Nmap's service detection is heuristic and may include false positives.</span>
            </div>
            <div class="summary-toolbar">
              <div class="density-controls" aria-label="Table density controls">
                <span class="density-controls-label">Table Density</span>
                <div class="btn-group btn-group-sm density-toggle-group" role="group" aria-label="Select table density">
                  <button type="button" class="btn btn-outline-secondary" id="densityComfortable" data-density="comfortable" aria-pressed="true">Comfortable</button>
                  <button type="button" class="btn btn-outline-secondary" id="densityDense" data-density="dense" aria-pressed="false">Dense</button>
                </div>
              </div>
            </div>
            <div class="keyword-highlight-controls" aria-label="Keyword highlighter">
              <input
                type="text"
                id="keywordHighlightInput"
                class="form-control"
                placeholder="sha1, ^ftp, ssh$, http*"
                aria-label="Comma-separated keywords or regex patterns to highlight"
              />
              <button type="button" class="btn btn-warning" id="highlightKeywordsButton">Globally Highlight Keywords</button>
              <button type="button" class="btn btn-outline-secondary" id="resetHighlightsButton">Reset</button>
            </div>
          </div>
  </xsl:template>
  <xsl:template name="render-footer">
        <hr class="my-3"/>
        <footer class="footer bg-light py-3">
          <div class="container">
            <p class="text-muted mb-0 text-center">
              Generated with <a href="https://github.com/dreizehnutters/NmapView">NmapView</a></p>
          </div>
        </footer>
  </xsl:template>
  <xsl:template name="render-scripts">
        <script><![CDATA[
          function appendText(parent, text) {
            parent.appendChild(document.createTextNode(text));
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

          function initializeCertificateExpiryAlerts() {
            const dayMs = 24 * 60 * 60 * 1000;
            const msPerYear = 365.2425 * dayMs;

            document.querySelectorAll(".certificate-expiry-value").forEach(element => {
              if (element.querySelector(".certificate-expiry-badge")) {
                return;
              }

              const rawExpiry = (element.textContent || "").trim();
              const expiryTimestamp = parseCertificateExpiry(rawExpiry);
              if (expiryTimestamp === null) {
                return;
              }

              const rawValidFrom = (element.getAttribute("data-valid-from") || "").trim();
              const validFromTimestamp = parseCertificateExpiry(rawValidFrom);

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
                ? `${rawValidFrom} to ${rawExpiry} (${formatCertificateLifetimeYears(validityYears)})`
                : `${rawExpiry} (${formatCertificateDayCount(daysRemaining)})`;
              element.appendChild(badge);
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

          function formatInventoryPortList(portSet) {
            return Array.from(portSet || []).sort(compareInventoryPortLabels).join(", ");
          }

          function formatInventoryHostCount(count) {
            return `${count} Host${count === 1 ? "" : "s"}`;
          }

          function formatInventoryPortCount(count) {
            return `${count} Port${count === 1 ? "" : "s"}`;
          }

          function formatInventoryVariantSummary(variants) {
            const knownVariantCount = variants.filter(variant => !variant.isUnknown).length;
            const hasUnknown = variants.some(variant => variant.isUnknown);

            if (knownVariantCount === 0) {
              return "Unknown";
            }

            return `${knownVariantCount} Variant${knownVariantCount === 1 ? "" : "s"}${hasUnknown ? " + Unknown" : ""}`;
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

              if (!service || !address) {
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
                  ports: new Set()
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
            });

            const sortedServices = Array.from(services.values()).sort((left, right) => {
              return right.hosts.size - left.hosts.size || compareInventoryText(left.name, right.name);
            });

            tableBody.textContent = "";

            sortedServices.forEach(serviceRecord => {
              const row = document.createElement("tr");
              const serviceCell = document.createElement("td");
              const countCell = document.createElement("td");
              const hostsCell = document.createElement("td");
              const serviceDetails = document.createElement("details");
              const serviceSummary = document.createElement("summary");
              const serviceLine = document.createElement("div");
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

              serviceDetails.className = "service-inventory-service-details";
              serviceSummary.className = "service-inventory-service-summary";
              serviceLine.className = "service-inventory-summary-line";
              serviceMeta.className = "service-inventory-service-meta";
              serviceBody.className = "service-inventory-service-body";
              hostTable.className = "service-inventory-host-table";
              hostTableBucketHeader.className = "service-inventory-host-bucket-column";
              hostTableHostHeader.className = "service-inventory-host-column";
              hostTablePortsHeader.className = "service-inventory-host-ports-column";
              hostTableServiceHeader.className = "service-inventory-host-service-column";

              serviceCell.className = "service-inventory-name-cell";
              serviceCell.textContent = serviceRecord.name;
              countCell.textContent = String(serviceRecord.hosts.size);
              countCell.dataset.order = String(serviceRecord.hosts.size);
              hostsCell.className = "service-inventory-hosts-cell";

              serviceMeta.textContent = `${formatInventoryHostCount(serviceRecord.hosts.size)} • ${formatInventoryVariantSummary(variants)}`;
              serviceLine.appendChild(serviceMeta);
              serviceSummary.appendChild(serviceLine);
              hostTableBucketHeader.textContent = "Product";
              hostTableHostHeader.textContent = "Host";
              hostTablePortsHeader.textContent = "Port(s)";
              hostTableServiceHeader.textContent = "Service";
              hostTableHeadRow.appendChild(hostTableBucketHeader);
              hostTableHeadRow.appendChild(hostTableHostHeader);
              hostTableHeadRow.appendChild(hostTablePortsHeader);
              hostTableHeadRow.appendChild(hostTableServiceHeader);
              hostTableHead.appendChild(hostTableHeadRow);

              let previousProductGroup = "";
              let previousVariantLabel = "";

              variants.forEach(variantRecord => {
                const hosts = Array.from(variantRecord.hosts.values()).sort((left, right) => {
                  const leftLabel = buildServiceInventoryHostLabel(left.hostname, left.address);
                  const rightLabel = buildServiceInventoryHostLabel(right.hostname, right.address);
                  return compareInventoryText(leftLabel, rightLabel);
                });

                hosts.forEach(hostRecord => {
                  const row = document.createElement("tr");
                  const bucketCell = document.createElement("td");
                  const hostCell = document.createElement("td");
                  const portsCell = document.createElement("td");
                  const serviceCell = document.createElement("td");
                  const link = document.createElement("a");

                  link.className = "service-inventory-host-link";
                  link.href = `#onlinehosts-${hostRecord.address.replace(/[.:]/g, "-")}`;
                  link.textContent = buildServiceInventoryHostLabel(hostRecord.hostname, hostRecord.address);
                  if (variantRecord.productGroup !== previousProductGroup) {
                    row.classList.add("service-inventory-product-separator");
                    previousProductGroup = variantRecord.productGroup;
                    previousVariantLabel = variantRecord.label;
                  } else if (variantRecord.label !== previousVariantLabel) {
                    row.classList.add("service-inventory-variant-separator");
                    previousVariantLabel = variantRecord.label;
                  }
                  bucketCell.textContent = variantRecord.label;
                  hostCell.appendChild(link);
                  portsCell.textContent = hostRecord.ports && hostRecord.ports.size > 0
                    ? formatInventoryPortList(hostRecord.ports)
                    : "";
                  serviceCell.textContent = serviceRecord.name;
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

              row.appendChild(serviceCell);
              row.appendChild(countCell);
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
              const normalizedHash = hash && hash.startsWith("#onlinehosts-") ? "#onlinehosts" : hash;
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

            const target = document.querySelector(hash);
            if (target) {
              scrollToReportTarget(target);
            }
          }

          function finalizeReportInitialization() {
            const overlay = document.getElementById("reportLoadingOverlay");

            window.requestAnimationFrame(() => {
              window.requestAnimationFrame(() => {
                document.body.classList.remove("report-initializing");
                if (overlay) {
                  overlay.classList.add("is-hidden");
                  overlay.setAttribute("aria-hidden", "true");
                }
                navigateToInitialHash();
              });
            });
          }

          function initializeHostToggle() {
            const toggle = document.getElementById("toggle-all-hosts");
            const hostList = document.getElementById("onlinehosts-list");
            if (!toggle || !hostList) return;

            const hostEntries = Array.from(hostList.querySelectorAll("details.host-entry"));
            if (hostEntries.length === 0) {
              toggle.hidden = true;
              return;
            }

            function syncLabel() {
              const allOpen = hostEntries.every(entry => entry.open);
              toggle.textContent = allOpen ? "Collapse all" : "Expand all";
              toggle.setAttribute("aria-expanded", allOpen ? "true" : "false");
            }

            toggle.addEventListener("click", () => {
              const shouldOpen = !hostEntries.every(entry => entry.open);
              hostEntries.forEach(entry => {
                entry.open = shouldOpen;
              });
              syncLabel();
            });

            hostEntries.forEach(entry => {
              entry.addEventListener("toggle", syncLabel);
            });

            syncLabel();
          }

          function getDataTableHeaderOffset() {
            const navbar = document.getElementById("mainNavbar");
            return navbar ? Math.ceil(navbar.getBoundingClientRect().height) : 0;
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
              "#web-services": "nmapview-web-tls-services",
              "#service-inventory": "nmapview-service-inventory"
            };
            const exportName = exportNames[selector] || "nmapview-table-export";
            const defaultOrders = {
              "#service-inventory": [[1, "desc"], [0, "asc"]]
            };
            const buttons = [
              {
                extend: 'colvis',
                text: 'Columns',
                className: 'btn btn-light'
              },
              {
                extend: 'copyHtml5',
                text: 'Copy',
                title: exportName,
                exportOptions: { columns: ':visible', orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'csvHtml5',
                text: 'CSV',
                filename: exportName,
                fieldSeparator: ';',
                exportOptions: { columns: ':visible', orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                extend: 'excelHtml5',
                text: 'Excel',
                filename: exportName,
                autoFilter: true,
                exportOptions: { columns: ':visible', orthogonal: 'export' },
                className: 'btn btn-light'
              },
              {
                text: 'JSON',
                className: 'btn btn-light',
                action: function (e, dt, node, config) {
                  const visibleColumns = dt.columns(':visible');
                  const headerIndexes = visibleColumns.indexes().toArray();
                  const headers = visibleColumns.header().toArray().map(h => $(h).text().trim());

                  const data = dt.rows({ search: 'applied' }).nodes().toArray().map(row => {
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
            ];

            if (selector === '#web-services') {
              buttons.push({
                extend: 'copyHtml5',
                text: 'Copy URLs',
                header: false,
                title: exportName,
                exportOptions: {  columns: [-1], orthogonal: 'export' },
                className: 'btn btn-light'
              });
            }

            if (selector === '#table-services') {
              buttons.push({
                text: 'Copy IP:Port',
                className: 'btn btn-light',
                action: async function (e, dt) {
                  const endpoints = [];

                  dt.rows({ search: 'applied' }).nodes().toArray().forEach(row => {
                    const cells = $(row).find('td');
                    const address = ($(cells.get(1)).text() || '').trim();
                    const port = ($(cells.get(2)).text() || '').trim();

                    if (address && port) {
                      endpoints.push(`${address}:${port}`);
                    }
                  });

                  const uniqueEndpoints = [...new Set(endpoints)];
                  await copyTextToClipboard(uniqueEndpoints.join('\n'));
                }
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
                "Count",
                "Host Count",
                "Uptime (est.)",
                "Hops",
                "Issues (est.)",
                "Rarity",
                "Open TCP Ports",
                "Open UDP Ports"
              ].forEach(headerName => {
                const columnIndex = headers.indexOf(headerName);
                if (columnIndex !== -1) {
                  columnDefs.push({ targets: [columnIndex], type: 'num' });
                }
              });

              if (selector === '#service-inventory') {
                const hostsColumnIndex = headers.indexOf("Hosts");
                if (hostsColumnIndex !== -1) {
                  columnDefs.push({ targets: [hostsColumnIndex], orderable: false });
                }
              }
            }

            const table = $(selector).DataTable({
              lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
              order: defaultOrders[selector] || [[0, 'desc']],
              columnDefs: columnDefs,
              dom: '<"d-flex justify-content-between align-items-center mb-2"lfB>rtip',
              stateSave: true,
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
            }

            if (selector === '#table-services' || selector === '#web-services') {
              initializeServiceDropdownFilter(table, tableElement, {
                tableLabel: selector === '#web-services' ? "Web/TLS Services" : "Open Services"
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

	        ]]></script>
        <script>
          window.addEventListener("load", finalizeReportInitialization, { once: true });
          $(document).ready(function() {
	              pinReportToSummaryView();
	              initializeNavbarToggle();
	              initializeSectionNav();
	              initializeHostToggle();
	              initializeKeywordHighlighter();
	              initializeCpeCopy();
	              initializeCertificateExpiryAlerts();
                formatVulnersChunks();
                buildServiceInventoryTable();
	              initializeDataTable('#table-services');
	              initializeDataTable('#table-overview');
	              initializeDataTable('#web-services');
	              initializeDataTable('#service-inventory');
                initializeHostUniquenessScores();
                initializeDensityToggle();


              $("a[href^='#onlinehosts-']").click(function(event) {
                  event.preventDefault();
                  const target = openLinkedHost(this.hash);
                  if (!target) {
                    return;
                  }
                  $('html,body').animate({
                      scrollTop: getReportScrollTop(target)
                  }, 500);
              });
          });
        </script>
  </xsl:template>
</xsl:stylesheet>
