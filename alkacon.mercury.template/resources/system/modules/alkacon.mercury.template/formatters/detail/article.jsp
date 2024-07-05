<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams replaceInvalid="bad_param" />
<m:init-messages>

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:load-plugins group="detail-setting-defaults" type="jsp-nocache" />

<m:setting-defaults>

<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="keyPieceSizeDesktop"    value="${setting.keyPieceSizeDesktop.useDefault('99').toInteger}" />
<c:set var="keyPiecePrefacePos"     value="${setting.keyPiecePrefacePos.toString}" />
<c:set var="keyPieceInfoPos"        value="${setting.keyPieceInfoPos.toString}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="pieceLayoutAlternating" value="${setting.pieceLayoutAlternating.toBoolean}" />
<c:set var="pieceLayoutSizeDesktop" value="${setting.pieceLayoutSizeDesktop.useDefault('99').toInteger}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="imageRatioLg"           value="${setting.imageRatioLg}" />
<c:set var="imageRatioParagraphs"   value="${setting.imageRatioParagraphs}" />
<c:set var="imageRatioParagraphsLg" value="${setting.imageRatioParagraphsLg}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('m-element').toString}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showCombinedDownloads"  value="${setting.showCombinedDownloads.toBoolean}" />
<c:set var="useVisualFromParagraph" value="${setting.keyPieceOrigin.useDefault('subsitute').toString ne 'none'}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<m:paragraph-split
    paragraphs="${content.valueList.Paragraph}"
    splitFirst="${false}"
    splitDownloads="${showCombinedDownloads}">

<c:set var="date">
    <m:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat}" />
</c:set>
<c:set var="intro"                  value="${value.Intro}" />
<c:set var="title"                  value="${value.Title}" />
<c:set var="preface"                value="${value.Preface}" />
<c:set var="useVisualFromParagraph" value="${useVisualFromParagraph and not value.Image.value.Image.isSet and firstParagraph.value.Image.isSet}" />
<c:set var="image"                  value="${value.Image.value.Image.isSet ? value.Image : (useVisualFromParagraph ? firstParagraph.value.Image : null)}" />
<c:set var="author"                 value="${value.Author}" />

<c:set var="showAuthor"             value="${author.isSet and setting.showAuthor.toBoolean}" />
<c:set var="showDate"               value="${not empty date}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50}" />
<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="keyPieceLayout"         value="${showOverlay ? 0 : keyPieceLayout}" />
<c:if test="${empty image}">
    <c:choose>
        <c:when test="${(keyPieceLayout >= 2) and (keyPieceLayout <= 5)}">
            <c:set var="keyPieceLayout"  value="${0}" />
        </c:when>
        <c:when test="${(keyPieceLayout >= 6) and (keyPieceLayout <= 9)}">
            <c:set var="keyPieceLayout"  value="${1}" />
        </c:when>
    </c:choose>
</c:if>

<c:set var="keyPiecePrefacePos"     value="${empty keyPiecePrefacePos ? ((showOverlay or (keyPieceLayout == 1)) ? 'bt' : (keyPieceLayout == 0 ? 'ih' : 'tt')) : keyPiecePrefacePos}" />
<c:set var="keyPieceInfoPos"        value="${empty keyPieceInfoPos ? 'it' : keyPieceInfoPos}" />

<%-- keyPiecePrefacePos options:    bt = bottom of text / tt = top of text   / ih = in header --%>
<%-- keyPieceInfoPos options:       ah = above heading  / bh = below heading / it = in text / ov = outside key visual --%>

<c:choose>
    <c:when test="${showDate or showAuthor}">
        <c:set var="keyPieceInfoMarkup">
            <div class="visual-info ${not showAuthor ? 'right date-only' : ''}"><%----%>
                <c:if test="${showDate}">
                    <div class="info date"><%----%>
                        <span class="sr-only"><fmt:message key="msg.page.sr.date" /></span><%----%>
                        <div>${datePrefix}${date}</div><%----%>
                    </div><%----%>
                </c:if>
                <c:if test="${showAuthor}">
                    <div class="info person"><%----%>
                        <span class="sr-only"><fmt:message key="msg.page.sr.by" /></span><%----%>
                        <div ${author.rdfaAttr}><m:out value="${author}" lenientEscaping="${true}" /></div><%----%>
                    </div><%----%>
                </c:if>
            </div><%----%>
        </c:set>
    </c:when>
    <c:otherwise>
        <c:set var="keyPieceInfoPos" value="${null}" />
    </c:otherwise>
</c:choose>

<m:nl />
<div class="detail-page type-article layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
<m:nl />

<%-- Optional debug output generated from "detail-setting-defaults" plugin --%>
${settingDefaultsDebug}

<m:piece
    cssWrapper="detail-visual${setCssWrapperKeyPiece}"
    pieceLayout="${keyPieceLayout}"
    allowEmptyBodyColumn="${not empty image}"
    sizeDesktop="${keyPieceSizeDesktop != 99 ? keyPieceSizeDesktop : ((keyPieceLayout < 2 || keyPieceLayout == 10) ? 12 : 6)}"
    sizeMobile="${12}">

    <jsp:attribute name="heading">
        <c:if test="${not showOverlay}">
            <c:if test="${keyPieceInfoPos eq 'ah'}">${keyPieceInfoMarkup}</c:if>
            <m:intro-headline intro="${intro}" headline="${title}" level="${hsize}" ade="${ade}"/>
            <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'ih'}" />
            <c:if test="${keyPieceInfoPos eq 'bh'}">${keyPieceInfoMarkup}</c:if>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="visual">
        <m:key-visual-piece
            image="${image}"
            showOverlay="${showOverlay}"
            effect="${setEffect}"
            imageRatio="${imageRatio}"
            imageRatioLg="${imageRatioLg}"
            showImageSubtitle="${showImageSubtitle}"
            showImageZoom="${showImageZoom}"
            showImageCopyright="${showImageCopyright}"
            ade="${ade}">
            <jsp:attribute name="markupHeading">
                <m:intro-headline intro="${intro}" headline="${title}" level="${hsize}"/>
            </jsp:attribute>
        </m:key-visual-piece>
    </jsp:attribute>

    <jsp:attribute name="text">
        <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'tt'}" />
        <c:if test="${keyPieceInfoPos eq 'it'}">${keyPieceInfoMarkup}</c:if>
        <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'bt'}" />
    </jsp:attribute>

</m:piece>

<c:if test="${keyPieceInfoPos eq 'ov'}">
    <div class="pivot detail-visual-info">${keyPieceInfoMarkup}</div><%----%>
</c:if>

<c:if test="${not empty paragraphsContent or not empty paragraphsDownload}">
    <c:set var="pHsize" value="${hsize >= 0 ? hsize + 1 : (hsize >= -7 ? -1 * hsize : 0)}" />
    <div class="detail-content"><%----%>
        <m:paragraphs-alternating
            paragraphs="${paragraphsContent}"
            baseLayout="${pieceLayout}"
            layoutAlternating="${pieceLayoutAlternating}"
            skipFirstParagraphImage="${useVisualFromParagraph}">
            <m:section-piece
                cssWrapper="${setCssWrapperParagraphs}"
                pieceLayout="${paragraphLayout}"
                sizeDesktop="${pieceLayoutSizeDesktop}"
                sizeMobile="${12}"
                heading="${paragraph.value.Caption}"
                image="${status.first and useVisualFromParagraph ? null : paragraph.value.Image}"
                imageRatio="${imageRatioParagraphs}"
                imageRatioLg="${imageRatioParagraphsLg}"
                text="${paragraph.value.Text}"
                link="${paragraph.value.Link}"
                showImageZoom="${showImageZoom}"
                showImageSubtitle="${showImageSubtitle}"
                showImageCopyright="${showImageCopyright}"
                hsize="${pHsize}"
                ade="${ade}"
                emptyWarning="${not status.first}"
            />
        </m:paragraphs-alternating>
        <m:paragraph-downloads paragraphs="${paragraphsDownload}" hsize="${hsize + 1}" />
    </div><%----%>
    <m:nl />

</c:if>

<m:container-attachment content="${content}" name="attachments" type="${containerType}" />
<m:data-article content="${content}" />

</div><%----%>
<m:nl />

</m:paragraph-split>

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
