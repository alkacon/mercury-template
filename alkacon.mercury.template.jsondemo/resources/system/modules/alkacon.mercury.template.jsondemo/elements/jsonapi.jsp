<%@page import="java.util.Map"%>
<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<c:set var="uri">
    <cms:link>${param.uri}</cms:link>
</c:set>

<%
String uri = (String)pageContext.getAttribute("uri");
boolean first = true;
for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
    String name = entry.getKey();
    String value = entry.getValue()[0];
    if (name.equals("uri")) {
        continue;
    } else if (first) {
        uri += "?" + name;
        first = false;
    } else {
        uri += "&" + name;
    }
    if (value != "") {
        uri += "=" + value;
    }
}
response.setStatus(301);
response.sendRedirect(uri);
%>