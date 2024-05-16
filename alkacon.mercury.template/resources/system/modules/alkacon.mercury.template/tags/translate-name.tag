<%@ tag pageEncoding="UTF-8"
    display-name="set-content-disposition"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Translates a (file) name according to the configured file name translation rules.
    The result will also be all lower case." %>


<%@ attribute name="name" type="java.lang.String" required="true"
    description="The name to translate according to the configured OpenCms filename translation rules."%>

<%@ attribute name="allowSlash" type="java.lang.Boolean" required="false"
    description="Allow the slash '/' or backslash '\' char in the result. Default is 'true'."%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String result = "";
    String name = (String)getJspContext().getAttribute("name");
    Boolean allowSlashB = (Boolean)getJspContext().getAttribute("allowSlash");
    boolean allowSlash = (null == allowSlashB) ? true : allowSlashB.booleanValue();

    if (name.length() > 0) {
        if (!allowSlash) {
            name = name.replace('/','-');
            name = name.replace('\\','-');
        }
        result = org.opencms.main.OpenCms.getResourceManager().getFileTranslator().translateResource(name).toLowerCase();
    }
    getJspContext().setAttribute("translatedName", result);
%>

<c:out value="${translatedName}" escapeXml="false" />
