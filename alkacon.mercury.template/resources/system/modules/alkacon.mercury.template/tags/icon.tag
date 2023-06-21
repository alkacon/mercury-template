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

<%@ attribute name="tag" type="java.lang.String" required="true"
    description="The tag that is generated around the icon." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="CSS wrapper added to the generated tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the generated tag." %>

<%@ attribute name="inline" type="java.lang.Boolean" required="false"
    description="Controls if the icon should be inlined as SVG,
    or rendered from an icon font (the default)." %>

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


<c:set var="ariaHidden"     value="${empty ariaHidden ? empty ariaLabel : ariaHidden}" />
<c:set var="icon"           value="${fn:trim(icon)}" />
<c:set var="isBootstrap"    value="${fn:startsWith(icon, 'bi-')}" />
<c:set var="isFlag"         value="${fn:startsWith(icon, 'fi-')}" />

<c:choose>
    <c:when test="${isBootstrap}">
        <c:set var="inline"         value="${true}" />
    </c:when>
    <c:when test="${isFlag}">
        <c:set var="imgsrc"         value="${true}" />
        <c:set var="inline"         value="${false}" />
    </c:when>
    <c:otherwise>
        <c:set var="selectedIcons"  value="${fn:contains(cms.sitemapConfig.attribute['mercury.iconFont.config'].toString, 'Selection')}" />
        <c:set var="noInline"       value="${fn:startsWith(icon, 'no-')}" />
        <c:set var="inline"         value="${inline and selectedIcons and (not noInline)}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${inline}">
        <mercury:icon-resource icon="${icon}" setFallback="${true}" />
        <c:set var="iconClass" value="ico ico-svg ico-inline ${iconName}" />
        <c:if test="${not iconIsValid}">
            <c:set var="iconClass" value="${iconClass} ico-missing" />
        </c:if>
        <c:set var="iconMarkup">
            <c:out value="${fn:replace(iconResource.content, 'xmlns=\"http://www.w3.org/2000/svg\" ', '')}" escapeXml="${false}" />
        </c:set>
    </c:when>
    <c:when test="${imgsrc}">
        <mercury:icon-resource icon="${icon}" setFallback="${true}" />
        <c:set var="iconClass" value="ico ico-img ${iconName}" />
        <c:choose>
            <c:when test="${not iconIsValid}">
                <c:set var="iconClass" value="ico ico-svg ico-inline ${iconName} ico-missing" />
                <c:set var="iconMarkup">
                    <c:out value="${fn:replace(iconResource.content, 'xmlns=\"http://www.w3.org/2000/svg\" ', '')}" escapeXml="${false}" />
                </c:set>
            </c:when>
            <c:otherwise>
                <c:set var="iconMarkup">
                    <img src="${iconResource.sitePath}" height="480" width="640"><%-- height and width can be static as long as only flag icons are used --%>
                </c:set>
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:when test="${noInline}">
        <c:set var="iconName" value="${fn:substringAfter(icon, 'no-')}" />
        <c:set var="iconClass" value="ico fa fa-${iconName}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fa-')}">
        <c:set var="iconClass" value="ico fa ${icon}" />
    </c:when>
    <c:otherwise>
        <c:set var="iconClass" value="ico fa fa-${icon}" />
    </c:otherwise>
</c:choose>

<${tag}${' '}<%--
--%>${empty attrWrapper ? '' : attrWrapper.concat(' ')}<%--
--%>class="<c:out value="${empty cssWrapper ? '' : cssWrapper.concat(' ')}${iconClass}" escapeXml="${true}" />"<%--
--%>${empty ariaLabel ? '' : ' aria-label=\"'.concat(ariaLabel).concat('\" role=\"img\"')}<%--
--%>${ariaHidden ? ' aria-hidden=\"true\"' : ''}<%--
--%>><%----%>
    <c:if test="${not empty iconMarkup}">${iconMarkup}</c:if>
</${tag}><%----%>
