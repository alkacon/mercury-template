<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:setting-defaults>

<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />

<c:set var="showOrganization"       value="${true}" />
<c:set var="showPosition"           value="${true}" />
<c:set var="showAddress"            value="${true}" />
<c:set var="showAddressAlways"      value="${true}" />
<c:set var="showTitle"              value="${setting.showTitle.toBoolean or (setting.showTitle.toString eq 'below')}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean or (setting.showDescription.toString eq 'below')}" />
<c:set var="showLink"               value="${true}" />
<c:set var="showPhone"              value="${true}" />
<c:set var="showWebsite"            value="${true}" />
<c:set var="showEmail"              value="${true}" />
<c:set var="showVcard"              value="${setting.showVcard.toBoolean}" />

<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageCopyright"     value="${setting.showImageCopyright.toBoolean}" />
<c:set var="imageRatio"             value="${setting.imageRatio.toString}" />
<c:set var="showImage"              value="${(imageRatio ne 'no-img') and value.Image.value.Image.isSet}" />

<c:set var="showLinkedOrgs"         value="${setting.showLinkedOrgs.toBoolean}" />

<c:set var="setSizeDesktop"         value="${setting.pieceSizeDesktop.toInteger}" />
<c:set var="setSizeMobile"          value="${setting.pieceSizeMobile.toInteger}" />

<c:set var="mapLayout"              value="${setting.mapLayout.toInteger}" />
<c:set var="showMap"                value="${mapLayout >= 0}" />
<c:set var="mapRatio"               value="${setting.mapRatio.toString}" />
<c:set var="mapZoom"                value="${setting.mapZoom.toString}" />
<c:set var="setMapSizeDesktop"      value="${setting.mapSizeDesktop.toInteger}" />

<c:set var="labelOption"            value="${setting.labels.toString}" />
<c:set var="linkOption"             value="${setting.linkOption.toString}" />

<c:set var="containerType"          value="${setting.containerType.useDefault('element').toString}" />

<c:set var="showTitleAbove"         value="${showTitle and not (setting.showTitle.toString eq 'below')}" />
<c:set var="showDescriptionAbove"   value="${showDescription and not (setting.showDescription.toString eq 'below')}" />

<c:set var="hsizeTitle"             value="${showTitleAbove ? hsize : hsize + 1}" />
<c:set var="hsize"                  value="${showTitleAbove ? hsize + 1 : hsize}" />

<mercury:contact-vars
    content="${content}"
    showPosition="${showPosition}"
    showOrganization="${showOrganization}">

<mercury:location-vars data="${valAddress}" addMapInfo="true">

<mercury:nl />
<div class="detail-page type-contact${setCssWrapper}"><%----%>
<mercury:nl />

<c:set var="imageMarkup">
    <c:if test="${showImage}">
        <mercury:contact
            kind="${valKind}"
            image="${value.Image}"
            organization="${valOrganization}"
            imageRatio="${imageRatio}"
            link="${showLink ? value.Link : null}"
            linkOption="${linkOption eq 'imageOverlay' ? 'imageOverlay' : ''}"
            hsize="${hsize}"
            showImage="${true}"
            showImageZoom="${showImageZoom}"
            showImageCopyright="${showImageCopyright}"
        />
    </c:if>
</c:set>

<c:set var="mapMarkup">
    <c:set var="hasCoords" value="${valAddress.isSet and (valAddress.value.Address.value.Coord.isSet or valAddress.value.PoiLink.isSet)}" />
    <c:if test="${showMap and hasCoords}">
        <c:set var="id"><mercury:idgen prefix='poimap' uuid='${cms.element.instanceId}' /></c:set>
        <mercury:map
            provider="auto"
            id="${id}"
            ratio="${mapRatio}"
            zoom="${mapZoom}"
            markers="${[locData]}"
            subelementWrapper="poi-map"
        />
        <mercury:nl />
    </c:if>
    <mercury:alert test="${showMap and cms.isEditMode and not hasCoords}" type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.page.poi.nomap" />
        </jsp:attribute>
    </mercury:alert>
</c:set>

<%-- If no map is there, additional info can be included in the first section --%>
<c:set var="showMapSection" value="${not empty mapMarkup or (value.Title.isSet and not showTitleAbove and showTitle)}" />
<c:set var="singleLink" value="${not value.Description.isSet and not value.Title.isSet and value.Link.isSet}" />

<%-- first section displays organization address and logo  --%>
<mercury:section-piece
    cssWrapper="subelement ${kindCss}${setCssWrapper2}"
    pieceLayout="${pieceLayout}"
    heading="${showTitleAbove ? value.Title : null}"
    hsize="${hsizeTitle}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"
    ade="${false}">

    <jsp:attribute name="markupVisual">
        ${imageMarkup}
    </jsp:attribute>

    <jsp:attribute name="markupText">
        <mercury:contact
            kind="${valKind}"
            link="${showMapSection and not singleLink ? null: value.Link}"
            linkOption="${linkOption}"
            name="${valName}"
            position="${valPosition}"
            organization="${valOrganization}"
            description="${not showDescriptionAbove and showMapSection ? null: value.Description}"
            data="${value.Contact}"
            address="${valAddress}"
            labelOption="${labelOption}"
            hsize="${hsize}"
            showName="${false}"
            showPosition="${false}"
            showAddress="${showAddress}"
            showAddressAlways="${showAddressAlways}"
            showOrganization="${true}"
            showDescription="${showDescription}"
            showPhone="${showPhone}"
            showWebsite="${showWebsite}"
            showEmail="${showEmail}"
            showVcard="${showVcard}"
        />

        <c:if test="${showLinkedOrgs and value.LinkToParentOrganization.isSet}">
            <c:set var="linkToParent"><cms:link baseUri="${cms.requestContext.uri}">${value.LinkToParentOrganization}</cms:link></c:set>
            <c:set var="parent" value="${cms.vfs.readXml[value.LinkToParentOrganization]}" />
            <c:set var="propertyDetailLink" value="${parent.resource.property['mercury.detail.link']}" />
            <c:if test="${not empty propertyDetailLink and cms.vfs.exists[propertyDetailLink]}">
                <c:set var="linkToParent"><cms:link baseUri="${cms.requestContext.uri}">${propertyDetailLink}</cms:link></c:set>
            </c:if>
            <div class="parentlink pivot${setCssWrapper2}"><%----%>
                <fmt:message var="parentInstitutionDefault" key="msg.page.institution.parent" />
                <c:set var="parentInstitution" value="${cms.sitemapConfig.attribute['msg.page.institution.parent']}" />
                <span>${empty parentInstitution ? parentInstitutionDefault : parentInstitution}</span> <%----%>
                <mercury:link link="${linkToParent}">
                    ${parent.value.Organization}
                </mercury:link>
            </div><%----%>
        </c:if>

    </jsp:attribute>

</mercury:section-piece>

<%-- second section displays map and additional text --%>
<c:if test="${showMapSection}">
    <c:choose>
        <%-- We always want the map displayed "on the side", so fake a text if there is none, otherwise the map would be displayed full --%>
        <c:when test="${(setMapSizeDesktop < 12) and (not value.Description.isSet or not showDescription or showDescriptionAbove) and not value.Title.isSet}">
            <c:set var="valDescription" value="&nbsp;" />
        </c:when>
        <c:otherwise>
            <c:set var="valDescription" value="${value.Description}" />
        </c:otherwise>
    </c:choose>
    <mercury:section-piece
        cssWrapper="subelement"
        cssVisual="map-visual"
        pieceLayout="${mapLayout}"
        sizeDesktop="${setMapSizeDesktop}"
        heading="${not showTitle or showTitleAbove ? null : value.Title}"
        text="${showDescription and not showDescriptionAbove ? valDescription : null}"
        link="${singleLink ? null : value.Link}"
        hsize="${hsizeTitle}"
        linkOption="${linkOption eq 'button' ? 'button-sm' : (linkOption eq 'button-lg' ? 'button' : linkOption)}"
        ade="${false}"
        emptyWarning="${true}">
        <jsp:attribute name="markupVisual">
            ${mapMarkup}
        </jsp:attribute>
    </mercury:section-piece>
</c:if>

<mercury:container-attachment content="${content}" name="attachments" type="${containerType}" />

<c:if test="${showLinkedOrgs}">
    <c:set var="suborgs" value="${content.resource.getIncomingRelations(content.typeName)}" />
    <c:if test="${not empty suborgs}">
        <c:set var="buttonText" value="${cms.sitemapConfig.attribute['geosearch.marker.button.text']}" />
        <c:set var="institutionText" value="${cms.sitemapConfig.attribute['msg.page.institutions']}" />
        <fmt:message var="institutionTextDefault" key="msg.page.institutions" />
        <mercury:nl />
        <div class="suborgs pivot"><%----%>
            <mercury:heading level="${showTitleAbove ? hsize : hsize + 1}" text="${empty institutionText ? institutionTextDefault : institutionText}" />
            <div class="suborg-list box-inner"><%----%>
                <c:forEach var="res" items="${suborgs}">
                    <cms:simpledisplay
                        value="${res.sitePath}"
                        editable="true"
                        formatterKey="m/display/organization-elaborate">
                            <cms:param name="hsize" value="${showTitleAbove ? hsize + 1 : hsize + 2}" />
                            <cms:param name="visualOption" value="none" />
                            <cms:param name="showOrganization" value="false" />
                            <cms:param name="showTitle" value="false" />
                            <cms:param name="showAddInfo" value="false" />
                            <cms:param name="showDescription" value="false" />
                            <cms:param name="linkTarget" value="detail" />
                            <cms:param name="buttonText" value="${buttonText}" />
                    </cms:simpledisplay>
                </c:forEach>
            </div><%----%>
        </div><%----%>
        <mercury:nl />
    </c:if>
</c:if>

</div><%----%>
<mercury:nl />

</mercury:location-vars>
</mercury:contact-vars>
</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>
</mercury:init-messages>