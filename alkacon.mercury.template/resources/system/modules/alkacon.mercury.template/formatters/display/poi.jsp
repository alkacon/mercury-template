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

<c:set var="title"                  value="${value.Title}" />

<c:if test="${showFacilities and value.Facilities.isSet}">
    <c:set var="accessibleFacilities">
        <div class="accessible"><%----%>
            <c:if test="${value.Facilities.value.WheelchairAccess.toBoolean}">
                <div title="<fmt:message key='label.Facility.WheelchairAccess' />" tabindex="0" data-bs-toggle="tooltip" class="acc-icon"><%----%>
                    <span class="acc-inner"><%----%>
                        <mercury:icon icon="wheelchair" tag="span" />
                    </span><%----%>
                </div><%----%>
            </c:if>
            <c:if test="${value.Facilities.value.HearingImpaired.toBoolean}">
                <div title="<fmt:message key='label.Facility.HearingImpaired' />" tabindex="0" data-bs-toggle="tooltip" class="acc-icon"><%----%>
                    <span class="acc-inner"><%----%>
                        <mercury:icon icon="assistive-listening-systems" tag="span" />
                    </span><%----%>
                </div><%----%>
            </c:if>
            <c:if test="${value.Facilities.value.LowVision.toBoolean}">
                <div title="<fmt:message key='label.Facility.LowVision' />" tabindex="0" data-bs-toggle="tooltip" class="acc-icon"><%----%>
                    <span class="acc-inner"><%----%>
                        <mercury:icon icon="low-vision" tag="span" />
                    </span><%----%>
                </div><%----%>
            </c:if>
            <c:if test="${value.Facilities.value.PublicRestrooms.toBoolean}">
                <div title="<fmt:message key='label.Facility.PublicRestrooms' />" tabindex="0" data-bs-toggle="tooltip" class="acc-icon"><%----%>
                    <span class="acc-inner"><%----%>
                        <mercury:icon icon="male" tag="span" cssWrapper="acc-male" />
                        <mercury:icon icon="female" tag="span" cssWrapper="acc-female" />
                    </span><%----%>
                </div><%----%>
            </c:if>
            <c:if test="${value.Facilities.value.PublicRestroomsAccessible.toBoolean}">
                <div title="<fmt:message key='label.Facility.PublicRestroomsAccessible' />" tabindex="0" data-bs-toggle="tooltip" class="acc-icon"><%----%>
                    <span class="acc-inner acc-wc"><%----%>
                        <mercury:icon icon="wheelchair" tag="span" />
                    </span><%----%>
                    <span class="acc-add acc-wc"><%----%>
                        <mercury:icon icon="male" tag="span" cssWrapper="acc-male" />
                        <mercury:icon icon="female" tag="span" cssWrapper="acc-female" />
                    </span><%----%>
                </div><%----%>
            </c:if>
        </div><%----%>
        <mercury:nl />
    </c:set>
</c:if>

<mercury:teaser-piece
    cssWrapper="type-poi${setCssWrapper}${setEffect}"
    headline="${title}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"
    teaserType="${displayType}"
    link="${linkToDetail}"
    linkOption="${setLinkOption}"
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
        <mercury:nl />
        ${accessibleFacilities}
    </jsp:attribute>

</mercury:teaser-piece>
</mercury:teaser-settings>

</cms:bundle>
</cms:formatter>

</mercury:init-messages>