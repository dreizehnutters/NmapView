          window.addEventListener("load", finalizeReportInitialization, { once: true });
          $(document).ready(function() {
	              pinReportToSummaryView();
	              initializeNavbarToggle();
	              initializeSectionNav();
	              initializeKeywordHighlighter();
	              initializeCpeCopy();
	              initializeCertificateExpiryAlerts();
                formatVulnersChunks();
                buildServiceInventoryTable();
                initializeServiceInventoryNestedTables();
	              initializeHostToggle();
	              initializeDataTable('#table-services');
	              initializeDataTable('#table-overview');
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
