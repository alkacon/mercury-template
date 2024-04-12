<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:opencms="xalan://org.opencms.xml.content.CmsXsltContext"
    exclude-result-prefixes="opencms" >

<xsl:output indent="yes" encoding="UTF-8"/>

<xsl:template match="/PoiData/Poi/TeaserData">
    <xsl:choose>
        <xsl:when test="not(/PoiData/@version)">
            <LinkedContentData>
                <xsl:copy-of select="*" />
            </LinkedContentData>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="." />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="node()|@*">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
