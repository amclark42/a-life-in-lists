<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs xsl"
  version="2.0">
  
  <xsl:output indent="yes" exclude-result-prefixes="tei"/>
  
  <xsl:template match="/">
    <tei:TEI>
      <tei:teiHeader>
        
      </tei:teiHeader>
      <tei:text>
        <tei:body>
          <tei:list>
            <xsl:apply-templates select="//tei:p"/>
          </tei:list>
        </tei:body>
      </tei:text>
    </tei:TEI>
  </xsl:template>
  
  <xsl:template match="text()[not(ancestor::tei:p)]"/>
  
  <xsl:template match="tei:p"/>
  <xsl:template match="tei:p//*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:p[contains(normalize-space(.),'~')]">
    <xsl:variable name="countPreceding" select="count(preceding-sibling::tei:p)"/>
    <xsl:variable name="seqStartIndex" select="if ( $countPreceding le 10 ) then 0 else $countPreceding - 10"/>
    <xsl:variable name="allPreceding" select="subsequence(preceding-sibling::tei:p,$seqStartIndex,11)"/>
    <xsl:variable name="previousQuote" select="$allPreceding[descendant::text()[contains(.,'~')]][last()]"/>
    <!--<xsl:variable name="previousQuote" select="$allPreceding[descendant::text()[contains(.,'~')]][last()-1]"/>-->
    <xsl:variable name="quoteDelimiter" 
      select="if ( $previousQuote ) then 
                index-of($allPreceding,$previousQuote)
              else 1"/>
    <xsl:variable name="startLoc" select="if ( count($quoteDelimiter) = 1 ) then 
                                            if ( $quoteDelimiter ne 1 ) then
                                              $quoteDelimiter +1
                                            else $quoteDelimiter
                                          else max($quoteDelimiter)+1"/>
    <xsl:variable name="content" 
      select="subsequence($allPreceding,$startLoc)"/>
    
    <tei:item>
      <!--<xsl:value-of select="$startLoc"/>-->
      <tei:quote><xsl:copy-of select="$content"/></tei:quote>
      <tei:bibl><xsl:apply-templates/></tei:bibl>
    </tei:item>
  </xsl:template>
  
</xsl:stylesheet>