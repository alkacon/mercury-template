<%@ tag pageEncoding="UTF-8"
    display-name="icon"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays icons from different icon sets." %>


<%@ attribute name="icon" type="java.lang.String" required="true"
    description="The name or id of the icon to render.
    The selection is based on a prefix.
    Supported prefixes are:
    fa- : use Fork Awesome.
    bi- : use Boostrap icons.
    my- : use Mercury icons.
    fab- : use Font Awesome Brand icons.
    fas- : use Font Awesome Solid icons.
    far- : use Font Awesome Regular icons.
    nf- : use National Flag icons.
    cif- : use custom icon font.
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

<%@ attribute name="fromImage" type="java.lang.Boolean" required="false"
    description="If 'true', then do NOT use an icon from a default font but treat the 'icon' parameter as path to an image resource." %>

<%@ attribute name="useSvg" type="java.lang.Boolean" required="false"
    description="If 'true', load the icon using 'svg use:href', i.e. from an exernal file.
    This is an alternative to displaying SVG icons with the 'inline' attribute.
    Compared to loading the icon with 'img src', this allows for styling the icon with CSS 'fill' etc.
    NOTE: This requires that the SVG icon has the attribute id='icon' set at the root svg node." %>

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
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="ariaHidden"     value="${empty ariaHidden ? empty ariaLabel : ariaHidden}" />
<c:set var="icon"           value="${fn:trim(icon)}" />
<c:choose>
    <c:when test="${fromImage or useSvg}">
        <c:set var="inline"         value="${false}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'cif-')}">
        <%-- Custom icon font --%>
        <c:set var="inline"         value="${false}" />
        <c:set var="customFont"     value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'bi-')}">
        <c:set var="inline"         value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'my-')}">
        <c:set var="inline"         value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fab-')}">
        <c:set var="inline"         value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'fas-')}">
        <c:set var="inline"         value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'far-')}">
        <c:set var="inline"         value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'nf-')}">
        <c:set var="inline"         value="${false}" />
        <c:set var="imgsrc"         value="${true}" />
    </c:when>
    <c:when test="${fn:startsWith(icon, 'no-')}">
        <%-- The icon font is 'fa', the icon must not be inlined. --%>
        <c:set var="inline"         value="${false}" />
        <c:set var="noInline"       value="${true}" />
    </c:when>
    <c:otherwise>
        <%-- The icon font is 'fa', there may or may not be an 'fa-' prefix, we will check this later. --%>
        <c:set var="inline"         value="${inline and fn:contains(cms.sitemapConfig.attribute['mercury.iconFont.config'].toString, 'Selection')}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${inline}">
        <m:icon-resource icon="${icon}" setFallback="${true}" />
        <c:set var="iconClass" value="ico ico-svg ico-inline ${iconName}" />
        <c:if test="${not iconIsValid}">
            <c:set var="iconClass" value="${iconClass} ico-missing" />
        </c:if>
        <c:set var="iconMarkup">
            <c:out value="${fn:replace(fn:replace(iconResource.content, 'id=\"icon\"', ''), 'xmlns=\"http://www.w3.org/2000/svg\" ', '')}" escapeXml="${false}" />
        </c:set>
    </c:when>
    <c:when test="${fromImage or useSvg or imgsrc}">
        <m:icon-resource icon="${icon}" setFallback="${true}" fromImage="${fromImage}" />
        <c:choose>
            <c:when test="${not iconIsValid}">
                <c:set var="iconClass" value="ico ico-svg ico-inline ${iconName} ico-missing" />
                <c:set var="iconMarkup">
                    <c:out value="${fn:replace(iconResource.content, 'xmlns=\"http://www.w3.org/2000/svg\" ', '')}" escapeXml="${false}" />
                </c:set>
            </c:when>
            <c:otherwise>
                <c:choose>
                    <c:when test="${useSvg}">
                        <c:set var="iconClass" value="ico ico-svg ico-usesvg ${iconName}" />
                        <c:set var="iconMarkup">
                            <m:image-vars image="${iconResource}">
                                <svg viewBox="0 0 ${imageWidth}${' '}${imageHeight}"><%----%>
                                    <use href="${imageUrl}#icon"><%----%>
                                </svg><%----%>
                            </m:image-vars>
                        </c:set>
                    </c:when>
                    <c:otherwise>
                        <c:set var="iconClass" value="ico ico-img ${iconName}" />
                        <c:set var="iconMarkup">
                            <m:image-direct image="${iconResource}" />
                        </c:set>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:when test="${noInline}">
        <c:set var="iconName" value="${fn:substringAfter(icon, 'no-')}" />
        <c:set var="iconClass" value="ico fa fa-${iconName}" />
    </c:when>
    <c:when test="${customFont}">
        <c:set var="iconClass" value="ico cif ${icon}" />
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
