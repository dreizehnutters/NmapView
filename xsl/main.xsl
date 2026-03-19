<?xml version="1.0" encoding="utf-8"?>
<!--
Nmap Bootstrap XSL
This software must not be used by military or secret service organisations.
Andreas Hontzia (@honze_net) & LRVT (@l4rm4nd) & Fabian Kopp (@dreizehnutters)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="helpers.xsl"/>
  <xsl:include href="layout.xsl"/>
  <xsl:include href="hosts.xsl"/>
  <xsl:include href="services.xsl"/>
  <xsl:include href="inventory.xsl"/>
  <xsl:include href="web.xsl"/>

  <xsl:template match="/">
    <html lang="en">
      <xsl:call-template name="render-head"/>
      <body>
        <xsl:call-template name="render-navbar"/>
        <div id="reportContent" class="container-fluid px-4" style="min-width: fit-content;">
          <xsl:call-template name="render-summary"/>
          <xsl:call-template name="render-scanned-hosts"/>
          <xsl:call-template name="render-open-services"/>
          <xsl:call-template name="render-service-inventory"/>
          <xsl:call-template name="render-web-services"/>
          <xsl:call-template name="render-visualizations"/>
          <xsl:call-template name="render-online-hosts"/>
        </div>
        <xsl:call-template name="render-footer"/>
        <xsl:call-template name="render-scripts"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
