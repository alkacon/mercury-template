<%@ tag pageEncoding="UTF-8"
    display-name="parse-ratio"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Parses and checks ratio settings like '4-3'." %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The ratio value to parse." %>

<%@ attribute name="literals" type="java.util.List" required="false"
    description="Allowed literal values that do not follow the 'width-height' pattern, e.g. 'desk'." %>

<%@ variable name-given="checkedRatio" declare="true"
    description="The pased and checkd ratio. This will be emtpy in case the ratio input was not valid." %>

<%@ variable name-given="ratioWidth" declare="true"
    variable-class="java.lang.Integer"
    description="The width of the image in pixel." %>

<%@ variable name-given="ratioHeight" declare="true"
    variable-class="java.lang.Integer"
    description="The height of the image in pixel." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:choose>
    <c:when test="${not empty literals and fn:contains(literals, value)}">
        <c:set var="checkedRatio" value="${value}" />
    </c:when>
    <c:when test="${not empty value and fn:contains(value, '-')}">
        <c:set var="value" value="${fn:replace(value, ',', '.')}" />
        <c:set var="ratioWidth" value="${(cms.wrap[fn:substringBefore(value, '-')].toDouble * 100.0).intValue()}" />
        <c:set var="ratioHeight" value="${(cms.wrap[fn:substringAfter(value, '-')].toDouble * 100.0).intValue()}" />
        <c:if test="${(ratioWidth gt 0) and (ratioHeight gt 0)}">
            <c:set var="checkedRatio" value="${ratioWidth}-${ratioHeight}" />
        </c:if>
    </c:when>
</c:choose>

<jsp:doBody/>




