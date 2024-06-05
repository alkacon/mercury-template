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
    description="The cms context to use when writing. If not provided use the cms contecxt from the content object." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%
    try {
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
    } catch (Exception e) {
        // ignore exception, the content is probably not written
        getJspContext().setAttribute("writeException", e);
    }
%>

<c:if test="${cms.isEditMode and (not empty writeException)}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <c:set var="errorMsg">
            <fmt:message key="msg.error.filewrite.text">
                <fmt:param>${content.resource.rootPath}</fmt:param>
                <fmt:param>${xpath}</fmt:param>
                <fmt:param>${writeException}</fmt:param>
            </fmt:message>
        </c:set>
        <m:alert type="error">
            <jsp:attribute name="head">
                <fmt:message key="msg.error.filewrite.head" />
            </jsp:attribute>
            <jsp:attribute name="text">
                <c:out value="${errorMsg}" escapeXml="false" />
            </jsp:attribute>
        </m:alert>
    </cms:bundle>
</c:if>
