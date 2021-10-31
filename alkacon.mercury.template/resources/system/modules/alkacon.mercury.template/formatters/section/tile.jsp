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

<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="cssWrapper"         value="${setting.cssWrapper.isSet ? ' '.concat(setting.cssWrapper.toString) : null}" />
<c:set var="effect"             value="${setting.effect.isSetNotNone ? ' '.concat(setting.effect.toString) : null}" />
<c:set var="cssVisibility"      value="${setting.cssVisibility.toString ne 'always' ? ' '.concat(setting.cssVisibility.toString) : null}" />
<c:set var="hsize"              value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"         value="${setting.imageRatio}" />
<c:set var="tileContainer"      value="${setting.tileContainer.toString}" />
<c:set var="fullOverlay"        value="${setting.fullOverlay.toBoolean}" />
<c:set var="textOption"         value="${setting.textOption.toString}" />
<c:set var="linkOption"         value="${fullOverlay ? setting.linkOption.toString : 'none'}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="textAlignment"      value="${setting.textAlignment.useDefault('pal').toString}" />
<c:set var="useAsElement"       value="${tileContainer eq 'element'}" />
<c:set var="ade"                value="${cms.isEditMode}" />

<c:choose>
    <c:when test="${useAsElement}">
        <c:set var="tileClass"          value="element tile-col" />
    </c:when>
    <c:otherwise>
        <c:set var="tileCss"            value="${empty param.tilegrid ? 'tile-col col-sm-6 col-lg-3' : param.tilegrid}" />
        <c:set var="tileCss"            value="${tileCss.concat(' freefloat')}" />
        <c:set var="tileClass"          value="${tileCss} min-height-px" />
        <c:set var="tileClass"          value="${tileClass}${fullOverlay ? ' f-o' : ' t-o'}" />
    </c:otherwise>
</c:choose>

<c:if test="${value.Image.isSet}">
    <c:set var="image" value="${value.Image}" />
</c:if>

<mercury:nl />
<div class="${tileClass}"><%----%>

    <div class="content-box${cssWrapper}${effect}${cssVisibility}"><%----%>

        <mercury:link link="${value.Link}" test="${linkOption eq 'none'}">

            <c:choose>
                <c:when test="${not empty image}">
                    <cms:addparams>
                        <cms:param name="cssgrid" value="${tileClass}" />
                        <mercury:image-animated
                            image="${image}"
                            ratio="${imageRatio}"
                            addEffectBox="${true}"
                            ade="${ade}"
                            title="${value.Title}">
                            <c:set var="imageCopyright" value="${imageCopyrightHtml}" scope="request" />
                        </mercury:image-animated>
                    </cms:addparams>
                </c:when>
                <c:otherwise>
                    <mercury:padding-box ratio="${imageRatio}" defaultRatio="4-3" />
                </c:otherwise>
            </c:choose>

            <c:set var="tileText">
                <mercury:section-piece
                    cssWrapper="${textAlignment}"
                    heading="${value.Title}"
                    pieceLayout="${1}"
                    text="${value.Text}"
                    link="${value.Link}"
                    hsize="${hsize}"
                    linkOption="${linkOption}"
                    textOption="${textOption}"
                    ade="${ade and (linkOption ne 'none')}"
                    emptyWarning="${false}"
                />
            </c:set>

            <c:if test="${not empty tileText}">
                <div class="${fullOverlay ? 'full-overlay' : 'text-overlay'}"><%----%>
                    ${tileText}
                </div><%----%>
            </c:if>

            <c:if test="${showImageCopyright and not empty imageCopyright}">
                <div class="copyright">${imageCopyright}</div><%----%>
            </c:if>

        </mercury:link>

    </div><%----%>
</div><%----%>
<mercury:nl />

</cms:formatter>
</mercury:init-messages>