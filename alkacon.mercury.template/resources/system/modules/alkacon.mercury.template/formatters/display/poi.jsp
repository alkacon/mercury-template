<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value" rdfa="rdfa">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:teaser-settings content="${content}">

<c:set var="showMap"                value="${setting.showMap.toBoolean}" />
<c:set var="mapRatio"               value="${setting.mapRatio.toString}" />
<c:set var="mapZoom"                value="${setting.mapZoom.toString}" />
<c:set var="showFacilities"         value="${setting.showFacilities.toBoolean}" />
<c:set var="showGeoInfo"            value="${setting.showGeoInfo.toBoolean}" />

<c:set var="title"                  value="${value.Title}" />

<c:if test="${showFacilities and value.Facilities.isSet}">
    <c:set var="accessibleFacilities">
        <mercury:facility-icons
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
        <mercury:nl />
    </c:set>
</c:if>

<mercury:teaser-piece
    cssWrapper="type-poi${setCssWrapperAll}"
    headline="${title}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"
    teaserType="${displayType}"
    link="${linkToDetail}"
    linkOption="${setLinkOption}"
    noLinkOnVisual="${true}"
    buttonText="${setButtonText}"
    hsize="${setHsize}">

    <jsp:attribute name="markupVisual">
        <c:if test="${showMap and value.Coord.isSet}">
            <mercury:location-vars data="${content}" addMapInfo="true" >
                <c:set var="id"><mercury:idgen prefix='poimap' uuid='${cms.element.instanceId}' /></c:set>
                <mercury:map
                    provider="auto"
                    id="${id}"
                    ratio="${mapRatio}"
                    zoom="${mapZoom}"
                    markers="${[locData]}"
                    subelementWrapper="poi-map"
                />
            </mercury:location-vars>
        </c:if>
        <mercury:alert test="${cms.isEditMode and showMap and not value.Coord.isSet}" type="warning">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.poi.nomap" />
            </jsp:attribute>
        </mercury:alert>
    </jsp:attribute>

    <jsp:attribute name="markupBody">
        <mercury:link
            link="${linkToDetail}"
            css='uncolored'
            attr="${'tabindex=\"-1\"'}"
            test="${true}">

            <p class="adr"><%----%>
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
            </p><%----%>
            <mercury:nl />
            ${geoInfo}
            ${accessibleFacilities}

        </mercury:link>
    </jsp:attribute>

</mercury:teaser-piece>
</mercury:teaser-settings>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>