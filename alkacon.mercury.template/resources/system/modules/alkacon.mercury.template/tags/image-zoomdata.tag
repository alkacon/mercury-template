<%@ tag pageEncoding="UTF-8"
    display-name="image-zoomdata"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates zoom data for an image." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="The title to display with the zoomed image." %>

<%@ attribute name="copyright" type="java.lang.String" required="false"
    description="The copyright to display with the zoomed image." %>

<%@ attribute name="alt" type="java.lang.String" required="false"
    description="The alt text to display with the zoomed image." %>

<%@ attribute name="src" type="java.lang.String" required="false"
    description="Image source to use for the zoom.
    If not set, the 'src' attribute of the image tag will be used." %>

<%@ attribute name="width" type="java.lang.Integer" required="true"
    description="Width of the target image. Required for box size calculation." %>

<%@ attribute name="height" type="java.lang.Integer" required="true"
    description="Height of the target image. Required for box size calculation." %>

<%@ attribute name="imageBean" type="org.opencms.jsp.util.CmsJspImageBean" required="false"
    description="The image bean for the image. Used in case recalculation of the image size is required." %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${(not empty width) and (not empty height)}">
    <%-- ###### Caption shown in gallery can contain HTML markup for formatting ###### --%>
    <c:set var="caption">
        <c:if test="${not empty title}"><div class="title">${title}</div></c:if>
        <c:if test="${not empty copyright}"><div class="copyright">${copyright}</div></c:if>
    </c:set>
    <c:if test="${not empty imageBean}">
        <c:set var="imageIsSvg" value="${fn:endsWith(imageBean.vfsUri, '.svg')}" />
        <c:choose>
            <c:when test="${imageIsSvg}">
                <c:set var="src" value="${imageBean.resource.link}" />
                <c:set var="minSvgWidth" value="${500}" />
                <c:if test="${width lt minSvgWidth}">
                    <c:set var="scale" value="${width / height}" />
                    <c:set var="width" value="${minSvgWidth}" />
                    <c:set var="height" value="${cms.wrap[height * scale].mathFloor}" />
                </c:if>
            </c:when>
            <c:when test="${(width gt 2500) or (height gt 2500)}">
                <%-- The image may be to large for the image scaler, check this and if so use a smaller image --%>
                <mercury:image-sizes>
                    <c:if test="${(width gt maxScaleWidth) or (height gt maxScaleWidth)}">
                        <c:set var="scale" value="${width gt height ? (maxScaleWidth / width) : (maxScaleWidth / height)}" />
                        <c:set var="scaledImage" value="${imageBean.scaleWidth[cms.wrap[width * scale].mathFloor]}" />
                        <c:set var="src" value="${scaledImage.srcUrl}" />
                        <c:set var="width" value="${imageBean.scaler.width}" />
                        <c:set var="height" value="${imageBean.scaler.height}" />
                    </c:if>
                </mercury:image-sizes>
            </c:when>
        </c:choose>
    </c:if>
    <%-- Note: Both "width" and "w" given, so that older templates can also use this tag --%>
    <c:set var="dataImagezoom">data-imagezoom='{ "width": ${width}, "height": ${height}, "w": ${width}, "h": ${height}<%----%>
        <c:if test="${not empty caption}">, "caption": "${cms:encode(caption)}"</c:if>
        <c:if test="${not empty alt}">, "alt": "${cms:encode(alt)}"</c:if>
        <c:if test="${not empty src}">, "src": "${src}"</c:if> }'<%----%>
    </c:set>
</c:if>

${dataImagezoom}