<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="preview"                value="${empty pageContext.request.getAttribute('ATTR_TEMPLATE_BEAN')}" />

<cms:secureparams replaceInvalid="bad_param" />
<m:init-messages>

<cms:formatter var="content" val="value" rdfa="rdfa">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:load-plugins group="detail-setting-defaults" type="jsp-nocache" />

<m:setting-defaults>

<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="keyPieceSizeDesktop"    value="${setting.keyPieceSizeDesktop.useDefault('99').toInteger}" />
<c:set var="keyPiecePrefacePos"     value="${setting.keyPiecePrefacePos.toString}" />
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
<c:set var="showLocation"           value="${value.Address.isSet and setting.showLocation.toBoolean}" />
<c:set var="showFacilities"         value="${value.Facilities.isSet and setting.showFacilities.toBoolean}" />
<c:set var="showOpeningHours"       value="${setting.showOpeningHours.toBoolean}" />
<c:set var="setShowMap"             value="${setting.showMap.toString eq 'onload' ? 'true' : (setting.showMap.toString eq 'onclick' ? 'onclick' : 'false')}" />
<c:set var="showMap"                value="${setShowMap eq 'true' or param.showmap ne null}" />
<c:set var="showMapOnClick"         value="${setting.showMap.toString eq 'onclick'}" />
<c:set var="mapRatio"               value="${setting.mapRatio.toString}" />
<c:set var="mapZoom"                value="${setting.mapZoom.toString}" />


<c:choose>
<c:when test="${value.Paragraph.isSet and value.Paragraph.value.Text.isSet}">

<m:paragraph-split
    paragraphs="${content.valueList.Paragraph}"
    splitFirst="${true}"
    splitDownloads="${showCombinedDownloads}">

<c:set var="intro"                  value="${value.Intro}" />
<c:set var="title"                  value="${value.Title}" />
<c:set var="preface"                value="${not empty firstParagraph.value.Text ? cms:stripHtml(firstParagraph.value.Text) : null}" />
<c:set var="useVisualFromParagraph" value="${firstParagraph.value.Image.isSet}" />
<c:set var="image"                  value="${firstParagraph.value.Image.isSet ? firstParagraph.value.Image : null}" />
<c:set var="openingHours"           value="${value.OpeningHours}" />
<c:set var="showOverlay"            value="${keyPieceLayout == 50 and image.isSet}" />
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

<c:if test="${showMapOnClick and value.Coord.isSet}">
    <c:set var="poiId"><m:idgen prefix='poi' uuid='${cms.element.id}' /></c:set>
    <c:choose>
        <c:when test="${param.showmap == null}">
            <c:set var="mapLinkMarkup">
                <c:set var="pageLink" value="${cms.detailRequest ? cms.detailContent.sitePath : cms.requestContext.uri}" />
                <c:set var="queryString"><c:out value="${pageContext.request.queryString}" /></c:set>
                <a class="btn" href="${cms.wrap[pageLink].toLink}?${queryString}${empty queryString ? '' : '&'}showmap#${poiId}" data-bs-toggle="map"><%----%>
                    <fmt:message key="msg.page.poi.showmap" />
                </a><%----%>
            </c:set>
        </c:when>
        <c:otherwise>
            <c:set var="showMap" value="${true}" />
        </c:otherwise>
    </c:choose>
</c:if>

<m:nl />
<div class="detail-page type-poi layout-${keyPieceLayout}${setCssWrapper123}"><%----%>
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
            <m:intro-headline intro="${intro}" headline="${title}" level="${hsize}" ade="${ade}"/>
            <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}" test="${keyPiecePrefacePos eq 'tt' and keyPieceLayout < 4}" />
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
        <m:heading text="${preface}" level="${7}" css="sub-header" ade="${ade}"
            test="${keyPiecePrefacePos eq 'ih' or keyPiecePrefacePos eq 'bt' or showOverlay or (keyPiecePrefacePos eq 'tt' and keyPieceLayout >= 4)}" />
    </jsp:attribute>

</m:piece>

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
                image="${paragraph.value.Image}"
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

</m:paragraph-split>

<c:if test="${showLocation}">
    <div class="adr detail-content"><%----%>
        <fmt:message key="msg.page.address" var="addressHeading" />
        <m:heading level="${hsize+1}" text="${addressHeading}" css="address-heading" />
        <div class="street-address" ${value.Address.value.StreetAddress.rdfaAttr}>${value.Address.value.StreetAddress}</div><%----%>
        <c:if test="${value.Address.value.ExtendedAddress.isSet}">
            <div class="extended-address" ${value.Address.value.ExtendedAddress.rdfaAttr}>${value.Address.value.ExtendedAddress}</div><%----%>
        </c:if>
        <div><%----%>
            <span class="postal-code" ${value.Address.value.PostalCode.rdfaAttr}>${value.Address.value.PostalCode}</span>${' '}<%----%>
            <span class="locality" ${value.Address.value.Locality.rdfaAttr}>${value.Address.value.Locality}</span><%----%>
        </div><%----%>
        <c:if test="${value.Address.value.Region.isSet or value.Address.value.Country.isSet}">
            <div><%----%>
                <c:if test="${value.Address.value.Region.isSet}">
                    <span class="region" ${value.Address.value.Region.rdfaAttr}>${value.Address.value.Region}</span>${' '}<%----%>
                </c:if>
                <c:if test="${value.Address.value.Country.isSet}">
                    <span class="country-name" ${value.Address.value.Country.rdfaAttr}>${value.Address.value.Country}</span><%----%>
                </c:if>
            </div><%----%>
        </c:if>
    </div><%----%>
    <m:nl />
</c:if>

<c:if test="${showOpeningHours and openingHours.isSet}"><%----%>
    <div class="detail-content"><%----%>
        <fmt:message key="msg.page.openingHours" var="hoursHeading" />
        <m:heading level="${hsize+1}" text="${hoursHeading}" css="hours-heading" />
        <m:opening-hours content="${value.OpeningHours}" />
    </div><%----%>
    <m:nl />
</c:if>

<c:if test="${showFacilities}">
    <div class="detail-content"><%----%>
        <fmt:message key="msg.page.facilities" var="facilitiesHeading" />
        <m:heading level="${hsize+1}" text="${facilitiesHeading}" css="facilities-heading" />
        <m:facility-icons
            useTooltip="${true}"
            wheelchairAccess="${value.Facilities.value.WheelchairAccess.toBoolean}"
            hearingImpaired="${value.Facilities.value.HearingImpaired.toBoolean}"
            lowVision="${value.Facilities.value.LowVision.toBoolean}"
            publicRestrooms="${value.Facilities.value.PublicRestrooms.toBoolean}"
            publicRestroomsAccessible="${value.Facilities.value.PublicRestroomsAccessible.toBoolean}"
        />
    </div><%----%>
    <m:nl />
</c:if>

<m:piece
    cssWrapper="detail-content ${setCssWrapperKeyPiece}"
    attrWrapper="${empty poiId ? '' : ' '.concat('id=\"').concat(poiId).concat('\"')}"
    pieceLayout="${2}"
    allowEmptyBodyColumn="${true}"
    sizeDesktop="${12}"
    sizeMobile="${12}">

    <jsp:attribute name="visual">
        <c:if test="${showMap and not preview and value.Coord.isSet}">
            <c:set var="id"><m:idgen prefix='poimap' uuid='${cms.element.instanceId}' /></c:set>
            <m:location-vars data="${content}" addMapInfo="true" >
                <m:map
                    provider="auto"
                    id="${id}"
                    ratio="${mapRatio}"
                    zoom="${mapZoom}"
                    markers="${[locData]}"
                    subelementWrapper="poi-map"
                    showFacilities="${true}"
                    showLink="${true}"
                />
            </m:location-vars>
            <m:nl />
        </c:if>

        <m:alert test="${cms.isEditMode and showMap and not value.Coord.isSet}" type="warning">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.poi.nomap" />
            </jsp:attribute>
        </m:alert>
    </jsp:attribute>

    <jsp:attribute name="heading" />

    <jsp:attribute name="link">
        ${mapLinkMarkup}
    </jsp:attribute>

</m:piece>


<m:container-attachment content="${content}" name="attachments" type="${containerType}" cssWrapper="subelement"/>
<m:nl />


</div><%----%>
<m:nl />

</c:when>
<c:otherwise>
    <cms:simpledisplay formatterKey="m/detail/poi" value="${content.filename}" />
</c:otherwise>
</c:choose>

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>
