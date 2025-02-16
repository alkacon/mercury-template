<%@ tag pageEncoding="UTF-8"
    display-name="parse-color"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Parses hex colors to RGB." %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The color value to parse." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:choose>
    <c:when test="${'transparent' eq fn:trim(value)}">
        <c:set var="result" value="255, 255, 255, 0" />
    </c:when>
    <c:otherwise>
        <c:set var="rgb" value="${cms.color.hexToRgb(value)}" />
        <c:if test="${not empty rgb}">
            <c:set var="result" value="${rgb[0]}, ${rgb[1]}, ${rgb[2]}" />
        </c:if>
    </c:otherwise>
</c:choose>
<c:out value="${result}" />


