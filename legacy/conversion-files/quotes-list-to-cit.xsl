<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei xs"
  version="2.0">
  
<!--
    Change `//list/item[quote]`s into <cit>s.
    
    Ashley M. Clark
    2019-09-29
  -->
  
  <xsl:output encoding="UTF-8" indent="no" method="xml" 
     omit-xml-declaration="no"/>
  
  
 <!--  IDENTITY TEMPLATES  -->
  
  <xsl:template match="*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | text() | comment() | processing-instruction()" mode="#all">
    <xsl:copy/>
  </xsl:template>
  
  
 <!--  TEMPLATES, #default mode  -->
  
  <!-- Put each leading processing instruction on its own line. -->
  <xsl:template match="/processing-instruction()">
    <xsl:if test="position() = 1">
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
    <xsl:copy/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="body/list">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="body/list/item[quote]">
    <cit>
      <xsl:apply-templates/>
    </cit>
  </xsl:template>
  
</xsl:stylesheet>