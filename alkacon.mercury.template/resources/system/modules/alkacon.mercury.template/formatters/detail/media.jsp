<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<m:init-messages>

<cms:formatter var="content" val="value">

<m:setting-defaults>

<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="titleOption"            value="${setting.titleOption.toString}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showMediaCopyright"     value="${setting.showMediaCopyright.toBoolean}" />
<c:set var="autoPlay"               value="${setting.autoPlay.toBoolean}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<c:set var="date">
    <m:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat}" />
</c:set>
<c:set var="intro"                  value="${value.Intro}" />
<c:set var="title"                  value="${value.Title}" />
<c:set var="preface"                value="${value.Preface}" />
<c:set var="text"                   value="${value.Text}" />

<c:set var="showDate"               value="${not empty date}" />
<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="showText"               value="${setting.showText.toBoolean and text.isSet}" />
<c:set var="showTextDetailContent"  value="${showText and setting.showTextDetailContent.toBoolean}" />
<c:set var="showPrefaceAsSubtitle"  value="${false}" />
<c:set var="showPreface"            value="${not showPrefaceAsSubtitle and setting.showPreface.toBoolean}" />
<c:set var="showMediaTime"          value="${true}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50}" />
<c:set var="showIntro"              value="${titleOption ne 'none'}" />

<c:set var="isAudio"                value="${value.MediaContent.value.Audio.isSet}" />

<c:if test="${fn:contains(imageRatio, '#')}">
    <c:set var="maxImageSize" value="${fn:substringAfter(imageRatio, '#')}" />
    <c:set var="attrVisual">style="max-width:${maxImageSize}px;"</c:set>
    <c:set var="cssVisual" value="size-limited" />
    <c:set var="imageRatio" value="${fn:substringBefore(imageRatio, '#')}" />
</c:if>

<m:nl />
<div class="detail-page type-media ${isAudio ? 'audio ' : ''}layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
<m:nl />

<c:set var="keyPieceLayout"         value="${showOverlay ? 0 : keyPieceLayout}" />

<m:piece
    cssWrapper="detail-visual${setCssWrapperKeyPiece}"
    attrVisual="${attrVisual}"
    cssVisual="${cssVisual}"
    pieceLayout="${keyPieceLayout}"
    sizeDesktop="${(keyPieceLayout < 2 || keyPieceLayout == 10) ? 12 : 6}"
    sizeMobile="${12}">

    <jsp:attribute name="heading">
        <c:if test="${not showOverlay}">
            <m:intro-headline intro="${showIntro ? value.Intro : null}" headline="${title}" level="${hsize}" ade="${ade}"/>
            <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${showPreface and keyPieceLayout <= 1}" />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="visual">
        <m:key-visual-piece
            image="${image}"
            effect="${setEffect}"
            showOverlay="${showOverlay}"
            imageRatio="${imageRatio}"
            showImageSubtitle="${showImageSubtitle}"
            showImageZoom="${showImageZoom}"
            showImageCopyright="${showImageCopyright}"
            ade="${ade}">
            <jsp:attribute name="markupHeading">
                <m:intro-headline intro="${intro}" headline="${title}" level="${hsize}"/>
            </jsp:attribute>
            <jsp:attribute name="markupImage">
                <m:media-box
                    content="${content}"
                    effect="${setEffect}"
                    ratio="${imageRatio}"
                    hsize="${hsize}"
                    mediaDate="${showDate ? datePrefix.concat(date) : ''}"
                    showMediaTime="${showMediaTime}"
                    showTitleOverlay="${showOverlay}"
                    showPreface="${showPreface}"
                    showPrefaceAsSubtitle="${showPrefaceAsSubtitle}"
                    showCopyright="${showMediaCopyright}"
                    showIntro="${showIntro}"
                    autoPlay="${autoPlay}"
                />
            </jsp:attribute>
        </m:key-visual-piece>
    </jsp:attribute>

    <jsp:attribute name="text">
        <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${showPreface and not showOverlay and (keyPieceLayout > 1)}" />

        <c:if test="${showText and not showTextDetailContent}">
            <div class="detail-content" ${ade ? text.rdfaAttr : ''}><%----%>
                ${text}
            </div><%----%>
            <m:nl />
        </c:if>

    </jsp:attribute>

</m:piece>

<c:if test="${showTextDetailContent}">

    <div class="detail-content"><%----%>
        <m:section-piece
            cssWrapper="${setCssWrapperParagraphs}"
            pieceLayout="${1}"
            text="${text}"
            hsize="${hsize + 1}"
            ade="${ade}"
        />
    </div><%----%>
    <m:nl />

</c:if>

<m:container-attachment content="${content}" name="attachments" type="${containerType}" />

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:formatter>
</m:init-messages>