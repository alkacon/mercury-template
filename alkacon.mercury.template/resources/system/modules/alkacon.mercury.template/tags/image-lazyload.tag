<%@ tag pageEncoding="UTF-8"
    display-name="image-lazyload"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates lazy load markup for an image." %>


<%@ attribute name="srcUrl" type="java.lang.String" required="true"
    description="The source URL of the main target image." %>

<%@ attribute name="srcSet" type="java.lang.String" required="false"
    description="The source set data for the image." %>

<%@ attribute name="srcSetSizes" type="java.lang.String" required="false"
    description="The source set sizes data for the image." %>

<%@ attribute name="width" type="java.lang.Integer" required="false"
    description="Width of the target image." %>

<%@ attribute name="height" type="java.lang.Integer" required="false"
    description="Height of the target image." %>

<%@ attribute name="heightPercentage" type="java.lang.String" required="false"
    description="Height of the target image in percentage relative to the target image width.
    Required for box size calculation." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not? Default is 'true'."%>

<%@ attribute name="lazyLoadJs" type="java.lang.Boolean" required="false"
    description="false (default): lazy loading using native browser support. true: lazy loading with JavaScript."%>

<%@ attribute name="addPaddingBox" type="java.lang.Boolean" required="false"
    description="Add a padding box (div with class 'presized') around the image? If 'true' the box will be added when needed. If 'false' no box will be added. Default is 'true'."%>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not?
    Default is 'true'." %>

<%@ attribute name="alt" type="java.lang.String" required="false"
    description="'alt' atttribute to set on the generated img tag." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="'title' atttribute to set on the generated img tag." %>

<%@ attribute name="copyright" type="java.lang.String" required="false"
    description="Copyright information to display as an image overlay.
    If this is emtpy, no copyright overlay will be displayed." %>

<%@ attribute name="cssImage" type="java.lang.String" required="false"
    description="'class' atttribute to set directly on the generated img tag."%>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the src-box div surrounding the generated img." %>

<%@ attribute name="attrImage" type="java.lang.String" required="false"
    description="Attribute(s) to add directly to the generated img tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the src-box div surrounding the generated img." %>

<%@ attribute name="zoomData" type="java.lang.String" required="false"
    description="Zoom data attribute added directly to the generated image tag." %>

<%@ attribute name="debug" type="java.lang.Boolean" required="false"
    description="Enables debug output. Default is 'false' if not provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="useNoScript" value="${empty noScript ? true : noScript}" />
<c:set var="useJsLazyLoading" value="${false or lazyLoadJs}" />
<c:set var="useLazyLoading" value="${empty lazyLoad ? true : lazyLoad}" />
<c:set var="useSrcSet" value="${not empty srcSet}" />
<c:set var="hasWidthHeight" value="${(width gt 0) and (height gt 0)}" />
<c:set var="alt">${fn:replace(alt, '"', '\'')}</c:set>
<c:set var="title">${fn:replace(title, '"', '\'')}</c:set>
<c:set var="DEBUG" value="${false or debug}" />

<c:set var="emptyImg" value="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />

<%-- Set img tag options depending on use case --%>
<c:choose>
    <c:when test="${useSrcSet and useJsLazyLoading}">
        <c:set var="attributes"><%--
        --%>src="${srcUrl}" <%-- Note: src Required for IE 10, because of no srcset support in IE 10.
        --%>srcset="${emptyImg}" <%--
        --%>data-sizes="auto" <%--
        --%>data-srcset="${srcSet}"</c:set>
        <c:set var="cssImageLazy" value="lazyload" />
    </c:when>
    <c:when test="${not useSrcSet and useJsLazyLoading}">
        <c:set var="attributes"><%--
        --%>src="${emptyImg}" <%--
        --%>data-src="${srcUrl}"</c:set>
        <c:set var="cssImageLazy" value="lazyload" />
    </c:when>
    <c:when test="${useSrcSet and not empty srcSetSizes}">
        <c:set var="attributes"><%--
        --%>src="${srcUrl}"<%--
        --%>${useLazyLoading ? ' loading=\"lazy\"' : ''} <%--
        --%>sizes="${srcSetSizes}" <%--
        --%>srcset="${srcSet}"</c:set>
        <c:set var="useNoScript" value="${false}" />
    </c:when>
    <c:otherwise>
        <c:set var="attributes"><%--
        --%>src="${srcUrl}"<%--
        --%>${useLazyLoading ? ' loading=\"lazy\"' : ''}</c:set>
        <c:set var="useNoScript" value="${false}" />
    </c:otherwise>
</c:choose>

<m:print comment="${true}" test="${DEBUG}">
    image-lazyload:

    useLazyLoading: ${useLazyLoading}
    useJsLazyLoading: ${useJsLazyLoading}
    useSrcSet: ${useSrcSet}
    srcSetSizes: ${srcSetSizes}
    empty srcSetSizes: ${empty srcSetSizes}
    useNoScript: ${useNoScript}
</m:print>

<c:if test="${useNoScript}">
    <%-- Two image tags will be generated in case <noscript> is used, hide the first one with CSS --%>
    <c:set var="cssImageLazy" value="${cssImageLazy} hide-noscript" />
</c:if>

<c:if test="${(addPaddingBox eq false) and hasWidthHeight}">
    <c:set var="styleAttr">style="aspect-ratio: ${width} / ${height};"</c:set>
    <c:set var="attrImage" value="${empty attrImage ? styleAttr : attrImage.concat(' ').concat(styleAttr)}" />
</c:if>

<m:nl />
<m:padding-box
    cssWrapper="${empty cssWrapper ? '' : cssWrapper.concat(' ')}image-src-box"
    attrWrapper="${attrWrapper}"
    heightPercentage="${heightPercentage}"
    width="${width}"
    height="${height}"
    test="${addPaddingBox}">

    <img ${attributes}<%----%>
        <c:if test="${not empty width}">${' '}width="${width}"</c:if>
        <c:if test="${not empty height}">${' '}height="${height}"</c:if>
        <c:if test="${not empty cssImage or not empty cssImageLazy}">${' '}class="${cssImage}${empty cssImage or empty cssImageLazy ? '' : ' '}${cssImageLazy}"</c:if>
        <c:if test="${true}">${' '}alt="<m:out value="${alt}" lenientEscaping="${true}" />"</c:if><%-- Always provide an alt, even if it's empty --%>
        <c:if test="${not empty title and (title ne alt)}">${' '}title="<m:out value="${title}" lenientEscaping="${true}" />"</c:if>
        <c:if test="${not empty attrImage}">${' '}${attrImage}</c:if>
        <c:if test="${not empty zoomData}">
            <fmt:setLocale value="${cms.locale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                ${' '}${zoomData}
                ${' '}aria-label="${not empty alt ? alt.concat(' - ') : ''}
                <fmt:message key="msg.aria.click-to-enlarge" />
                ${'\" '}role="button" tabindex="0"<%----%>
            </cms:bundle>
        </c:if><%--
--%>><%----%>

    <c:if test="${useNoScript}">
        <m:nl />
        <noscript><%----%>
            <img src=${'\"'}${srcUrl}${'\"'}<%----%>
                <c:if test="${not empty width}">${' '}width="${width}"</c:if>
                <c:if test="${not empty height}">${' '}height="${height}"</c:if>
                <c:if test="${not empty cssImage}">${' '}class="${cssImage}"</c:if>
                <c:if test="${true}">${' '}alt="<m:out value="${alt}" lenientEscaping="${true}" />"</c:if>
        --%>><%----%>
        </noscript><%----%>
    </c:if>

    <c:if test="${not empty copyright}">
        <div class="copyright image-copyright" aria-hidden="true">
            <m:out value="${copyright}" lenientEscaping="${true}" />
        </div>
    </c:if>

</m:padding-box>