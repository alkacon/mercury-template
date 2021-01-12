<%@ tag pageEncoding="UTF-8"
    display-name="padding-box"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Creates a fixed height padding box." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the generated div." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the generated div." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the box in a specific ratio,
    Example values: '1-1', '4-3', '3-2', '16-9', '2-1' and '2.35-1'" %>

<%@ attribute name="defaultRatio" type="java.lang.String" required="false"
    description="Alternative default ratio to use" %>

<%@ attribute name="width" type="java.lang.Number" required="false"
    description="Width of the target box size. Required for box size calculation." %>

<%@ attribute name="height" type="java.lang.Number" required="false"
    description="Height of the target box size. Required for box size calculation." %>

<%@ attribute name="heightPercentage" type="java.lang.String" required="false"
    description="Height of the target image in percentage relative to the target image width.
    Required for box size calculation." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually create the markup around the body to the calling element.
    If not set or 'true', the markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and just the body of the tag is returned. " %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:choose>
<c:when test="${empty test or test}">

    <jsp:doBody var="body" />

    <c:choose>
        <c:when test="${empty heightPercentage}">
            <c:set var="ratio" value="${(not empty defaultRatio) and ((empty ratio) or (ratio eq 'none')) ? defaultRatio : ratio}" />

            <c:if test="${(empty width or empty height) and (not empty ratio) and (ratio ne 'none')}">
                <c:set var="width" value="${cms:mathRound(cms:toNumber(fn:substringBefore(ratio, '-'), 16))}" />
                <c:set var="height" value="${cms:mathRound(cms:toNumber(fn:substringAfter(ratio, '-'), 9))}" />
            </c:if>

            <c:if test="${not empty width and not empty height}">
                <c:set var="cssWrapper">${cssWrapper} presized</c:set>
                <c:set var="paddingStyle">style="padding-bottom: ${cms:mathCeil((height / width) * 100000) / 1000}%;"</c:set>
            </c:if>
        </c:when>
        <c:otherwise>
            <c:set var="cssWrapper">${cssWrapper} presized</c:set>
            <c:set var="paddingStyle">style="padding-bottom: ${heightPercentage};"</c:set>
        </c:otherwise>
    </c:choose>

    <div class="${cssWrapper}" ${paddingStyle}${' '}${attrWrapper}><%----%>
    <c:if test="${not empty body}">
        <mercury:nl />
        ${body}
        <mercury:nl />
    </c:if>
    </div><%----%>
    <mercury:nl />

</c:when>
<c:otherwise>
    <%-- Initial test did fail --%>
    <jsp:doBody />
</c:otherwise>
</c:choose>
