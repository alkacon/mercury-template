<%@ tag pageEncoding="UTF-8"
    display-name="set-content-disposition"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Translates a (file) name according to the configured file name translation rules.
    The result will also be all lower case." %>


<%@ attribute name="name" type="java.lang.String" required="true"
    description="The name to translate according to the configured OpenCms filename transltation rules."%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String result = "";
    String name = (String)getJspContext().getAttribute("name");
    if (name.length() > 0) {
        result = org.opencms.main.OpenCms.getResourceManager().getFileTranslator().translateResource(name).toLowerCase();
    }
    getJspContext().setAttribute("translatedName", result);
%>

<c:out value="${translatedName}" escapeXml="false" />
