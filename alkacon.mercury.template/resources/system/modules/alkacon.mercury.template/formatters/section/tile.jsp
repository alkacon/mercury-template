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
<c:set var="cssWrapper"             value="${setting.cssWrapper.isSet ? ''.concat(setting.cssWrapper.toString) : ''}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="tileClass"              value="${setting.squareGrid.toString}" />
<c:set var="animationClass"         value="${setting.effect.toString ne 'none' ? ' '.concat(setting.effect.toString.concat(' effect-piece')) : ''}" />
<c:set var="fullOverlay"            value="${setting.fullOverlay.toBoolean}" />
<c:set var="textOption"             value="${setting.textOption.toString}" />
<c:set var="linkOption"             value="${fullOverlay ? setting.linkOption.toString : 'none'}" />
<c:set var="tileCss"                value="${empty param.tilegrid ? 'tile-col col-sm-6 col-md-4 col-lg-3' : param.tilegrid}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />

<c:if test="${value.Image.isSet}">
    <c:set var="image" value="${value.Image}" />
</c:if>

<c:set var="tileClass" value="${tileCss} min-height-px" />

<mercury:nl />
<div class="${tileClass}${fullOverlay ? ' f-o' : ' t-o'}"><%----%>
    <div class="content-box${animationClass}${cssWrapper}"><%----%>

        <mercury:link link="${value.Link}" test="${linkOption eq 'none'}">

            <c:choose>
                <c:when test="${not empty image}">
                    <cms:addparams>
                        <cms:param name="cssgrid" value="${tileClass}" />
                        <mercury:image-animated
                            image="${image}"
                            ratio="${imageRatio}"
                            addEffectBox="${true}"
                            ade="${true}"
                            title="${value.Title}">
                            <c:set var="imageCopyright" value="${imageCopyrightHtml}" scope="request" />
                        </mercury:image-animated>
                    </cms:addparams>
                </c:when>
                <c:otherwise>
                    <mercury:padding-box ratio="${imageRatio}" />
                </c:otherwise>
            </c:choose>

            <div class="${fullOverlay ? 'full-overlay' : 'text-overlay'}"><%----%>
                <mercury:section-piece
                    heading="${value.Title}"
                    pieceLayout="${1}"
                    text="${value.Text}"
                    link="${value.Link}"
                    hsize="${hsize}"
                    linkOption="${linkOption}"
                    textOption="${textOption}"
                    ade="${linkOption ne 'none'}"
                />
            </div><%----%>

            <c:if test="${showImageCopyright and not empty imageCopyright}">
                <div class="image-copyright">${imageCopyright}</div><%----%>
            </c:if>

        </mercury:link>

    </div><%----%>
</div><%----%>
<mercury:nl />

</cms:formatter>
</mercury:init-messages>