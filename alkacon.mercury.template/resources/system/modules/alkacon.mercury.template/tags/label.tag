<%@ tag
    pageEncoding="UTF-8"
    display-name="label"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    import="java.lang.String, java.util.Locale"
    description="Displays a message from the OpenCms workplace bundles." %>


<%@ attribute name="locale" type="java.util.Locale" required="true"
    description="The locale to use for the message lookup." %>

<%@ attribute name="key" type="java.lang.String" required="true"
    description="The key to use for the message lookup." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<c:set var="rLocale" scope="request" value="${locale}" />
<c:set var="rKey" scope="request" value="${key}" /><%

    Locale locale = (Locale)request.getAttribute("rLocale");
    String key = (String)request.getAttribute("rKey");

    String message = org.opencms.main.OpenCms.getWorkplaceManager().getMessages(locale).key(key);

%><c:out value="<%= message %>" />
