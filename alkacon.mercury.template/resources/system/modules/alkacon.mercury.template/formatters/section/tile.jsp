<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<m:init-messages>
<cms:formatter var="content" val="value">

<m:setting-defaults>

<c:set var="hsize"              value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"         value="${setting.imageRatio}" />
<c:set var="fullOverlayOption"  value="${setting.fullOverlay.toString}" />
<c:set var="textOption"         value="${setting.textOption.toString}" />
<c:set var="linkOption"         value="${setting.linkOption.toString}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="textAlignment"      value="${setting.textAlignment.useDefault('pal').toString}" />
<c:set var="useAsElement"       value="${setting.tileContainer.toString eq 'element'}" />

<c:choose>
    <c:when test="${useAsElement}">
        <c:set var="tileClass"          value="element tile-col" />
    </c:when>
    <c:otherwise>
        <c:set var="tileClass"          value="${empty param.tilegrid ? 'tile-col col-12' : param.tilegrid}${' '}freefloat min-height-px ${fullOverlay ? 'f-o' : 't-o'}" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${fullOverlayOption eq 'boxbg'}">
        <c:set var="linkFullTile"       value="${linkOption eq 'none'}" />
        <c:set var="linkOption"         value="${linkOption eq 'hide' ? 'false' : linkOption}" />
        <c:set var="overlayWrapper"     value="full-overlay boxbg-overlay" />
    </c:when>
    <c:when test="${fullOverlayOption eq 'true'}">
        <c:set var="linkFullTile"       value="${linkOption eq 'none'}" />
        <c:set var="linkOption"         value="${linkOption eq 'hide' ? 'false' : linkOption}" />
        <c:set var="overlayWrapper"     value="full-overlay" />
    </c:when>
    <c:otherwise>
        <%-- fullOverlayOption should be 'false' --%>
        <c:set var="linkFullTile"       value="${true}" />
        <c:set var="linkOption"         value="false" />
        <c:set var="overlayWrapper"     value="text-overlay" />
    </c:otherwise>
</c:choose>

<m:tile-col
    heading="${value.Title}"
    image="${value.Image}"
    text="${value.Text}"
    link="${value.Link}"
    linkFullTile="${linkFullTile}"
    tileWrapper="${tileClass}"
    boxWrapper="${setCssWrapperAll}"
    overlayWrapper="${overlayWrapper}"
    hsize="${hsize}"
    imageRatio="${imageRatio}"
    showImageCopyright="${showImageCopyright}"
    textOption="${textOption}"
    linkOption="${linkOption}"
    textAlignment="${textAlignment}"
    ade="${cms.isEditMode}"
/>

</m:setting-defaults>

</cms:formatter>
</m:init-messages>