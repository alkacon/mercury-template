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

<c:set var="showLocation"           value="${setting.showLocation.toBoolean}" />
<c:set var="setShowMap"             value="${setting.showMap.toString eq 'onload' ? 'true' : (setting.showMap.toString eq 'onclick' ? 'onclick' : 'false')}" />
<c:set var="showType"               value="${setting.showType.toBoolean}" />
<c:set var="bookingOption"          value="${setting.bookingOption.toString}" />
<c:set var="performerOption"        value="${setting.performerOption.toString}" />
<c:set var="showiCalendar"          value="${setting.iCalendarShowLink.toBoolean}" />
<c:set var="showCosts"              value="${setting.showCosts.toBoolean and not empty content.valueList.Costs}" />

<c:set var="dateFormat"             value="${setting.dateFormat.toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />

<m:paragraph-split
    paragraphs="${content.valueList.Paragraph}"
    splitFirst="${false}"
    splitDownloads="${showCombinedDownloads}">

<m:location-vars data="${value.AddressChoice}" test="${showLocation}">

<c:set var="intro"                  value="${value.Intro}" />
<c:set var="title"                  value="${value.Title}" />
<c:set var="preface"                value="${value.Preface}" />
<c:set var="useVisualFromParagraph" value="${useVisualFromParagraph and not value.Image.value.Image.isSet and firstParagraph.value.Image.isSet}" />
<c:set var="image"                  value="${value.Image.value.Image.isSet ? value.Image : (useVisualFromParagraph ? firstParagraph.value.Image : null)}" />
<c:set var="locationNote"           value="${value.LocationNote}" />
<c:set var="type"                   value="${value.Type}" />
<c:set var="performer"              value="${value.Performer}" />

<c:set var="hasVirtualLocation"     value="${value.VirtualLocation.value.URI.isSet}" />
<c:set var="showLocation"           value="${showLocation and (not empty locData or locationNote.isSet or hasVirtualLocation)}" />
<c:set var="showMap"                value="${setShowMap ne 'false' and not hasVirtualLocation and value.AddressChoice.value.PoiLink.isSet}" />

<c:set var="showType"               value="${showType and type.isSet}" />
<c:set var="showPerformer"          value="${performerOption ne 'none'}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50}" />
<c:set var="seriesInfo"             value="${value.Dates.toDateSeries}" />
<c:set var="date">
    <m:instancedate date="${seriesInfo.instanceInfo.get(param.instancedate)}" format="${dateFormat}" />
</c:set>
<c:set var="showDate"               value="${not empty date}" />
<c:set var="ade"                    value="${cms.isEditMode and (empty cms.detailContentId or (not empty date) and (seriesInfo.isExtractedDate or seriesInfo.isSingleDate))}" />

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
    <c:when test="${showDate or showLocation or showType or showPerformer}">
        <c:set var="keyPieceInfoMarkup">
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
                <m:nl />
                <c:if test="${showLocation}">
                    <div class="info location"><%----%>
                        <span class="sr-only"><fmt:message key="msg.page.sr.location" /></span><%----%>
                        <div class="locdata"><%----%>
                            <c:if test="${hasVirtualLocation}">
                                    <div class="onlineInfo"><%----%>
                                    <m:link link="${value.VirtualLocation}" text="${value.VirtualLocation.value.URI.isSet ? value.VirtualLocation.value.URI.toLink : ''}" noExternalMarker="${true}" />
                                    </div><%----%>
                            </c:if>
                            <c:if test="${not empty locData}">
                                <c:if test="${not empty locData.name}">
                                    <div class="locname">${locData.name}</div><%----%>
                                </c:if>
                                <div class="address"><%----%>
                                    <div class="street"> ${locData.streetAddress}</div><%----%>
                                    <c:if test="${not empty locData.extendedAddress}">
                                        <div class="extended"> ${locData.extendedAddress}</div><%----%>
                                    </c:if>
                                    <div class="city"><%----%>
                                        <span class="code"> ${locData.postalCode}</span><%----%>
                                        <span class="locality"> ${locData.locality}</span><%----%>
                                    </div>
                                    <div class="region"><%----%>
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
                        <m:nl />
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
<div class="detail-page type-event layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
<m:nl />

<%-- Optional debug output generated from "detail-setting-defaults" plugin --%>
${settingDefaultsDebug}

<m:event-booking
    content="${content}"
    bookingOption="${bookingOption}"
    test="${seriesInfo.isExtractedDate or seriesInfo.isSingleDate}">

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

<c:if test="${showCosts}"><%----%>
    <div class="detail-content event-costs pivot"><%----%>

        <fmt:message key="msg.page.event.costs" var="costHeading" />
        <m:heading level="${hsize+1}" text="${costHeading}" css="ev-cost-heading" />

        <div class="cost-table"><%----%>
            <c:forEach var="costs" items="${content.valueList.Costs}">
                <div class="ct-category"><%----%>
                    <div class="ct-price"><%----%>
                        <c:set var="priceVal" value="${cms.wrap[fn:replace(costs.value.Price.toString, ',', '.')].toFloat}" />
                        <c:set var="currencyVal" value="${empty costs.value.Currency ? 'EUR' : costs.value.Currency}" />
                        <c:catch var ="formatException">
                            <fmt:formatNumber value="${priceVal}" currencyCode="${currencyVal}" type="currency" />
                        </c:catch>
                        <c:if test="${not empty formatException}">
                            <fmt:formatNumber value="${priceVal}" currencyCode="EUR" type="currency" />
                        </c:if>
                    </div><%----%>
                    <div class="ct-class"><%----%>
                        <c:out value="${costs.value.Label}" />
                    </div><%----%>
                    <c:if test="${costs.value.LinkToPaymentService.isSet}">
                        <div class="ct-link"><%----%>
                            <m:link link="${costs.value.LinkToPaymentService}" />
                        </div><%----%>
                    </c:if>
                </div><%----%>
            </c:forEach>
        </div><%----%>
    </div><%----%>
    <m:nl />
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

<c:if test="${showMap}">
    <m:nl/>
    <div class="detail-addition ser-poi"><%----%>
        <c:set var="params" value="${{
            'mapRatio': '16-9',
            'hsize': hsize+1,
            'showLocation': true,
            'showMap': setShowMap,
            'showDescription': false
        }}" />
        <m:display
            formatter="%(link.weak:/system/modules/alkacon.mercury.template/formatters/detail/poi.xml:08d2a739-0286-492b-a3d4-d302dd64d3f6)"
            file="${value.AddressChoice.value.PoiLink.stringValue}"
            settings="${params}"
        />
    </div><%----%>
    <m:nl/>
</c:if>

<c:if test="${showiCalendar}">
    <m:icalendar-vars content="${content}">
        <div class="detail-addition element pivot ical-link"><%----%>
            <a class="btn" download="${iCalFileName}" href="${iCalLink}">${iCalLabel}</a><%----%>
        </div><%----%>
    </m:icalendar-vars>
    <m:nl />
</c:if>

<m:container-attachment content="${content}" name="attachments" type="${containerType}" />

<c:if test="${showBookingForm}">
    <cms:include file="/system/modules/alkacon.mercury.webform/elements/webform-booking.jsp">
        <cms:param name="formInfo"      value="${content.value.Booking.value.Webform}" />
        <cms:param name="bookingInfo"   value="${content.id}" />
        <cms:param name="bookingOption" value="${bookingOption}" />
        <cms:param name="bookingFormId" value="${bookingFormId}" />
    </cms:include>
</c:if>

<m:data-event content="${content}" date="${value.Dates.toDateSeries.instanceInfo.get(param.instancedate)}" />

</m:event-booking>

</div><%----%>
<m:nl />

</m:location-vars>
</m:paragraph-split>

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
