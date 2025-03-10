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

<cms:secureparams replaceInvalid="bad_param" />
<m:init-messages>

<cms:formatter var="content" val="value" rdfa="rdfa">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:teaser-settings content="${content}">

<c:set var="intro"      value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
<c:set var="title"      value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="preface"    value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : null}" />

<c:set var="displayAddressMarkup"   value="${fn:startsWith(param.displayType, 'static:')}" />
<c:set var="displayAddressMarkup"   value="${displayAddressMarkup or (setting.poiDisplayOption.toString eq 'addr')}" />
<c:set var="displayAddressMarkup"   value="${displayAddressMarkup or ((setting.poiDisplayOption.toString eq 'textaddr') and (empty preface) and (not paragraph.isSet))}" />

<c:choose>
<c:when test="${displayAddressMarkup}">

    <c:set var="showMap"                value="${setting.showMap.toBoolean}" />
    <c:set var="mapRatio"               value="${setting.mapRatio.toString}" />
    <c:set var="mapRatioLg"             value="${setting.mapRatioLg.useDefault(mapRatio).toString}" />
    <c:set var="mapZoom"                value="${setting.mapZoom.toString}" />
    <c:set var="showFacilities"         value="${setting.showFacilities.toBoolean}" />
    <c:set var="showGeoInfo"            value="${setting.showGeoInfo.toBoolean}" />
    <c:set var="isMapMarker"            value="${setting.cssWrapper.toString eq 'map-marker'}" />

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

    <c:if test="${showGeoInfo and value.Coord.isSet}">
        <c:set var="geoInfo">
            <jsp:useBean id="coordBean" class="org.opencms.widgets.CmsLocationPickerWidgetValue" />
            <jsp:setProperty name="coordBean" property="wrappedValue" value="${value.Coord}" />
            <p class="geoinfo"><%----%>
                GPS: ${coordBean.lat.toString()}, ${coordBean.lng.toString()}
            </p><%----%>
            <m:nl />
        </c:set>
    </c:if>

    <m:teaser-piece
        cssWrapper="type-poi${setCssWrapperAll}"
        headline="${title}"
        headlineSuffix="${setOrderBadge}"
        piecePreMarkup="${setElementPreMarkup}"
        pieceLayout="${setPieceLayout}"
        sizeDesktop="${setSizeDesktop}"
        sizeMobile="${setSizeMobile}"
        teaserType="${displayType}"
        link="${linkToDetail}"
        linkOnHeadline="${not isMapMarker}"
        linkOption="${not isMapMarker ? setLinkOption : 'text'}"
        noLinkOnVisual="${true}"
        buttonText="${setButtonText}"
        hsize="${setHsize}">

        <jsp:attribute name="markupVisual">
            <c:if test="${showMap and value.Coord.isSet}">
                <m:map-marker-vars content="${content}" showFacilities="${showFacilities}">
                    <c:set var="id"><m:idgen prefix='poimap' uuid='${cms.element.instanceId}' /></c:set>
                    <m:map
                        provider="auto"
                        id="${id}"
                        ratio="${mapRatio}"
                        ratioLg="${mapRatioLg}"
                        zoom="${mapZoom}"
                        markers="${[markerData]}"
                        subelementWrapper="poi-map"
                    />
                </m:map-marker-vars>
            </c:if>
            <m:alert test="${cms.isEditMode and showMap and not value.Coord.isSet}" type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.page.poi.nomap" />
                </jsp:attribute>
            </m:alert>
        </jsp:attribute>

        <jsp:attribute name="markupBody">

            <m:link
                link="${linkToDetail}"
                css="${not isMapMarker ? 'uncolored' : 'marker-text'}"
                attr="${not isMapMarker ? 'tabindex=\"-1\"' : ''}"
                test="${not isMapMarker}"
                testFailTag="div">

                <div class="adr"><%----%>
                    <div itemprop="streetAddress" class="street-address">${value.Address.value.StreetAddress}</div><%----%>
                    <c:if test="${value.Address.value.ExtendedAddress.isSet}">
                        <div class="extended-address">${value.Address.value.ExtendedAddress}</div><%----%>
                    </c:if>
                    <div><%----%>
                        <span class="postal-code">${value.Address.value.PostalCode}</span>${' '}<%----%>
                        <span class="locality">${value.Address.value.Locality}</span><%----%>
                    </div><%----%>
                    <c:if test="${value.Address.value.Region.isSet or value.Address.value.Country.isSet}">
                        <div><%----%>
                            <c:if test="${value.Address.value.Region.isSet}">
                                <span class="region">${value.Address.value.Region}</span>${' '}<%----%>
                            </c:if>
                            <c:if test="${value.Address.value.Country.isSet}">
                                <span class="country-name">${value.Address.value.Country}</span><%----%>
                            </c:if>
                        </div><%----%>
                    </c:if>
                </div><%----%>
                <m:nl />
                ${geoInfo}
                ${accessibleFacilities}

            </m:link>
        </jsp:attribute>

    </m:teaser-piece>
</c:when>

<c:otherwise>

    <m:teaser-piece
        teaserClass="${setTeaserClass}"
        cssWrapper="type-poi${setCssWrapperAll}"
        intro="${setShowIntro ? intro : null}"
        headline="${title}"
        preface="${preface}"
        date="${value.Date.toInstanceDate}"
        dateOnTop="${setDateOnTop}"
        paraCaption="${paragraph.value.Caption}"
        paraText="${paragraph.value.Text}"
        piecePreMarkup="${setElementPreMarkup}"
        pieceLayout="${setPieceLayout}"
        sizeDesktop="${setSizeDesktop}"
        sizeMobile="${setSizeMobile}"

        teaserType="${displayType}"
        link="${linkToDetail}"
        linkOption="${setLinkOption}"
        linkNewWin="${setLinkNewWin}"
        hsize="${setHsize}"
        dateFormat="${setDateFormat}"
        textLength="${value['TeaserData/TeaserPreface'].isSet ? -1 : setTextLength}"
        headingInBody="${setHeadingInBody}"
        buttonText="${setButtonText}">

        <jsp:attribute name="markupVisual">
            <c:if test="${setShowVisual}">
                <c:set var="image" value="${value['TeaserData/TeaserImage'].isSet ? value['TeaserData/TeaserImage'] : (paragraph.value.Image.isSet ? paragraph.value.Image : null)}" />
                <m:image-animated
                    image="${image}"
                    ratio="${setRatio}"
                    ratioLg="${setRatioLg}"
                    test="${not empty image}"
                    setTitle="${false}"
                    showCopyright="${setShowCopyright}"
                />
            </c:if>
        </jsp:attribute>

    </m:teaser-piece>
</c:otherwise>
</c:choose>

</m:teaser-settings>

</cms:bundle>
</cms:formatter>

</m:init-messages>