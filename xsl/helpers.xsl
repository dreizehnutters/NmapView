<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:key name="serviceGroup" match="host/ports/port[state/@state='open' and service/@name]" use="concat(            substring('ssl/', 1, (service/@tunnel = 'ssl') * string-length('ssl/')),            service/@name,            '-',            @protocol          )"/>
  <xsl:key name="uniquePorts" match="port[state/@state='open']" use="@portid"/>
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>

  <xsl:template name="render-hostname-or-na">
    <xsl:param name="hostname"/>
    <xsl:choose>
      <xsl:when test="string(normalize-space($hostname)) != ''">
        <xsl:value-of select="normalize-space($hostname)"/>
      </xsl:when>
      <xsl:otherwise>N/A</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extract-first-dns-name">
    <xsl:param name="text"/>
    <xsl:variable name="normalized-text" select="normalize-space($text)"/>
    <xsl:choose>
      <xsl:when test="contains($normalized-text, 'DNS:')">
        <xsl:variable name="after-dns" select="substring-after($normalized-text, 'DNS:')"/>
        <xsl:variable name="candidate-raw">
          <xsl:choose>
            <xsl:when test="contains($after-dns, ',')">
              <xsl:value-of select="substring-before($after-dns, ',')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$after-dns"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="candidate" select="normalize-space($candidate-raw)"/>
        <xsl:variable name="remaining">
          <xsl:choose>
            <xsl:when test="contains($after-dns, ',')">
              <xsl:value-of select="substring-after($after-dns, ',')"/>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string($candidate) != '' and $candidate != 'localhost' and string(translate($candidate, '0123456789.:-[]', '')) != ''">
            <xsl:value-of select="$candidate"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="extract-first-dns-name">
              <xsl:with-param name="text" select="$remaining"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extract-url-host">
    <xsl:param name="url"/>
    <xsl:variable name="normalized-url" select="normalize-space($url)"/>
    <xsl:variable name="without-scheme">
      <xsl:choose>
        <xsl:when test="contains($normalized-url, '://')">
          <xsl:value-of select="substring-after($normalized-url, '://')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$normalized-url"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="without-path">
      <xsl:choose>
        <xsl:when test="contains($without-scheme, '/')">
          <xsl:value-of select="substring-before($without-scheme, '/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$without-scheme"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="without-query">
      <xsl:choose>
        <xsl:when test="contains($without-path, '?')">
          <xsl:value-of select="substring-before($without-path, '?')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$without-path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="without-fragment">
      <xsl:choose>
        <xsl:when test="contains($without-query, '#')">
          <xsl:value-of select="substring-before($without-query, '#')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$without-query"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="host-only">
      <xsl:choose>
        <xsl:when test="starts-with($without-fragment, '[') and contains($without-fragment, ']')">
          <xsl:value-of select="substring-before(substring-after($without-fragment, '['), ']')"/>
        </xsl:when>
        <xsl:when test="contains($without-fragment, ':')">
          <xsl:value-of select="substring-before($without-fragment, ':')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$without-fragment"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="candidate" select="normalize-space($host-only)"/>
    <xsl:if test="string($candidate) != '' and $candidate != 'localhost' and string(translate($candidate, '0123456789.:-[]', '')) != ''">
      <xsl:value-of select="$candidate"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="resolve-inferred-hostname">
    <xsl:variable name="cert-san" select="ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script/table[@key='extensions']/table[elem[@key='name']='X509v3 Subject Alternative Name'][1]/elem[@key='value']"/>
    <xsl:variable name="cert-san-output">
      <xsl:choose>
        <xsl:when test="string($cert-san) != ''">
          <xsl:value-of select="$cert-san"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before(substring-after(ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script[@id='ssl-cert']/@output, 'Subject Alternative Name:'), '&#xA;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cert-dns">
      <xsl:call-template name="extract-first-dns-name">
        <xsl:with-param name="text" select="$cert-san-output"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="cert-cn" select="normalize-space(ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script/table[@key='subject']/elem[@key='commonName'])"/>
    <xsl:variable name="cert-cn-output" select="normalize-space(substring-before(substring-after(ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script[@id='ssl-cert']/@output, 'Subject: commonName='), '/'))"/>
    <xsl:variable name="location-url">
      <xsl:choose>
        <xsl:when test="string(ancestor-or-self::host[1]/ports/port[script[@id='http-title']/elem[@key='redirect_url']][1]/script[@id='http-title']/elem[@key='redirect_url']) != ''">
          <xsl:value-of select="ancestor-or-self::host[1]/ports/port[script[@id='http-title']/elem[@key='redirect_url']][1]/script[@id='http-title']/elem[@key='redirect_url']"/>
        </xsl:when>
        <xsl:when test="contains(ancestor-or-self::host[1]/ports/port[script[@id='http-headers']][1]/script[@id='http-headers']/@output, 'Location:')">
          <xsl:call-template name="extract-header-value">
            <xsl:with-param name="text" select="ancestor-or-self::host[1]/ports/port[script[@id='http-headers']][1]/script[@id='http-headers']/@output"/>
            <xsl:with-param name="label" select="'Location'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains(ancestor-or-self::host[1]/ports/port[script[@id='http-headers']][1]/script[@id='http-headers']/@output, 'location:')">
          <xsl:call-template name="extract-header-value">
            <xsl:with-param name="text" select="ancestor-or-self::host[1]/ports/port[script[@id='http-headers']][1]/script[@id='http-headers']/@output"/>
            <xsl:with-param name="label" select="'location'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains(ancestor-or-self::host[1]/ports/port[script[@id='fingerprint-strings']][1]/script[@id='fingerprint-strings']/elem[@key='GetRequest'], 'Location:')">
          <xsl:call-template name="extract-header-value">
            <xsl:with-param name="text" select="ancestor-or-self::host[1]/ports/port[script[@id='fingerprint-strings']][1]/script[@id='fingerprint-strings']/elem[@key='GetRequest']"/>
            <xsl:with-param name="label" select="'Location'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains(ancestor-or-self::host[1]/ports/port[script[@id='fingerprint-strings']][1]/script[@id='fingerprint-strings']/elem[@key='GetRequest'], 'location:')">
          <xsl:call-template name="extract-header-value">
            <xsl:with-param name="text" select="ancestor-or-self::host[1]/ports/port[script[@id='fingerprint-strings']][1]/script[@id='fingerprint-strings']/elem[@key='GetRequest']"/>
            <xsl:with-param name="label" select="'location'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="location-host">
      <xsl:call-template name="extract-url-host">
        <xsl:with-param name="url" select="$location-url"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string($cert-dns) != ''">
        <xsl:value-of select="$cert-dns"/>
      </xsl:when>
      <xsl:when test="string($cert-cn) != '' and $cert-cn != 'localhost' and string(translate($cert-cn, '0123456789.:-[]', '')) != ''">
        <xsl:value-of select="$cert-cn"/>
      </xsl:when>
      <xsl:when test="string($cert-cn-output) != '' and $cert-cn-output != 'localhost' and string(translate($cert-cn-output, '0123456789.:-[]', '')) != ''">
        <xsl:value-of select="$cert-cn-output"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$location-host"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-inferred-hostname-source">
    <xsl:variable name="cert-san" select="ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script/table[@key='extensions']/table[elem[@key='name']='X509v3 Subject Alternative Name'][1]/elem[@key='value']"/>
    <xsl:variable name="cert-san-output">
      <xsl:choose>
        <xsl:when test="string($cert-san) != ''">
          <xsl:value-of select="$cert-san"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before(substring-after(ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script[@id='ssl-cert']/@output, 'Subject Alternative Name:'), '&#xA;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cert-dns">
      <xsl:call-template name="extract-first-dns-name">
        <xsl:with-param name="text" select="$cert-san-output"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="cert-cn" select="normalize-space(ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script/table[@key='subject']/elem[@key='commonName'])"/>
    <xsl:variable name="cert-cn-output" select="normalize-space(substring-before(substring-after(ancestor-or-self::host[1]/ports/port[script[@id='ssl-cert']][1]/script[@id='ssl-cert']/@output, 'Subject: commonName='), '/'))"/>
    <xsl:variable name="location-url">
      <xsl:choose>
        <xsl:when test="string(ancestor-or-self::host[1]/ports/port[script[@id='http-title']/elem[@key='redirect_url']][1]/script[@id='http-title']/elem[@key='redirect_url']) != ''">
          <xsl:value-of select="ancestor-or-self::host[1]/ports/port[script[@id='http-title']/elem[@key='redirect_url']][1]/script[@id='http-title']/elem[@key='redirect_url']"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string($cert-dns) != '' or (string($cert-cn) != '' and $cert-cn != 'localhost' and string(translate($cert-cn, '0123456789.:-[]', '')) != '') or (string($cert-cn-output) != '' and $cert-cn-output != 'localhost' and string(translate($cert-cn-output, '0123456789.:-[]', '')) != '')">
        <xsl:text>inferred-cert</xsl:text>
      </xsl:when>
      <xsl:when test="string($location-url) != ''">
        <xsl:text>inferred-location</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-effective-hostname">
    <xsl:choose>
      <xsl:when test="string(normalize-space(ancestor-or-self::host[1]/hostnames/hostname[1]/@name)) != ''">
        <xsl:value-of select="normalize-space(ancestor-or-self::host[1]/hostnames/hostname[1]/@name)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="resolve-inferred-hostname"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="resolve-effective-hostname-source">
    <xsl:choose>
      <xsl:when test="string(normalize-space(ancestor-or-self::host[1]/hostnames/hostname[1]/@name)) != ''">
        <xsl:value-of select="normalize-space(ancestor-or-self::host[1]/hostnames/hostname[1]/@type)"/>
      </xsl:when>
      <xsl:when test="string(normalize-space(ancestor-or-self::host[1]/hostnames/hostname[1]/@name)) = '' and string(normalize-space(ancestor-or-self::host[1])) != ''">
        <xsl:call-template name="resolve-inferred-hostname-source"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extract-last-token">
    <xsl:param name="text"/>
    <xsl:variable name="normalized-text" select="normalize-space($text)"/>
    <xsl:choose>
      <xsl:when test="contains($normalized-text, ' ')">
        <xsl:call-template name="extract-last-token">
          <xsl:with-param name="text" select="substring-after($normalized-text, ' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$normalized-text"/>
      </xsl:otherwise>
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
    <a class="cpe-copy" title="Click to copy CPE">
      <xsl:attribute name="href">
        <xsl:text>https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=</xsl:text>
        <xsl:value-of select="$cpe"/>
      </xsl:attribute>
      <xsl:attribute name="data-cpe">
        <xsl:value-of select="$cpe"/>
      </xsl:attribute>
      <xsl:value-of select="$cpe"/>
    </a>
  </xsl:template>

  <xsl:template name="render-cpe-text">
    <xsl:param name="cpe"/>
    <span class="cpe-copy" title="Click to copy CPE">
      <xsl:attribute name="data-cpe">
        <xsl:value-of select="$cpe"/>
      </xsl:attribute>
      <xsl:value-of select="$cpe"/>
    </span>
  </xsl:template>

  <xsl:template name="render-certificate-row">
    <xsl:param name="label"/>
    <xsl:param name="primary"/>
    <xsl:param name="secondary" select="''"/>
    <xsl:param name="row-class" select="''"/>
    <xsl:param name="value-class" select="''"/>
    <xsl:if test="string($primary) != '' or string($secondary) != ''">
      <div>
        <xsl:attribute name="class">
          <xsl:text>certificate-row</xsl:text>
          <xsl:if test="string($row-class) != ''">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$row-class"/>
          </xsl:if>
        </xsl:attribute>
        <span class="certificate-label">
          <xsl:value-of select="$label"/>
          <xsl:text>: </xsl:text>
        </span>
        <i>
          <xsl:attribute name="class">
            <xsl:text>certificate-value</xsl:text>
            <xsl:if test="string($value-class) != ''">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$value-class"/>
            </xsl:if>
          </xsl:attribute>
          <xsl:value-of select="$primary"/>
          <xsl:if test="string($secondary) != ''">
            <xsl:text> – </xsl:text>
            <xsl:value-of select="$secondary"/>
          </xsl:if>
        </i>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="extract-header-value">
    <xsl:param name="text"/>
    <xsl:param name="label"/>
    <xsl:variable name="needle" select="concat($label, ':')"/>
    <xsl:choose>
      <xsl:when test="contains($text, $needle)">
        <xsl:value-of select="normalize-space(substring-before(substring-after($text, $needle), '&#xA;'))"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extract-powered-by-value">
    <xsl:param name="text"/>
    <xsl:variable name="lower-text" select="translate($text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    <xsl:variable name="needle" select="'powered-by:'"/>
    <xsl:choose>
      <xsl:when test="contains($lower-text, $needle)">
        <xsl:variable name="prefix-length" select="string-length(substring-before($lower-text, $needle))"/>
        <xsl:variable name="value-start" select="$prefix-length + string-length($needle) + 1"/>
        <xsl:value-of select="normalize-space(substring-before(concat(substring($text, $value-start), '&#xA;'), '&#xA;'))"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extract-stack-hint-line">
    <xsl:param name="text"/>
    <xsl:if test="string($text) != ''">
      <xsl:variable name="line" select="normalize-space(substring-before(concat($text, '&#xA;'), '&#xA;'))"/>
      <xsl:variable name="rest" select="substring-after($text, '&#xA;')"/>
      <xsl:variable name="lower-line" select="translate($line, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:choose>
        <xsl:when test="contains($lower-line, 'powered') or contains($lower-line, 'php') or contains($lower-line, 'asp')">
          <xsl:value-of select="$line"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="extract-stack-hint-line">
            <xsl:with-param name="text" select="$rest"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="normalize-powered-by-stack">
    <xsl:param name="value"/>
    <xsl:variable name="lower-value" select="translate(normalize-space($value), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    <xsl:variable name="has-php" select="contains($lower-value, 'php/') or contains($lower-value, 'php')"/>
    <xsl:variable name="php-version">
      <xsl:choose>
        <xsl:when test="contains($lower-value, 'php/')">
          <xsl:variable name="prefix-length" select="string-length(substring-before($lower-value, 'php/'))"/>
          <xsl:variable name="value-start" select="$prefix-length + 5"/>
          <xsl:variable name="php-rest" select="substring(normalize-space($value), $value-start)"/>
          <xsl:value-of select="normalize-space(substring-before(concat(translate($php-rest, ',;()[]', '      '), ' '), ' '))"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="has-aspnet" select="contains($lower-value, 'asp.net core') or contains($lower-value, 'asp.net') or contains($lower-value, 'aspnet') or contains($lower-value, 'asp')"/>
    <xsl:if test="$has-php">
      <xsl:text>PHP</xsl:text>
      <xsl:if test="string($php-version) != ''">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$php-version"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$has-aspnet">
      <xsl:if test="$has-php">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="contains($lower-value, 'asp.net core') or contains($lower-value, 'aspnetcore')">
          <xsl:text>ASP.NET Core</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>ASP.NET</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-http-row">
    <xsl:param name="label"/>
    <xsl:param name="value"/>
    <xsl:if test="string($value) != ''">
      <div class="certificate-row">
        <span class="certificate-label">
          <xsl:value-of select="$label"/>
          <xsl:text>: </xsl:text>
        </span>
        <i class="certificate-value">
          <xsl:value-of select="$value"/>
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
