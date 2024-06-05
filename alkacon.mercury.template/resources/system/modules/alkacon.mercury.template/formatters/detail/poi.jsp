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
<m:init-messages reload="${param.showmap ne null and not preview}">

<cms:formatter var="content" val="value" rdfa="rdfa">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="keyPieceLayout"         value="${setting.keyPieceLayout.toInteger}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="showMap"                value="${setting.showMap.toBoolean}" />
<c:set var="showMapOnClick"         value="${setting.showMap.toString eq 'onclick'}" />
<c:set var="mapRatio"               value="${setting.mapRatio.toString}" />
<c:set var="mapZoom"                value="${setting.mapZoom.toString}" />
<c:set var="showLocation"           value="${value.Address.isSet and setting.showLocation.toBoolean}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showFacilities"         value="${setting.showFacilities.toBoolean}" />
<c:set var="showOpeningHours"       value="${setting.showOpeningHours.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />

<c:set var="ade"                    value="${cms.isEditMode}" />

<c:set var="openingHours"           value="${value.OpeningHours}" />

<c:if test="${showFacilities and value.Facilities.isSet}">
    <c:set var="accessibleFacilities">
        <m:facility-icons
            useTooltip="${true}"
            wheelchairAccess="${value.Facilities.value.WheelchairAccess.toBoolean}"
            hearingImpaired="${value.Facilities.value.HearingImpaired.toBoolean}"
            lowVision="${value.Facilities.value.LowVision.toBoolean}"
            publicRestrooms="${value.Facilities.value.PublicRestrooms.toBoolean}"
            publicRestroomsAccessible="${value.Facilities.value.PublicRestroomsAccessible.toBoolean}"
        />
    </c:set>
</c:if>

<c:if test="${showMapOnClick and value.Coord.isSet}">
    <c:set var="poiId"><m:idgen prefix='poi' uuid='${cms.element.id}' /></c:set>
    <c:choose>
        <c:when test="${param.showmap == null}">
            <c:set var="linkMarkup">
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
<div class="detail-page type-poi layout-${keyPieceLayout}${setCssWrapper123}"${empty poiId ? '' : ' '.concat('id=\"').concat(poiId).concat('\"')}><%----%>
<m:nl />

<m:piece
    cssWrapper="detail-visual${setCssWrapperKeyPiece}"
    pieceLayout="${keyPieceLayout}"
    allowEmptyBodyColumn="${true}"
    sizeDesktop="${(keyPieceLayout < 2 || keyPieceLayout == 10) ? 12 : 6}"
    sizeMobile="${12}">

    <jsp:attribute name="heading">
        <div class="poi-head"><%----%>
            <m:intro-headline intro="${value.Intro}" headline="${value.Title}" level="${hsize}" ade="${ade}"/>
            ${accessibleFacilities}
        </div><%----%>
    </jsp:attribute>

    <jsp:attribute name="text">
        <c:if test="${showLocation}">
            <div class="adr" <%--
            --%>itemprop="address" itemscope <%--
            --%>itemtype="http://schema.org/PostalAddress"><%----%>
                <div itemprop="streetAddress" class="street-address" ${value.Address.value.StreetAddress.rdfaAttr}>${value.Address.value.StreetAddress}</div><%----%>
                <c:if test="${value.Address.value.ExtendedAddress.isSet}">
                    <div itemprop="streetAddress" class="extended-address" ${value.Address.value.ExtendedAddress.rdfaAttr}>${value.Address.value.ExtendedAddress}</div><%----%>
                </c:if>
                <div><%----%>
                    <span itemprop="postalCode" class="postal-code" ${value.Address.value.PostalCode.rdfaAttr}>${value.Address.value.PostalCode}</span>${' '}<%----%>
                    <span itemprop="addressLocality" class="locality" ${value.Address.value.Locality.rdfaAttr}>${value.Address.value.Locality}</span><%----%>
                </div><%----%>
                <c:if test="${value.Address.value.Region.isSet or value.Address.value.Country.isSet}">
                    <div><%----%>
                        <c:if test="${value.Address.value.Region.isSet}">
                            <span itemprop="addressRegion" class="region" ${value.Address.value.Region.rdfaAttr}>${value.Address.value.Region}</span>${' '}<%----%>
                        </c:if>
                        <c:if test="${value.Address.value.Country.isSet}">
                            <span itemprop="addressCountry" class="country-name" ${value.Address.value.Country.rdfaAttr}>${value.Address.value.Country}</span><%----%>
                        </c:if>
                    </div><%----%>
                </c:if>
            </div><%----%>
            <m:nl />
        </c:if>
    </jsp:attribute>

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

    <jsp:attribute name="link">
        ${linkMarkup}
    </jsp:attribute>

</m:piece>

<c:if test="${showOpeningHours and openingHours.isSet}"><%----%>
    <div class="detail-content"><%----%>
        <fmt:message key="msg.page.openingHours" var="hoursHeading" />
        <m:heading level="${hsize+1}" text="${hoursHeading}" css="hours-heading" />
        <m:opening-hours content="${value.OpeningHours}" />
    </div><%----%>
    <m:nl />
</c:if>

<c:if test="${showDescription}">
    <div class="detail-content"><%----%>
        <m:paragraphs
            cssWrapper="${setCssWrapperParagraphs}"
            paragraphs="${content.valueList.Paragraph}"
            pieceLayout="${pieceLayout}"
            splitDownloads="${false}"
            hsize="${4}"
            showImageZoom="${showImageZoom}"
            showImageSubtitle="${showImageSubtitle}"
            showImageCopyright="${showImageCopyright}"
            ade="${ade}"
        />
    </div><%----%>
</c:if>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</cms:formatter>

</m:init-messages>