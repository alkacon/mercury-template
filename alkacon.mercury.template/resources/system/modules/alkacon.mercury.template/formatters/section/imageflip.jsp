<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="isTile"                 value="${setting.isTile.toBoolean}" />
<c:if test="${isTile}">
    <c:set var="tileCss"            value="${empty param.tilegrid ? 'tile-col col-sm-6 col-lg-3' : param.tilegrid}" />
</c:if>

<mercury:init-messages css="${tileCss}">

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:choose>
<c:when test="${value.Image.isSet}">

<mercury:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="ratio"                  value="${setting.imageRatio.toString}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showTextFirst"          value="${setting.showTextFirst.toBoolean}" />
<c:set var="doNotFlip"              value="${setting.doNotFlip.toBoolean}" />
<c:set var="flipColor"              value="${setting.flipColor.toString}" />
<c:set var="flipTitle"              value="${setting.flipTitle.useDefault('on-text').toString}" />

<c:set var="title"                  value="${value.Title.toString}" />

<mercury:image-vars
    image="${value.Image}"
    ratio="${ratio}"
    title="${title}"
    ade="${false}">

<c:set var="imageSide">
    <div class="image-section ${showTextFirst ? ' back' : ' front'}${doNotFlip and (not showTextFirst) ? ' noflip' : ''}"><%----%>
        <mercury:image-srcset
            imagebean="${imageBean}"
            cssWrapper="img-responsive"
            copyright="${showImageCopyright ? imageCopyrightHtml : null}"
            alt="${title}"
        />
        <c:if test="${not empty flipTitle and (flipTitle ne 'on-text')}">
            <div class="heading"><%----%>
                <mercury:heading
                    text="${value.Title}"
                    level="${flipTitle eq 'on-both' ? 7 : hsize}"
                    css="text-heading${flipTitle eq 'on-both' ? ' h'.concat(hsize) : ''}"
                />
            </div><%----%>
        </c:if>
    </div><%----%>
</c:set>

<c:set var="textSide">
    <div class="text-section ${showTextFirst ? 'front' : 'back'}${doNotFlip and showTextFirst ? ' noflip' : ''}"><%----%>
        <mercury:section-piece
            heading="${value.Title}"
            pieceLayout="${1}"
            text="${value.Text}"
            link="${value.Link}"
            hsize="${flipTitle ne 'on-image' ? hsize : 0}"
            ade="${false}"
        />
    </div><%----%>
</c:set>

<mercury:nl />
<div class="element imageflip h-${flipTitle}${' '}${tileCss}${' '}${flipColor}${setCssWrapperAll}" ontouchstart="this.classList.toggle('hover');"><%----%>
    <mercury:padding-box ratio="${ratio}" cssWrapper="flipper">
        ${showTextFirst ? textSide : imageSide}
        <c:if test="${not doNotFlip}">
            ${showTextFirst ? imageSide : textSide}
        </c:if>
    </mercury:padding-box>
</div><%----%>
<mercury:nl />

</mercury:image-vars>
</mercury:setting-defaults>

</c:when>

<c:when test="${cms.isEditMode}">
<%-- ###### No image: Offline version: Output warning ###### --%>
<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">
<mercury:nl />
<div class="element imageflip ${tileCss}"><%----%>
    <mercury:alert type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.page.noImage" />
        </jsp:attribute>
        <jsp:attribute name="text">
            <fmt:message key="msg.page.noImage.hint" />
        </jsp:attribute>
    </mercury:alert>
</div><%----%>
<mercury:nl />
</cms:bundle>
</c:when>

<c:otherwise>
<%-- ######  No image: Online version: Output nothing ###### --%>
<mercury:nl />
<div></div><%----%>
<mercury:nl />
</c:otherwise>

</c:choose>

</cms:bundle>
</cms:formatter>
</mercury:init-messages>

