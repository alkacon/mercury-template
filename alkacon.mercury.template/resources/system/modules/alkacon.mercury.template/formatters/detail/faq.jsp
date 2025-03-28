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

<m:setting-defaults>

<c:set var="keyPieceWrapper"        value="${setting.keyPieceWrapper.isSetNotNone ? 'detail-visual '.concat(setting.keyPieceWrapper) : 'detail-visual'}" />
<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="imageRatioLg"           value="${setting.imageRatioLg}" />
<c:set var="imageRatioParagraphs"   value="${setting.imageRatioParagraphs}" />
<c:set var="imageRatioParagraphsXs" value="${setting.imageRatioParagraphsXs}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('m-element').toString}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showCombinedDownloads"  value="${setting.showCombinedDownloads.toBoolean}" />
<c:set var="hideVisual"             value="${setting.keyPieceOrigin.toString eq 'hide'}" />
<c:set var="useVisualFromParagraph" value="${not hideVisual and (setting.keyPieceOrigin.useDefault('subsitute').toString ne 'none')}" />


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
<c:set var="title"                  value="${value.Question}" />
<c:set var="image"                  value="${useVisualFromParagraph ? firstParagraph.value.Image : null}" />
<c:set var="link"                   value="${firstParagraph.value.Link}" />

<c:set var="showDate"               value="${not empty date}" />
<c:set var="ade"                    value="${cms.isEditMode}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50}" />

<m:nl />
<div class="detail-page type-faq layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
<m:nl />

<c:set var="keyPieceLayout"         value="${showOverlay ? 0 : keyPieceLayout}" />

<m:piece
    cssWrapper="detail-visual${setCssWrapperKeyPiece}"
    pieceLayout="${keyPieceLayout}"
    allowEmptyBodyColumn="${image.isSet}"
    sizeDesktop="${(keyPieceLayout < 2 || keyPieceLayout == 10) ? 12 : 6}"
    sizeMobile="${12}">

    <jsp:attribute name="heading">
        <c:if test="${not showOverlay}">
            <m:intro-headline intro="${intro}" headline="${title}" level="${hsize}" ade="${ade}"/>
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
        <c:if test="${showDate}">
            <div class="visual-info right"><%----%>
                <div class="info date"><%----%>
                    <span class="sr-only"><fmt:message key="msg.page.sr.date" /></span><%----%>
                    <div>${datePrefix}${date}</div><%----%>
                </div><%----%>
            </div><%----%>
        </c:if>
    </jsp:attribute>

</m:piece>

<c:if test="${not empty paragraphsContent or not empty paragraphsDownload}">
    <c:set var="pHsize" value="${hsize >= 0 ? hsize + 1 : (hsize >= -7 ? -1 * hsize : 0)}" />
    <div class="detail-content"><%----%>
        <c:forEach var="paragraph" items="${paragraphsContent}" varStatus="status">
            <m:section-piece
                cssWrapper="${setCssWrapperParagraphs}"
                pieceLayout="${pieceLayout}"
                heading="${paragraph.value.Caption}"
                image="${status.first and useVisualFromParagraph ? null : paragraph.value.Image}"
                imageRatio="${imageRatioParagraphs}"
                imageRatioLg="${imageRatioParagraphsXs}"
                text="${paragraph.value.Text}"
                link="${paragraph.value.Link}"
                showImageZoom="${showImageZoom}"
                showImageSubtitle="${showImageSubtitle}"
                showImageCopyright="${showImageCopyright}"
                hsize="${pHsize}"
                ade="${ade}"
                emptyWarning="${not status.first}"
            />
        </c:forEach>
        <m:paragraph-downloads paragraphs="${paragraphsDownload}" hsize="${hsize + 1}" />
    </div><%----%>
    <m:nl />

</c:if>

<m:container-attachment content="${content}" name="attachments" type="${containerType}" />

</div><%----%>
<m:nl />

</m:paragraph-split>

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
