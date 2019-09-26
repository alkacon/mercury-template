<%@ tag pageEncoding="UTF-8"
    display-name="idgen"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a JavaScript ID based on element UID and name." %>


<%@ attribute name="prefix" type="java.lang.String" required="true"
    description="The prefix for the generated ID." %>

<%@ attribute name="uuid" type="java.lang.String" required="true"
    description="The UUID to create the JavaScript ID from." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:out value="${prefix}_${fn:substringBefore(uuid, '-')}" />