<%@tag pageEncoding="UTF-8"
    display-name="write-content"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Write a - usually modified - XML content to the VFS."
    import="org.opencms.jsp.util.*, org.opencms.file.*, org.opencms.xml.content.*, org.opencms.xml.content.*, org.opencms.xml.types.*"
    %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content to write." %>

<%@ attribute name="xpath" type="java.lang.String" required="true"
    description="The xpath to write the value to." %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The value to set in the content." %>

<%@ attribute name="cms" type="org.opencms.file.CmsObject"  required="false"
    description="The cms context to use when writing." %>

<%
    CmsJspContentAccessBean content = (CmsJspContentAccessBean)getJspContext().getAttribute("content");
    CmsObject cms = (CmsObject)getJspContext().getAttribute("cms");
    cms = (cms == null) ? content.getCmsObject() : cms;
    java.util.Locale locale = content.getLocale();

    CmsXmlContent rawXmlContent = (CmsXmlContent)content.getRawContent();
    I_CmsXmlContentValue xmlValue = rawXmlContent.getValue(xpath, locale, 0);
    if (xmlValue == null) {
        xmlValue = rawXmlContent.addValue(cms, xpath + "[1]", locale, 0);
    }
    xmlValue.setStringValue(cms, value);

    CmsFile file = content.getFile();
    file.setContents(rawXmlContent.marshal());

    cms.lockResource(file);
    cms.writeFile(file);
    cms.unlockResource(file);
%>