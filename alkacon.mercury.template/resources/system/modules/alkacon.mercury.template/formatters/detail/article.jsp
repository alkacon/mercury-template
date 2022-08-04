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

<mercury:setting-defaults>

<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />
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
<c:set var="ade"                    value="${cms.isEditMode}" />

<mercury:nl />
<div class="detail-page type-article layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
<mercury:nl />

<c:set var="keyPieceLayout"         value="${showOverlay ? 0 : keyPieceLayout}" />

<mercury:piece
    cssWrapper="detail-visual${setCssWrapperKeyPiece}"
    pieceLayout="${keyPieceLayout}"
    allowEmptyBodyColumn="${image.isSet}"
    sizeDesktop="${(keyPieceLayout < 2 || keyPieceLayout == 10) ? 12 : 6}"
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
        <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${not showOverlay and (keyPieceLayout > 1)}" />

        <c:if test="${showDate or showAuthor}">
            <div class="visual-info ${not showAuthor ? 'right' : ''}"><%----%>
                <c:if test="${showDate}">
                    <div class="info date"><%----%>
                        <span class="sr-only"><fmt:message key="msg.page.sr.date" /></span><%----%>
                        <div>${datePrefix}${date}</div><%----%>
                    </div><%----%>
                </c:if>
                <c:if test="${showAuthor}">
                    <div class="info person"><%----%>
                        <span class="sr-only"><fmt:message key="msg.page.sr.by" /></span><%----%>
                        <c:choose>
                            <c:when test="${author.value.Name.isSet}">
                                <div ${author.value.Name.rdfaAttr}>${author.value.Name}</div><%----%>
                            </c:when>
                            <c:when test="${author.value.LinkToPerson.isSet}">
                                <c:set var="authorContent" value="${author.value.LinkToPerson.toResource.toXml}" />
                                <c:set var="authorName" value="${authorContent.value.Name.value}" />
                                <div><%--
                                --%>${authorName.Title.isSet ? authorName.Title.toString.concat(' ') : ''}<%--
                                --%>${authorName.FirstName.isSet ? authorName.FirstName.toString.concat(' ') : ''}<%-- 
                                --%>${authorName.MiddleName.isSet ? authorName.MiddleName.toString.concat(' ') : ''}<%--
                                --%>${authorName.LastName.isSet ? authorName.LastName.toString.concat(' ') : ''}<%--
                                --%>${authorName.Suffix.isSet ? authorName.Suffix.toString.concat(' ') : ''}<%--
                            --%></div><%----%>
                            </c:when>
                        </c:choose>
                    </div><%----%>
                </c:if>
            </div><%----%>
        </c:if>

        <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${showOverlay or (keyPieceLayout == 1)}" />
    </jsp:attribute>

</mercury:piece>

<c:if test="${not empty paragraphsContent or not empty paragraphsDownload}">

    <div class="detail-content"><%----%>
        <c:forEach var="paragraph" items="${paragraphsContent}" varStatus="status">
            <mercury:section-piece
                cssWrapper="${setCssWrapperParagraphs}"
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

<mercury:container-attachment content="${content}" name="attachments" type="${containerType}" />
<mercury:data-article content="${content}" />

</div><%----%>
<mercury:nl />

</mercury:paragraph-split>

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
