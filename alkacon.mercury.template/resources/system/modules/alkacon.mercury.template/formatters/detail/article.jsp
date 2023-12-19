<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:if test="${not empty cms.plugins['detail-setting-defaults']}">
    <c:set var="defaultSettingOutput">
        <mercury:load-plugins group="detail-setting-defaults" type="jsp-nocache" />
    </c:set>
</c:if>

<mercury:setting-defaults>

<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="keyPieceSizeDesktop"    value="${setting.keyPieceSizeDesktop.useDefault('99').toInteger}" />
<c:set var="keyPiecePrefacePos"     value="${setting.keyPiecePrefacePos.toString}" />
<c:set var="keyPieceInfoPos"        value="${setting.keyPieceInfoPos.toString}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="pieceLayoutAlternating" value="${setting.pieceLayoutAlternating.toBoolean}" />
<c:set var="pieceLayoutSizeDesktop" value="${setting.pieceLayoutSizeDesktop.useDefault('99').toInteger}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="imageRatioParagraphs"   value="${setting.imageRatioParagraphs}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('m-element').toString}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showCombinedDownloads"  value="${setting.showCombinedDownloads.toBoolean}" />
<c:set var="useVisualFromParagraph" value="${setting.keyPieceOrigin.useDefault('subsitute').toString ne 'none'}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<mercury:paragraph-split
    paragraphs="${content.valueList.Paragraph}"
    splitFirst="${false}"
    splitDownloads="${showCombinedDownloads}">

<c:set var="date">
    <mercury:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat}" />
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

<c:set var="keyPiecePrefacePos"     value="${empty keyPiecePrefacePos ? ((showOverlay or (keyPieceLayout == 1)) ? 'bt' : (keyPieceLayout == 0 ? 'ih' : 'tt')) : keyPiecePrefacePos}" />
<c:set var="keyPieceInfoPos"        value="${empty keyPieceInfoPos ? 'it' : keyPieceInfoPos}" />

<%-- keyPiecePrefacePos options:    bt = bottom of text / tt = top of text   / ih = in header --%>
<%-- keyPieceInfoPos options:       ah = above heading  / bh = below heading / it = in text / ov = outside key visual --%>

<mercury:nl />
<div class="detail-page type-article layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
<mercury:nl />

${defaultSettingOutput}

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
                        <div ${author.rdfaAttr}>${author}</div><%----%>
                    </div><%----%>
                </c:if>
            </div><%----%>
        </c:set>
    </c:when>
    <c:otherwise>
        <c:set var="keyPieceInfoPos" value="${null}" />
    </c:otherwise>
</c:choose>

<mercury:piece
    cssWrapper="detail-visual${setCssWrapperKeyPiece}"
    pieceLayout="${keyPieceLayout}"
    allowEmptyBodyColumn="${image.isSet}"
    sizeDesktop="${keyPieceSizeDesktop != 99 ? keyPieceSizeDesktop : ((keyPieceLayout < 2 || keyPieceLayout == 10) ? 12 : 6)}"
    sizeMobile="${12}">

    <jsp:attribute name="heading">
        <c:if test="${not showOverlay}">
            <c:if test="${keyPieceInfoPos eq 'ah'}">${keyPieceInfoMarkup}</c:if>
            <mercury:intro-headline intro="${intro}" headline="${title}" level="${hsize}" ade="${ade}"/>
            <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'ih'}" />
            <c:if test="${keyPieceInfoPos eq 'bh'}">${keyPieceInfoMarkup}</c:if>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="visual">
        <mercury:key-visual-piece
            image="${image}"
            showOverlay="${showOverlay}"
            effect="${setEffect}"
            imageRatio="${imageRatio}"
            showImageSubtitle="${showImageSubtitle}"
            showImageZoom="${showImageZoom}"
            showImageCopyright="${showImageCopyright}"
            ade="${ade}">
            <jsp:attribute name="markupHeading">
                <mercury:intro-headline intro="${intro}" headline="${title}" level="${hsize}"/>
            </jsp:attribute>
        </mercury:key-visual-piece>
    </jsp:attribute>

    <jsp:attribute name="text">
        <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'tt'}" />
        <c:if test="${keyPieceInfoPos eq 'it'}">${keyPieceInfoMarkup}</c:if>
        <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'bt'}" />
    </jsp:attribute>

</mercury:piece>

<c:if test="${keyPieceInfoPos eq 'ov'}">
    <div class="pivot detail-visual-info">${keyPieceInfoMarkup}</div><%----%>
</c:if>

<c:if test="${not empty paragraphsContent or not empty paragraphsDownload}">
    <c:set var="pHsize" value="${hsize >= 0 ? hsize + 1 : (hsize >= -7 ? -1 * hsize : 0)}" />
    <div class="detail-content"><%----%>
        <mercury:paragraphs-alternating
            paragraphs="${paragraphsContent}"
            baseLayout="${pieceLayout}"
            layoutAlternating="${pieceLayoutAlternating}"
            skipFirstParagraphImage="${useVisualFromParagraph}">
            <mercury:section-piece
                cssWrapper="${setCssWrapperParagraphs}"
                pieceLayout="${paragraphLayout}"
                sizeDesktop="${pieceLayoutSizeDesktop}"
                sizeMobile="${12}"
                heading="${paragraph.value.Caption}"
                image="${status.first and useVisualFromParagraph ? null : paragraph.value.Image}"
                imageRatio="${imageRatioParagraphs}"
                text="${paragraph.value.Text}"
                link="${paragraph.value.Link}"
                showImageZoom="${showImageZoom}"
                showImageSubtitle="${showImageSubtitle}"
                showImageCopyright="${showImageCopyright}"
                hsize="${pHsize}"
                ade="${ade}"
                emptyWarning="${not status.first}"
            />
        </mercury:paragraphs-alternating>
        <mercury:paragraph-downloads paragraphs="${paragraphsDownload}" hsize="${hsize + 1}" />
    </div><%----%>
    <mercury:nl />

</c:if>

<mercury:container-attachment content="${content}" name="attachments" type="${containerType}" />
<mercury:data-article content="${content}" />

</div><%----%>
<mercury:nl />

</mercury:paragraph-split>

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
