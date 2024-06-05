<%@ tag pageEncoding="UTF-8"
    display-name="event-kind"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Checks what kind this event is.
    Possible return values are 'presence' (the default), 'online' or 'mixed'." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the booking information should be shown." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="hasVirtualLocation" value="${content.value.VirtualLocation.isSet and content.value.VirtualLocation.value.URI.isSet}" />
<c:set var="hasAddress" value="${content.value.AddressChoice.isSet and (content.value.AddressChoice.value.PoiLink.isSet or content.value.AddressChoice.value.Address.isSet)}" />
<c:choose>
    <c:when test="${hasVirtualLocation and hasAddress}">
        <c:set var="eventKind" value="mixed" />
    </c:when>
    <c:when test="${hasVirtualLocation}">
        <c:set var="eventKind" value="online" />
    </c:when>
    <c:otherwise>
        <c:set var="eventKind" value="presence" />
    </c:otherwise>
</c:choose>

${eventKind}