<%@ tag pageEncoding="UTF-8"
    display-name="image-zoomdata"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates zoom data for an image." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="The title to display with the zoomed image." %>

<%@ attribute name="copyright" type="java.lang.String" required="false"
    description="The copyright to display with the zoomed image." %>

<%@ attribute name="src" type="java.lang.String" required="false"
    description="Image source to use for the zoom.
    If not set, the 'src' attribute of the image tag will be used." %>

<%@ attribute name="width" type="java.lang.Integer" required="true"
    description="Width of the target image. Required for box size calculation." %>

<%@ attribute name="height" type="java.lang.Integer" required="true"
    description="Height of the target image. Required for box size calculation." %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>


<c:if test="${(not empty width) and (not empty height)}">
    <%-- ###### Caption shown in gallery can contain HTML markup for formatting ###### --%>
    <c:set var="caption">
        <c:if test="${not empty title}"><div class="title">${title}</div></c:if>
        <c:if test="${not empty copyright}"><div class="copyright">${copyright}</div></c:if>
    </c:set>
    <%-- Note: Both "width" and "w" given, so that older templates can also use this tag --%>
    <c:set var="dataImagezoom">data-imagezoom='{ "width": ${width}, "height": ${height}, "w": ${width}, "h": ${height}<%----%>
        <c:if test="${not empty caption}">, "caption": "${cms:encode(caption)}"</c:if>
        <c:if test="${not empty src}">, "src": "${src}"</c:if> }'<%----%>
    </c:set>
</c:if>

${dataImagezoom}