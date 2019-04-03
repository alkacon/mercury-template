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
    <c:set var="tileCssWrapper"     value="${empty param.tilegrid ? 'tile-col col-sm-6 col-md-4 col-lg-3' : param.tilegrid}" />
</c:if>

<mercury:init-messages reload="${isTile}" css="${tileCssWrapper}">

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:choose>
<c:when test="${value.Image.isSet}">

<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="ratio"                  value="${setting.imageRatio.toString}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showTextFirst"          value="${setting.showTextFirst.toBoolean}" />
<c:set var="doNotFlip"              value="${setting.doNotFlip.toBoolean}" />
<c:set var="flipColor"              value="${setting.flipColor.toString}" />
<c:set var="effect"                 value="${setting.effect.toString != 'none' ? setting.effect.toString : ''}" />

<c:set var="title"                  value="${value.Title.toString}" />

<mercury:image-vars
    image="${value.Image}"
    ratio="${ratio}"
    title="${title}"
    ade="${false}">

<c:set var="imageSide">
    <div class="image-section ${showTextFirst ? 'back' : 'front'}${doNotFlip and (not showTextFirst) ? ' noflip' : ''}">
        <mercury:image-srcset
            imagebean="${imageBean}"
            cssWrapper="img-responsive"
            alt="${title}"
        />
        <c:if test="${showImageCopyright and not empty imageCopyrightHtml}">
            <div class="copyright">
                <div class="text">${imageCopyrightHtml}</div>
            </div>
        </c:if>
    </div>
</c:set>

<c:set var="textSide">
    <div class="text-section ${showTextFirst ? 'front' : 'back'}${doNotFlip and showTextFirst ? ' noflip' : ''}">

        <mercury:heading level="${hsize}" text="${title}" css="imageflip-title" />

        <div class="imageflip-text">
            ${value.Text}
        </div>

        <c:if test="${value.Link.exists and value.Link.value.URI.isSet}">
            <mercury:link link="${value.Link}" css="btn btn-sm" setTitle="false"/>
        </c:if>

    </div>
</c:set>

<div class="element imageflip ${tileCssWrapper}${' '}${effect}${' '}${flipColor}${' '}${cssWrapper}" ontouchstart="this.classList.toggle('hover');">
    <mercury:padding-box ratio="${ratio}" cssWrapper="flipper">
        ${showTextFirst ? textSide : imageSide}
        <c:if test="${not doNotFlip}">
            ${showTextFirst ? imageSide : textSide}
        </c:if>
    </mercury:padding-box>
</div>

</mercury:image-vars>

</c:when>
<c:when test="${cms.isEditMode}">
<%-- ###### No image: Offline version: Output warning ###### --%>

<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<div class="element imageflip ${tileCssWrapper}">
    <mercury:alert type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.page.noImage" />
        </jsp:attribute>
        <jsp:attribute name="text">
            <fmt:message key="msg.page.noImage.hint" />
        </jsp:attribute>
    </mercury:alert>
</div>

</cms:bundle>

</c:when>
<c:otherwise>
<%-- ######  No image: Online version: Output nothing ###### --%>

<div></div>

</c:otherwise>
</c:choose>

</cms:bundle>

</cms:formatter>
</mercury:init-messages>

