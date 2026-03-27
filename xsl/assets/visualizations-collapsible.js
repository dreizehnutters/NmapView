document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll("details.visualization-card-collapsible").forEach(detailsElement => {
    detailsElement.addEventListener("toggle", function() {
      if (!detailsElement.open) {
        return;
      }

      window.requestAnimationFrame(() => refreshCollapsibleVisualization(detailsElement));
      window.setTimeout(() => refreshCollapsibleVisualization(detailsElement), 140);
    });

    if (detailsElement.open) {
      window.requestAnimationFrame(() => refreshCollapsibleVisualization(detailsElement));
    }
  });
});
