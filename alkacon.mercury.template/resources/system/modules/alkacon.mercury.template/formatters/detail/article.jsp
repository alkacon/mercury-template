<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="visualEffect"           value="${setting.effect.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showCombinedDownloads"  value="${setting.showCombinedDownloads.toBoolean}" />

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
<c:set var="image"                  value="${value.Image.value.Image.isSet ? value.Image : firstParagraph.value.Image}" />
<c:set var="author"                 value="${value.Author}" />

<c:set var="showAuthor"             value="${author.isSet and setting.showAuthor.toBoolean}" />
<c:set var="showDate"               value="${not empty date}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50}" />
<c:set var="keyPieceLayout"         value="${showOverlay ? 0 : keyPieceLayout}" />
<c:set var="ade"                    value="${true}" />

<mercury:nl />
<div class="detail-page type-article layout-${setting.keyPieceLayout.toInteger}${' '}${cssWrapper}"><%----%>
<mercury:nl />

<mercury:piece
    cssWrapper="detail-visual"
    pieceLayout="${keyPieceLayout}"
    allowEmptyBodyColumn="${true}"
    sizeDesktop="${keyPieceLayout > 1 ? 6 : 12}"
    sizeMobile="${12}">

    <jsp:attribute name="heading">
        <c:if test="${not showOverlay}">
            <mercury:intro-headline intro="${intro}" headline="${title}" level="${hsize}" ade="${ade}"/>
            <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPieceLayout == 0}" />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="visual">
        <mercury:key-visual-piece
            image="${image}"
            showOverlay="${showOverlay}"
            effect="${visualEffect}"
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
        <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${not showOverlay and (keyPieceLayout > 1)}" />

        <c:if test="${showDate or showAuthor}">
            <div class="visual-info ${not showAuthor ? 'right' : ''}"><%----%>
                <c:if test="${showDate}"><div class="info date"><div>${datePrefix}${date}</div></div></c:if>
                <c:if test="${showAuthor}"><div class="info person"><div ${author.rdfaAttr}>${author}</div></div></c:if>
            </div><%----%>
        </c:if>

        <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${showOverlay or (keyPieceLayout == 1)}" />
    </jsp:attribute>

</mercury:piece>

<c:if test="${not empty paragraphsContent or not empty paragraphsDownload}">

    <div class="detail-content"><%----%>
        <c:forEach var="paragraph" items="${paragraphsContent}" varStatus="status">
            <mercury:section-piece
                pieceLayout="${pieceLayout}"
                heading="${paragraph.value.Caption}"
                image="${(status.first and not value.Image.value.Image.isSet) ? null : paragraph.value.Image}"
                text="${paragraph.value.Text}"
                link="${paragraph.value.Link}"
                showImageZoom="${showImageZoom}"
                showImageSubtitle="${showImageSubtitle}"
                showImageCopyright="${showImageCopyright}"
                hsize="${hsize + 1}"
                ade="${ade}"
                emptyWarning="${not status.first}"
            />
        </c:forEach>
        <mercury:paragraph-downloads paragraphs="${paragraphsDownload}" hsize="${hsize + 1}" />
    </div><%----%>
    <mercury:nl />

</c:if>

<mercury:container-attachment content="${content}" name="attachments" />
<mercury:data-article content="${content}" />

</div><%----%>
<mercury:nl />

</mercury:paragraph-split>

</cms:formatter>

</mercury:init-messages>
