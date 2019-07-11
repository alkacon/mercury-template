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

<c:set var="preview"                value="${empty pageContext.request.getAttribute('ATTR_TEMPLATE_BEAN')}" />

<cms:secureparams />
<mercury:init-messages reload="${showMap and not preview}">

<cms:formatter var="content" val="value" rdfa="rdfa">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="showMap"                value="${setting.showMap.toBoolean}" />
<c:set var="mapRatio"               value="${setting.mapRatio.toString}" />
<c:set var="mapZoom"                value="${setting.mapZoom.toString}" />
<c:set var="showLocation"           value="${value.Address.isSet and setting.showLocation.toBoolean}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageSubtitle"      value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />

<c:set var="ade"                    value="${true}" />

<mercury:nl />
<div class="element type-poi ${cssWrapper}"><%----%>
<mercury:nl />

    <div class="poi-head"><%----%>

        <mercury:heading level="${hsize}" text="${value.Title}" ade="${ade}" css="heading" />

        <c:if test="${value.Facilities.isSet}">
            <div class="accessible"><%----%>
                <c:if test="${value.Facilities.value.WheelchairAccess.toBoolean}">
                    <div title="<fmt:message key='label.Facility.WheelchairAccess' />" tabindex="0" data-toggle="tooltip" class="acc-icon"><span class="acc-inner"><span class="fa fa-wheelchair"></span></span></div><%----%>
                </c:if>
                <c:if test="${value.Facilities.value.HearingImpaired.toBoolean}">
                    <div title="<fmt:message key='label.Facility.HearingImpaired' />" tabindex="0" data-toggle="tooltip" class="acc-icon"><span class="acc-inner"><span class="fa fa-assistive-listening-systems"></span></span></div><%----%>
                </c:if>
                <c:if test="${value.Facilities.value.LowVision.toBoolean}">
                    <div title="<fmt:message key='label.Facility.LowVision' />" tabindex="0" data-toggle="tooltip" class="acc-icon"><span class="acc-inner"><span class="fa fa-low-vision"></span></span></div><%----%>
                </c:if>
                <c:if test="${value.Facilities.value.PublicRestrooms.toBoolean}">
                    <div title="<fmt:message key='label.Facility.PublicRestrooms' />" tabindex="0" data-toggle="tooltip" class="acc-icon"><span class="acc-inner"><span class="fa fa-male"></span><span class="fa fa-female"></span></span></div><%----%>
                </c:if>
            </div><%----%>
        </c:if>

    </div><%----%>
    <mercury:nl />

    <c:if test="${showLocation}">
        <div class="subelement adr " <%--
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
    </c:if>

    <c:if test="${showMap and not preview and value.Coord.isSet}">
        <mercury:location-data data="${content}" addMapInfo="true" >
            <c:set var="id"><mercury:idgen prefix='poimap' uuid='${cms.element.instanceId}' /></c:set>
            <c:set var="markerList" value="${cms:createList()}" />
            ${cms:addToList(markerList, locData)}
            <mercury:map-subelement
                id="${id}"
                ratio="${mapRatio}"
                zoom="${mapZoom}"
                markers="${markerList}"
            />
        </mercury:location-data>
        <mercury:nl />
    </c:if>

    <mercury:alert test="${cms.isEditMode and showMap and not value.Coord.isSet}" type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.page.poi.nomap" />
        </jsp:attribute>
    </mercury:alert>

    <c:if test="${showDescription}">
        <mercury:paragraphs
            paragraphs="${content.valueList.Paragraph}"
            pieceLayout="${pieceLayout}"
            splitDownloads="${false}"
            hsize="${4}"
            showImageZoom="${showImageZoom}"
            showImageSubtitle="${showImageSubtitle}"
            showImageCopyright="${showImageCopyright}"
            ade="${ade}"
        />
    </c:if>

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>

</mercury:init-messages>