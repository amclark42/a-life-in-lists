<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs tei"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <!-- GLOBAL VARIABLES -->
  
  <xsl:variable name="months">
    <key name="Jan.">01</key>
    <key name="Feb.">02</key>
    <key name="Mar.">03</key>
    <key name="Apr.">04</key>
    <key name="May">05</key>
    <key name="Jun.">06</key>
    <key name="Jul.">07</key>
    <key name="Aug.">08</key>
    <key name="Sept.">09</key>
    <key name="Oct.">10</key>
    <key name="Nov.">11</key>
    <key name="Dec.">12</key>
  </xsl:variable>
  
  <!-- FUNCTIONS -->
  
  <!-- TEMPLATES -->
  
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="text()"/>
  
  <xsl:template match="tei:TEI">
    <booklist>
      <xsl:apply-templates/>
    </booklist>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader//tei:titleStmt/tei:title">
    <title><xsl:value-of select="text()"/></title>
  </xsl:template>
  
  <xsl:template match="tei:body//tei:p[not(@rend eq 'center')]">
    <xsl:variable name="firstText" select="tokenize(text()[1],':')"/>
    <xsl:variable name="plainDates" 
      select="if ( matches($firstText[1],'[–\-]') ) then 
      tokenize($firstText[1],' [–\-] ')
                else $firstText[1]"/>
    <xsl:variable name="from">
      <xsl:call-template name="dateFormatter">
        <xsl:with-param name="textDate" select="$plainDates[1]"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="to">
      <xsl:if test="$plainDates[2]">
        <xsl:call-template name="dateFormatter">
          <xsl:with-param name="textDate" select="$plainDates[2]"/>
          <xsl:with-param name="guessMonth"
            select="substring-before($plainDates[1],' ')"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <book>
      <title><xsl:value-of select="normalize-space(tei:hi[@rend eq 'underline'][1])"/></title>
      <xsl:call-template name="getContributors">
        <xsl:with-param name="textContribs" select="$firstText[2]"></xsl:with-param>
      </xsl:call-template>
      <event>
        <xsl:choose>
          <xsl:when test="$to ne ''">
            <xsl:attribute name="from" select="$from"/>
            <xsl:attribute name="to" select="$to"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="when" select="$from"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="tei:hi[@rend eq 'italic']">
            <xsl:for-each select="tei:hi[@rend eq 'italic']">
              <xsl:value-of select="normalize-space(.)"/>
              <xsl:text>.</xsl:text>
              <xsl:if test="position() ne last()">
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>Read.</xsl:otherwise>
        </xsl:choose>
      </event>
      <xsl:if test="text()[contains(.,'*')]">
        <tag>comics</tag>
      </xsl:if>
    </book>
  </xsl:template>
  
  <xsl:template name="getContributors">
    <xsl:param name="textContribs" as="xs:string"/>
    <xsl:variable name="normContribs" select="normalize-space($textContribs)"/>
    <xsl:variable name="firstContrib" 
      select="replace($normContribs,'^ ?([a-zA-Z\- ]+, [a-zA-Z\- ]+)(\.|, | and ).*','$1')"/>
    <xsl:variable name="otherContribs"
      select="substring-after($normContribs,$firstContrib)"/>
    <xsl:variable name="otherTokens" 
      select="tokenize($otherContribs,', ')"/>
    <contributor>
      <relation type="Author"/>
      <name type="forename">
        <xsl:value-of select="substring-after($firstContrib,', ')"/>
      </name>
      <name type="surname">
        <xsl:value-of select="substring-before($firstContrib,', ')"/>
      </name>
    </contributor>
    <xsl:for-each select="$otherTokens[not(matches(.,'^\W+$'))]">
      <contributor>
        <name>
          <xsl:value-of select="."/>
        </name>
      </contributor>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="dateFormatter">
    <xsl:param name="textDate" as="xs:string"/>
    <xsl:param name="guessMonth" as="xs:string" select="substring-before($textDate,' ')"/>
    <xsl:variable name="guessYear" select="preceding-sibling::tei:p[@rend eq 'center'][1]"/>
    <xsl:variable name="tokenDate" select="tokenize($textDate,',? ')"/>
    <xsl:variable name="txtMonth">
      <xsl:choose>
        <xsl:when test="count($tokenDate) = 1">
          <xsl:value-of select="$guessMonth"/>
        </xsl:when>
        <xsl:when test="count($tokenDate) ge 2">
          <xsl:value-of select="$tokenDate[1]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="txtDay">
      <xsl:choose>
        <xsl:when test="count($tokenDate) = 1">
          <xsl:value-of select="xs:integer($tokenDate)"/>
        </xsl:when>
        <xsl:when test="count($tokenDate) ge 2">
          <xsl:value-of select="xs:integer($tokenDate[2])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="w3cMonth" select="$months//key[@name eq $txtMonth]"/>
    <xsl:value-of select="if (count($tokenDate) = 3) then $tokenDate[3]
                          else $guessYear"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$w3cMonth"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="format-number($txtDay,'00')"/>
  </xsl:template>
  
</xsl:stylesheet>