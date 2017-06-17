<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output indent="yes" exclude-result-prefixes="tei"/>
    
    <xsl:template match="/TEI">
        <xsl:processing-instruction name="xml-model">
            <xsl:attribute name="href" select="'file:/media/removable/SD%20Card/perspectography/schema/perspectography.rng'"/>
            <xsl:attribute name="type" select="'application/xml'"/>
            <xsl:attribute name="schematypens" select="'http://relaxng.org/ns/structure/1.0'"/>
        </xsl:processing-instruction>
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>My First Books Read</title>
                        <title type="sub">List of Bibliographic Entries</title>
                        <editor><persName>Ashley M. Clark</persName></editor>
                    </titleStmt>
                    <publicationStmt>
                        <p>Just me, Ashley.</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Generated from the Microsoft Word Document
                            <title type="filename">
                                <xsl:value-of select="tokenize(base-uri(.),'/')[last()]"/>
                            </title>.
                        </p>
                    </sourceDesc>
                </fileDesc>
                <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                    <xsl:attribute name="href" select="'boilerplate/encodingDesc.xml'"/>
                </xsl:element>
                <revisionDesc>
                    <listChange>
                        <change when="{current-dateTime()}">Created this TEI version of the list 
                            using <title type="filename">firstBooks2bibl.xsl</title>.</change>
                        <xsl:apply-templates select="teiHeader/revisionDesc/listChange/change, 
                            teiHeader/fileDesc/editionStmt"/>
                    </listChange>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <listBibl>
                        <xsl:apply-templates select="text/body/*"/>
                    </listBibl>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="teiHeader/fileDesc/editionStmt">
        <change when="{normalize-space(edition/date)}">Created first version of this list in Microsoft Word.</change>
    </xsl:template>
    
    <xsl:template match="teiHeader/revisionDesc/listChange/change">
        <change when="{normalize-space(date)}">Last known revision of the Word document.</change>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="body/head">
        <head>
            <xsl:choose>
                <xsl:when test="position() eq 1">
                    <xsl:attribute name="rend" select="'smallcaps'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type" select="'sub'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    
    <xsl:template match="body/p">
        <bibl>
            <xsl:call-template name="get-author"/>
            <xsl:apply-templates/>
        </bibl>
    </xsl:template>
    
    <xsl:template match="p/text()[1]"/>
    
    <xsl:template match="p/text()[preceding-sibling::text()]">
        <xsl:choose>
            <xsl:when test="contains(.,'*')">
                <trait ref="#tag.comics"/>
                <xsl:value-of select="replace(.,'\*','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="p/hi[1]">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
    <xsl:template match="p/hi[preceding-sibling::hi]">
        <note>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    
    <xsl:template name="get-author">
        <xsl:variable name="firstText" select="text()[1]/normalize-space(.)"/>
        <author>
            <persName>
                <xsl:choose>
                    <xsl:when test="contains($firstText,'---')">
                        <xsl:variable name="lastAuthor" select="preceding-sibling::p[not(contains(normalize-space(.),'---'))][1]
                                                                /text()[1]/normalize-space(.)"/>
                        <xsl:value-of select="$lastAuthor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace($firstText,'---','')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </persName>
            <xsl:value-of select="substring-after($firstText,'---')"/>
        </author>
        <xsl:text> </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>