<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:opencms="xalan://org.opencms.xml.content.CmsXsltContext"  
  exclude-result-prefixes="opencms" >
 
 <xsl:output indent="yes" encoding="UTF-8"/>
 <xsl:param name="context" />

<xsl:template match="/FlexibleData/Flexible/Code">
    <xsl:copy-of select="opencms:convertType($context, ., 'OpenCmsHtml', 'OpenCmsString', 'Code')" />
</xsl:template>

 <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*" />
     </xsl:copy>
 </xsl:template>

</xsl:stylesheet>