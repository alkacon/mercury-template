<%@ tag pageEncoding="UTF-8"
    display-name="icon"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays icons from different icon sets." %>


<%@ attribute name="icon" type="java.lang.String" required="true"
    description="The name or id of the icon to render.
    The selection is based on a prefix.
    Supported prefixes are:
    fa- : use Fork Awesome
    bi- : use Boostrap Icons.
    In case no prefix is given, the default is Fork Awesome" %>

<%@ attribute name="use" type="java.lang.String" required="false"
    description="Use case of the icon.
    If provided, the iconName can in certain configurations be replaced by a different name, depending on the use case." %>

<%@ attribute name="tag" type="java.lang.String" required="false"
    description="If provided, a tag with the given tagName is generated around the icon.
    If this is empty, no tag is generated." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="If provided, the output is prefixed with the given css wrapper." %>

<%@ attribute name="ariaLabel" required="false"
    description="The aria-label attribute to add to the generated tag.
    In case this is set, an attribut 'role=img' is also added.
    Only used if a tagName is provided." %>

<%@ attribute name="ariaHidden" type="java.lang.Boolean" required="false"
    description="Appends aria-hidden='true' to the generated tag.
    The default is 'true' if 'ariaLabel' is empty, or 'false' othereise.
    Only used if a tagName is provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="ariaHidden" value="${empty ariaHidden ? empty ariaLabel : ariaHidden}" />

<c:choose>
    <c:when test="${fn:startsWith(icon, 'bi-')}">
        <c:set var="iconClass" value="${icon}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fa-')}">
        <c:set var="iconClass" value="fa ${icon}" />
    </c:when>
    <c:otherwise>
        <c:set var="iconClass" value="fa fa-${icon}" />
    </c:otherwise>
</c:choose>

<c:if test="${not empty tag}"><${tag} class="</c:if>

<c:out value="${empty cssWrapper ? '' : cssWrapper.concat(' ')}${iconClass}" escapeXml="${true}" />

<c:if test="${not empty tag}">"<%--
--%>${empty ariaLabel ? '' : ' aria-label=\"'.concat(ariaLabel).concat('\" role=\"img\"')}<%--
--%>${ariaHidden ? ' aria-hidden=\"true\"' : ''}<%--
--%>></${tag}><%----%>
</c:if>