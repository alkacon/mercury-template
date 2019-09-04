<%@ tag
    pageEncoding="UTF-8"
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
    description="Use lazy loading or not?
    Default is 'true'." %>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not?
    Default is 'true'." %>

<%@ attribute name="alt" type="java.lang.String" required="false"
    description="'alt' atttribute to set on the generated img tag." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="'title' atttribute to set on the generated img tag." %>

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


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="useNoScript" value="${empty noScript ? true : noScript}" />
<c:set var="useLazyLoading" value="${empty lazyLoad ? true : lazyLoad}" />
<c:set var="useSrcSet" value="${not empty srcSet}" />
<c:set var="emptyImg" value="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />

<%-- ###### Set img tag options depending on use case ###### --%>
<c:choose>
    <c:when test="${useSrcSet and useLazyLoading}">
        <c:set var="attributes"><%--
        --%>src="${srcUrl}" <%-- Note: src Required for IE 10, because of no srcset support in IE 10.
        --%>srcset="${emptyImg}" <%--
        --%>data-sizes="auto" <%--
        --%>data-srcset="${srcSet}"</c:set>
        <c:set var="cssImageLazy" value="lazyload" />
    </c:when>
    <c:when test="${not useSrcSet and useLazyLoading}">
        <c:set var="attributes"><%--
        --%>src="${emptyImg}" <%--
        --%>data-src="${srcUrl}"</c:set>
        <c:set var="cssImageLazy" value="lazyload" />
    </c:when>
    <c:when test="${useSrcSet}">
        <c:set var="attributes"><%--
        --%>src="${srcUrl}" <%--
        --%>sizes="${srcSetSizes}" <%--
        --%>srcset="${srcSet}"</c:set>
        <c:set var="useNoScript" value="${false}" />
    </c:when>
    <c:otherwise>
        <c:set var="attributes">src="${srcUrl}"</c:set>
        <c:set var="useNoScript" value="${false}" />
    </c:otherwise>
</c:choose>

<c:if test="${useNoScript}">
    <%-- ###### Two image tags will be generated in case <noscript> is used, hide the first one with CSS ###### --%>
    <c:set var="cssImageLazy" value="${cssImageLazy} hide-noscript" />
</c:if>

<mercury:nl />
<mercury:padding-box
    cssWrapper="image-src-box ${cssWrapper}"
    attrWrapper="${attrWrapper}"
    heightPercentage="${heightPercentage}"
    width="${width}"
    height="${height}">

    <img ${attributes}<%----%>
        <c:if test="${not empty width}">${' '}width="${width}"</c:if>
        <c:if test="${not empty height}">${' '}height="${height}"</c:if>
        <c:if test="${not empty cssImage or not empty cssImageLazy}">${' '}class="${cssImage}${' '}${cssImageLazy}"</c:if>
        <c:if test="${true}">${' '}alt="${alt}"</c:if><%-- Always provide an alt, even if it's empty --%>
        <c:if test="${not empty title and (title ne alt)}">${' '}title="${title}"</c:if>
        <c:if test="${not empty attrImage}">${' '}${attrImage}</c:if>
        <c:if test="${not empty zoomData}">${' '}${zoomData}</c:if><%--
--%>><%----%>

    <c:if test="${useNoScript}">
        <mercury:nl />
        <noscript><%----%>
            <img src=${'\"'}${srcUrl}${'\"'}<%----%>
                <c:if test="${not empty width}">${' '}width="${width}"</c:if>
                <c:if test="${not empty height}">${' '}height="${height}"</c:if>
                <c:if test="${not empty cssImage}">${' '}class="${cssImage}"</c:if>
                <c:if test="${true}">${' '}alt="${alt}"</c:if><%--
        --%>><%----%>
        </noscript><%----%>
    </c:if>

</mercury:padding-box>