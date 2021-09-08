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

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="visualEffect"           value="${setting.effect.toString}" />
<c:set var="bookingOption"          value="${setting.bookingOption.toString}" />
<c:set var="performerOption"        value="${setting.performerOption.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="imageRatio"             value="${setting.imageRatio}" />
<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />
<c:set var="showLocation"           value="${setting.showLocation.toBoolean}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showCombinedDownloads"  value="${setting.showCombinedDownloads.toBoolean}" />
<c:set var="showiCalendar"          value="${setting.iCalendarShowLink.toBoolean}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<mercury:paragraph-split
    paragraphs="${content.valueList.Paragraph}"
    splitFirst="${false}"
    splitDownloads="${showCombinedDownloads}">

<mercury:location-vars data="${value.AddressChoice}" test="${showLocation}">

<c:set var="intro"                  value="${value.Intro}" />
<c:set var="title"                  value="${value.Title}" />
<c:set var="preface"                value="${value.Preface}" />
<c:set var="image"                  value="${value.Image.value.Image.isSet ? value.Image : firstParagraph.value.Image}" />
<c:set var="locationNote"           value="${value.LocationNote}" />
<c:set var="type"                   value="${value.Type}" />
<c:set var="performer"              value="${value.Performer}" />

<c:set var="showLocation"           value="${showLocation and (not empty locData or locationNote.isSet)}" />
<c:set var="showType"               value="${type.isSet}" />
<c:set var="showPerformer"          value="${performerOption ne 'none'}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50}" />
<c:set var="keyPieceLayout"         value="${showOverlay ? 0 : keyPieceLayout}" />
<c:set var="seriesInfo"             value="${value.Dates.toDateSeries}" />
<c:set var="date">
    <mercury:instancedate date="${seriesInfo.instanceInfo.get(param.instancedate)}" format="${dateFormat}" />
</c:set>
<c:set var="showDate"               value="${not empty date}" />
<c:set var="ade"                    value="${cms.isEditMode and (empty cms.detailContentId or (not empty date) and (seriesInfo.isExtractedDate or seriesInfo.isSingleDate))}" />

<mercury:nl />
<div class="detail-page type-event layout-${setting.keyPieceLayout.toInteger}${' '}${cssWrapper}"><%----%>
<mercury:nl />

<mercury:event-booking
    content="${content}"
    bookingOption="${bookingOption}"
    test="${seriesInfo.isExtractedDate or seriesInfo.isSingleDate}">

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

            <c:if test="${showDate or showLocation or showType or showPerformer}">
                <c:if test="${showPerformer}">
                    <c:choose>
                        <c:when test="${value.Performer.isSet}">
                            <c:set var="performer" value="${value.Performer.toString}" />
                            <c:set var="showPerformer" value="${performer ne 'none'}" />
                        </c:when>
                        <c:when test="${performerOption eq 'sitename'}">
                            <c:set var="sourceSite" value="${cms.vfs.readSubsiteFor(cms.element.sitePath)}" />
                            <c:set var="sourceSiteProps" value="${cms.vfs.readProperties[sourceSite]}" />
                            <c:set var="performer" value="${not empty sourceSiteProps['mercury.sitename'] ? sourceSiteProps['mercury.sitename'] : sourceSiteProps['Title'] }" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="showPerformer" value="${false}" />
                        </c:otherwise>
                    </c:choose>
                </c:if>
                <div class="visual-info ${not showLocation ? 'right' : ''}"><%----%>
                    <div class="infogroup">
                        <c:if test="${showDate}">
                            <div class="info date"><%----%>
                                <span class="sr-only"><fmt:message key="msg.page.sr.date" /></span><%----%>
                                <div>${datePrefix}${date}</div><%----%>
                            </div><%----%>
                        </c:if>
                        <c:if test="${showType}">
                            <div class="info type"><%----%>
                                <span class="sr-only"><fmt:message key="msg.page.sr.type" /></span><%----%>
                                <div>${type}</div><%----%>
                            </div><%----%>
                        </c:if>
                        <c:if test="${showPerformer}">
                            <div class="info person"><%----%>
                                <span class="sr-only"><fmt:message key="msg.page.sr.by" /></span><%----%>
                                <div ${value.Performer.isSet ? value.Performer.rdfaAttr : ''}>${performer}</div><%----%>
                            </div><%----%>
                        </c:if>
                    </div><%----%>
                    <mercury:nl />
                    <c:if test="${showLocation}">
                        <div class="info location"><%----%>
                            <span class="sr-only"><fmt:message key="msg.page.sr.location" /></span><%----%>
                            <div class="locdata"><%----%>
                            <c:if test="${not empty locData}">
                                <c:if test="${not empty locData.name}">
                                    <div class="locname">${locData.name}</div><%----%>
                                </c:if>
                                <div class="address">
                                    <div class="street"> ${locData.streetAddress}</div><%----%>
                                    <c:if test="${not empty locData.extendedAddress}">
                                        <div class="extended"> ${locData.extendedAddress}</div><%----%>
                                    </c:if>
                                    <div class="city">
                                        <span class="code"> ${locData.postalCode}</span><%----%>
                                        <span class="locality"> ${locData.locality}</span><%----%>
                                    </div>
                                    <div class="region">
                                        <c:if test="${not empty locData.region}">
                                            <span class="region"> ${locData.region}</span><%----%>
                                        </c:if>
                                        <c:if test="${not empty locData.country}">
                                            <span class="country"> ${locData.country}</span><%----%>
                                        </c:if>
                                    </div><%----%>
                                </div><%----%>
                            </c:if>
                            <c:if test="${locationNote.isSet}">
                                <div class="adressInfo" ${ade ? loocationNote.rdfaAttr : ''}>${locationNote}</div><%----%>
                            </c:if>
                            </div><%----%>
                            <mercury:nl />
                        </div><%----%>
                    </c:if>
                </div><%----%>
            </c:if>

            <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${showOverlay or (keyPieceLayout == 1)}" />
        </jsp:attribute>

    </mercury:piece>

    <c:if test="${not empty paragraphsContent or not empty paragraphsDownload or showiCalendar}">
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

    <c:if test="${showiCalendar}">
        <div class="detail-addition element ical-link"><%----%>
            <a class="btn" download="${fn:escapeXml(fn:replace(value.Title, '\"', ''))}"<%--
            --%>href="<cms:link>/system/modules/alkacon.mercury.template/elements/event.ics<%--
                --%>?id=${cms.element.id}<%--
                --%>&instancedate=${param.instancedate}<%--
                --%>&url=<cms:link>${content.file.rootPath}</cms:link><%--
                --%>&__locale=${cms.locale}<%--
            --%></cms:link>"><%----%>
                <fmt:message key="msg.page.icalendar" />
            </a><%----%>
        </div><%----%>
        <mercury:nl />
    </c:if>

    <mercury:container-attachment content="${content}" name="attachments" type="${containerType}" />

    <c:if test="${showBookingForm}">
        <cms:include file="/system/modules/alkacon.mercury.webform/elements/webform-booking.jsp">
            <cms:param name="formInfo"      value="${content.value.Booking.value.Webform}" />
            <cms:param name="bookingInfo"   value="${content.id}" />
            <cms:param name="bookingOption" value="${bookingOption}" />
            <cms:param name="bookingFormId" value="${bookingFormId}" />
        </cms:include>
    </c:if>

    <mercury:data-event content="${content}" date="${value.Dates.toDateSeries.instanceInfo.get(param.instancedate)}" />

</mercury:event-booking>

</div><%----%>
<mercury:nl />

</mercury:location-vars>
</mercury:paragraph-split>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>
