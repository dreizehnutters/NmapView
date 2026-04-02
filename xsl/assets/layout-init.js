          window.addEventListener("load", finalizeReportInitialization, { once: true });
          $(document).ready(function() {
	              pinReportToSummaryView();
	              initializeNavbarToggle();
	              initializeSectionNav();
	              initializeAboutDialog();
	              initializeKeywordHighlighter();
	              initializeCpeCopy();
	              initializeCertificateExpiryAlerts();
                formatVulnersChunks();
                buildServiceInventoryTable();
                initializeServiceInventoryToggle();
                initializeServiceInventoryNestedTables();
	              initializeHostToggle();
	              initializeDataTable('#table-services');
	              initializeDataTable('#table-overview');
	              initializeDataTable('#service-inventory');
                initializeSlashSearchShortcut();
                initializeHostUniquenessScores();
                initializeDensityToggle();


              $("a[href^='#onlinehosts-']").click(function(event) {
                  event.preventDefault();
                  const target = openLinkedHost(this.hash);
                  if (!target) {
                    return;
                  }
                  if (window.history && window.history.pushState) {
                    window.history.pushState(null, "", this.hash);
                  }
                  $('html,body').animate({
                      scrollTop: getReportScrollTop(target)
                  }, 500);
              });

              $(document).on("click", "a[href^='#servicevariant-']", function(event) {
                  event.preventDefault();
                  const target = openLinkedServiceVariant(this.hash);
                  if (!target) {
                    return;
                  }
                  if (window.history && window.history.pushState) {
                    window.history.pushState(null, "", this.hash);
                  }
                  $('html,body').animate({
                      scrollTop: getReportScrollTop(target)
                  }, 500);
              });
          });
