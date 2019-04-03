<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:init-messages>

<cms:formatter var="content" val="value">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="tileClass"              value="${setting.squareGrid.toString}" />
<c:set var="animationClass"         value="${setting.effect.toString != 'none' ? setting.effect.toString.concat(' effect-box') : ''}" />
<c:set var="fullOverlay"            value="${setting.fullOverlay.toBoolean}" />
<c:set var="tileCss"                value="${empty param.tilegrid ? 'tile-col col-sm-6 col-md-4 col-lg-3' : param.tilegrid}" />

<c:if test="${value.Image.isSet}">
    <c:set var="image" value="${value.Image}" />
</c:if>

<c:set var="tileClass" value="${tileCss} min-height-px" />

<div class="${tileClass}">
<div class="content-box ${animationClass}${' '}${cssWrapper}">

<mercury:link link="${content.value.Link}">

<c:choose>
<c:when test="${not empty image}">
    <cms:addparams>
        <cms:param name="cssgrid" value="${tileClass}" />
        <mercury:image-animated
            image="${image}"
            ratio="${imageRatio}"
            addEffectBox="${true}"
            ade="true"
            title="${value.Title}" />
    </cms:addparams>
</c:when>
<c:otherwise>
    <mercury:padding-box ratio="${imageRatio}" />
</c:otherwise>
</c:choose>

<div class="${fullOverlay ? 'full-overlay' : 'text-overlay'}">
    <mercury:section-piece
        heading="${value.Title}"
        pieceLayout="${1}"
        text="${value.Text}"
        link="${value.Link}"
        hsize="${hsize}"
        linkOption="${setting.linkOption.toString}"
        textOption="${setting.textOption.toString}"
        ade="${true}"
    />
</div>

</mercury:link>

</div>
</div>

</cms:formatter>
</mercury:init-messages>