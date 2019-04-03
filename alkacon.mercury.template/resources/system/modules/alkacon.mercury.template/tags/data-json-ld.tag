<%@ tag
    pageEncoding="UTF-8"
    display-name="json-ld"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates JSON-LD information for contents." %>


<%@ attribute name="properties" type="java.util.LinkedHashMap" required="true"
    description="The properties to show for the schema."%>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="The optional schema type name, can be used on initial call."%>

<%@ attribute name="url" type="java.lang.String" required="false"
    description="The optional URL of the item, can be used on initial call."%>

<%@ attribute name="innerschema" type="java.lang.Boolean" required="false"
    description="Determines if this is an inner schema to generate." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="isInnerSchema">${innerschema != null && innerschema}</c:set>

<c:if test="${not isInnerSchema}">
    <c:out value='<script type="application/ld+json">' escapeXml="false"/>
</c:if><%--
--%>{<%--
--%><c:if test="${not isInnerSchema}">"@context": "http://schema.org",</c:if>
    <c:if test="${not empty type}">"@type": "<c:out value="${type}" />",</c:if>
    <c:if test="${not empty url}">"url" : "<c:out value="${url}" />",</c:if>
    <c:forEach var="property" items="${properties}" varStatus="status">
        <c:set var="key" value="${property.key}" />
        <c:set var="val" value="${property.value}" /><%--
    --%>"<c:out value="${key}" />": <%--
    --%><c:choose>
            <c:when test="${val.getClass().simpleName == 'String' or cms:isWrapper(val)}">
                <c:if test="${cms:isWrapper(val)}">
                    <c:set var="val" value="${val.stringValue}" />
                </c:if>
                <c:set var="val"><mercury:meta-value text="${val}" /></c:set><%--
            --%>"<c:out value="${val}" />"<%--
        --%></c:when>
            <c:otherwise>
                <mercury:data-json-ld properties="${val}" innerschema="true" />
            </c:otherwise>
        </c:choose>
        <c:if test="${not status.last}">,</c:if>
    </c:forEach><%--
--%>}<%--
--%><c:if test="${not isInnerSchema}">
    <c:out value='</script>' escapeXml="false"/>
</c:if>