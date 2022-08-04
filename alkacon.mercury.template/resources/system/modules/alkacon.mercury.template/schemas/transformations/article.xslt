<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:opencms="xalan://org.opencms.xml.content.CmsXsltContext"  
  exclude-result-prefixes="opencms" >
 
 <xsl:output indent="yes" encoding="UTF-8"/>
 <xsl:param name="context" />

<xsl:template match="/ArticleData/Article/Author">
    <Author>
        <Name>
            <xsl:value-of select="." />
        </Name>
    </Author>
</xsl:template>

 <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*" />
     </xsl:copy>
 </xsl:template>

</xsl:stylesheet>