<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:key name="serviceGroup" match="host/ports/port[state/@state='open' and service/@name]" use="concat(            substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),            service/@name,            '-',            @protocol          )"/>
  <xsl:key name="uniquePorts" match="port[state/@state='open']" use="@portid"/>
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>

  <xsl:template name="render-hostname-or-na">
    <xsl:param name="hostname"/>
    <xsl:choose>
      <xsl:when test="string($hostname) != ''">
        <xsl:value-of select="$hostname"/>
      </xsl:when>
      <xsl:otherwise>N/A</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-onlinehosts-link">
    <xsl:param name="address"/>
    <a>
      <xsl:attribute name="href">
        <xsl:text>#onlinehosts-</xsl:text>
        <xsl:value-of select="translate($address, '.:', '--')"/>
      </xsl:attribute>
      <xsl:value-of select="$address"/>
    </a>
  </xsl:template>

  <xsl:template name="render-service-name">
    <xsl:choose>
      <xsl:when test="script[@id='ssl-cert']">
        <xsl:text>ssl/</xsl:text>
        <xsl:choose>
          <xsl:when test="number(service/@conf) &gt; 5">
            <xsl:value-of select="service/@name"/>
          </xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="number(service/@conf) &gt; 5">
            <xsl:value-of select="service/@name"/>
          </xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-external-link">
    <xsl:param name="href"/>
    <xsl:param name="text"/>
    <a target="_blank" rel="noopener noreferrer">
      <xsl:attribute name="href">
        <xsl:value-of select="$href"/>
      </xsl:attribute>
      <xsl:value-of select="$text"/>
    </a>
  </xsl:template>

  <xsl:template name="render-nvd-cpe-link">
    <xsl:param name="cpe"/>
    <a>
      <xsl:attribute name="href">
        <xsl:text>https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=</xsl:text>
        <xsl:value-of select="$cpe"/>
      </xsl:attribute>
      <xsl:value-of select="$cpe"/>
    </a>
  </xsl:template>

  <xsl:template name="render-cpe-text">
    <xsl:param name="cpe"/>
    <xsl:value-of select="$cpe"/>
  </xsl:template>

  <xsl:template name="render-certificate-row">
    <xsl:param name="label"/>
    <xsl:param name="primary"/>
    <xsl:param name="secondary" select="''"/>
    <xsl:if test="string($primary) != '' or string($secondary) != ''">
      <div class="certificate-row">
        <span class="certificate-label">
          <xsl:value-of select="$label"/>
          <xsl:text>: </xsl:text>
        </span>
        <i class="certificate-value">
          <xsl:value-of select="$primary"/>
          <xsl:if test="string($secondary) != ''">
            <xsl:text> – </xsl:text>
            <xsl:value-of select="$secondary"/>
          </xsl:if>
        </i>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-service-url">
    <xsl:param name="scheme"/>
    <xsl:param name="host"/>
    <xsl:param name="port"/>
    <xsl:call-template name="render-external-link">
      <xsl:with-param name="href" select="concat($scheme, '://', $host, ':', $port)"/>
      <xsl:with-param name="text" select="concat($scheme, '://', $host, ':', $port)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-host-header-label">
    <xsl:param name="address"/>
    <xsl:param name="mac" select="''"/>
    <xsl:param name="vendor" select="''"/>
    <xsl:param name="hostname" select="''"/>
    <xsl:value-of select="$address"/>
    <xsl:if test="string($mac) != ''">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$mac"/>
      <xsl:if test="string($vendor) != ''">
        <xsl:text> - </xsl:text>
        <xsl:value-of select="$vendor"/>
      </xsl:if>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:if test="string($hostname) != ''">
      <xsl:text> - </xsl:text>
      <xsl:value-of select="$hostname"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-script-output-list">
    <xsl:if test="count(script) &gt; 0">
      <ul class="list-unstyled mb-0">
        <xsl:for-each select="script">
          <li>
            <strong>
              <xsl:value-of select="@id"/>
            </strong>
            <pre class="bg-light p-2 rounded">
              <xsl:value-of select="@output"/>
            </pre>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-empty-state">
    <xsl:param name="message"/>
    <p class="text-muted fst-italic mb-3">
      <xsl:value-of select="$message"/>
    </p>
  </xsl:template>
</xsl:stylesheet>
