<%@ tag pageEncoding="UTF-8"
    display-name="idgen"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a JavaScript ID based on element UID and name." %>


<%@ attribute name="prefix" type="java.lang.String" required="true"
    description="The prefix for the generated ID." %>

<%@ attribute name="uuid" type="java.lang.String" required="true"
    description="The UUID to create the JavaScript ID from." %>

<%@ attribute name="translate" type="java.lang.Boolean" required="false"
    description="If 'true' the provided prefix is translated for 'save for id' characters. Default is 'false'." %>

<%@ attribute name="delimiter" type="java.lang.String" required="false"
    description="Delimiter to place between the prefix and ID. Default is  '_'." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="delimiter" value="${empty delimiter ? '_' : delimiter}" />

<c:if test="${translate}">
    <c:set var="prefix"><m:translate-name name="${fn:trim(prefix)}" allowSlash="${false}" /></c:set>
</c:if>

<c:out value="${prefix}${delimiter}${fn:substringBefore(uuid, '-')}" />

