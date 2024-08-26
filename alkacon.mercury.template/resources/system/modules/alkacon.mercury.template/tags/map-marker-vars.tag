<%@ tag pageEncoding="UTF-8"
    display-name="map-marker-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects marker and location data for use in map info windows." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="false"
    description="Use this to generate the marker info for a content element. Supported types are 'm-poi', 'm-person', 'm-organization' and 'm-contact'." %>

<%@ attribute name="address" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Use this to generate the marker info for a nested address node." %>

<%@ attribute name="marker" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Use this to generate the marker info for a marker directly entered in a map." %>

<%@ attribute name="geocoords" type="java.lang.String" required="false"
    description="The geo coordinates the search has returned for this marker." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="Optional CSS wrapper classes added to the generated marker info div." %>

<%@ attribute name="showLink" type="java.lang.Boolean" required="false"
    description="Controls if the link is displayed. Default is 'true'.
    There are actually 2 type of links that can be displayed: The link to a website, and the link to a detail page.
    If 'false', then NONE of these links is rendered.
    If 'true' then the following applies:
    In case a 'marker' is rendered, this controls the link to the website.
    In case a 'content' is rendered, this controls the link to the detail page." %>

<%@ attribute name="showFacilities" type="java.lang.Boolean" required="false"
    description="If true, show the facility information in the marker info window. Default is 'false'." %>

<%@ attribute name="showRoute" type="java.lang.Boolean" required="false"
    description="If true, show route option in the marker info window. Currently only supported for Google maps, not OSM. Default is 'false'." %>


<%@ variable name-given="markerData" declare="true"
    description="A map that contains the marker data read for the location as properties." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="useContentTypes" value="${[
    'm-poi',
    'm-person',
    'm-organization',
    'm-contact'
]}" />

<c:set var="showFacilities"                 value="${empty showFacilities ? cms.sitemapConfig.attribute['geosearch.marker.show.facilities'].toBoolean : showFacilities}" />

<c:if test="${not empty content and not fn:contains(useContentTypes, content.typeName)}">
    <c:set var="address" value="${content.value.AddressChoice}" />
    <c:set var="content" value="${null}" />
</c:if>

<c:choose>
    <c:when test="${not empty content}">

        <%-- Generate the marker info for a content element of type 'm-poi', 'm-person', 'm-organization' or 'm-contact' --%>
        <c:set var="value"                  value="${content.value}" />
        <c:set var="showPosition"           value="${true}" />
        <c:set var="showOrganization"       value="${false}" />
        <c:set var="showNotice"             value="top" />
        <c:set var="showDescription"        value="top" />
        <c:set var="showPhone"              value="${true}" />
        <c:set var="showWebsite"            value="${true}" />
        <c:set var="showEmail"              value="${true}" />
        <c:set var="labelOption"            value="label-min" />
        <c:set var="linkOption"             value="${cms.formatterSettingDefault['m/display/person-compact']['linkOption']}" />
        <c:set var="linkTarget"             value="${cms.sitemapConfig.attribute['geosearch.marker.link.target']}" />
        <c:set var="buttonText"             value="${cms.sitemapConfig.attribute['geosearch.marker.button.text']}" />

        <m:contact-vars
            content="${content}"
            showPosition="${showPosition}"
            showOrganization="${showOrganization}">

            <m:location-vars data="${valAddress}">
                <c:set var="markerHeading">
                    <m:contact
                        kind="${valKind}"
                        name="${valName}"
                        position="${valPosition}"
                        organization="${valOrganization}"
                        addTextBox="${false}"
                        showName="${true}"
                        showOrganization="${setShowOrganization}"
                        showPosition="${setShowPosition}"
                    />
                </c:set>
                <c:set var="markerText">
                    <m:contact
                        kind="${valKind}"
                        name="${valName}"
                        position="${valPosition}"
                        organization="${valOrganization}"
                        address="${valAddress}"
                        addTextBox="${false}"
                        showAddressAlways="${true}"
                        data="${value.Contact}"
                        locData="${locData}"
                        linkToWebsite="${empty showLink or showLink ? valLinkToWebsite : null}"

                        showFacilities="${showFacilities}"
                        showNotice="${showNotice}"
                        showDescription="${showDescription}"
                        showPhone="${showPhone}"
                        showWebsite="${showWebsite}"
                        showEmail="${showEmail}"
                        labelOption="${labelOption}"
                        linkOption="${linkOption}"
                    />
                </c:set>
                <c:set var="markerData" value="${locData}" />

            </m:location-vars>
        </m:contact-vars>

        <c:if test="${showLink or empty showLink}">
            <c:set var="linkToDetail"><cms:link baseUri="${cms.requestContext.folderUri}">${content.filename}</cms:link></c:set>
            <c:set var="link" value="${(linkOption ne 'none') and (linkTarget ne 'none') ? (linkTarget eq 'detail' ? linkToDetail : value.Link) : null}" />
        </c:if>

    </c:when>
    <c:when test="${not empty address}">

        <%-- Generate the marker info for a nested address node --%>
        <m:location-vars data="${address}">

            <c:set var="markerHeading">
                <c:if test="${not empty locData.name}">
                    <h3 class="fn n">${locData.name}</h3><%----%>
                </c:if>
            </c:set>

            <c:set var="markerText">
                <m:contact
                    kind="poi"
                    locData="${locData}"
                    addTextBox="${false}"
                    showAddressAlways="${true}"
                    showFacilities="${showFacilities}"
                    labelOption="label-min"
                />
            </c:set>

            <%-- Address only node does not require a detail page link --%>

            <c:set var="markerData" value="${locData}" />
        </m:location-vars>

    </c:when>
    <c:when test="${not empty marker}">

        <%-- Generate the marker info for a marker directly entered in a map --%>
        <jsp:useBean id="coordBean" class="org.opencms.widgets.CmsLocationPickerWidgetValue" />
        <jsp:setProperty name="coordBean" property="wrappedValue" value="${marker.value.Coord.stringValue}" />

        <c:if test="${(coordBean.lat != 0) and (coordBean.lng != 0)}">

            <c:if test="${not empty marker.value.Caption}">
                <c:set var="markerHeading">
                    <h3 class="fn n">${marker.value.Caption}</h3><%----%>
                </c:set>
            </c:if>

            <c:set var="markerText">
                <div class="adr"><%----%>
                    <c:choose>
                        <c:when test="${not empty marker.value.Address}">
                            ${cms:escapeHtml(fn:trim(marker.value.Address))}
                            <c:set var="markerNeedsGeoCode" value="false" />
                        </c:when>
                        <c:otherwise>
                            <%-- This will be replaced by Google GeoCoder in JavaScript --%>
                            <!-- replace-with-geoadr --><%----%>
                            <c:set var="markerNeedsGeoCode" value="true" />
                        </c:otherwise>
                    </c:choose>
                </div><%----%>
                <m:contact
                    kind="poi"
                    addTextBox="${false}"
                    linkToWebsite="${marker.value.Link}"
                    showWebsite="${showLink}"
                    labelOption="label-min"
                />
            </c:set>

            <%-- Direct marker does not require a detail page link --%>

            <c:set var="markerData" value="${{
                'lat': coordBean.lat,
                'lng': coordBean.lng,
                'geocode': markerNeedsGeoCode
            }}" />
        </c:if>

    </c:when>
    <c:otherwise>
       <c:if test="${not empty geocoords}">
            <c:set var="markerHeading">
                <h3 class="fn n"><fmt:message key="msg.page.map.info.empty" /></h3><%----%>
            </c:set>

            <c:set var="geocos" value="${fn:split(geocoords, ',')}" />
            <c:set var="markerData" value="${{
                'lat': geocos[1],
                'lng': geocos[0]
            }}" />
        </c:if>
    </c:otherwise>
</c:choose>

<c:if test="${not empty markerData}">

    <c:if test="${not empty link}">
        <fmt:message var="linkDefaultText" key="${isDetailLink ? 'msg.page.moreLink' : 'msg.page.map.link.default.text'}" />
        <c:set var="markerLink">
            <m:link
                link="${link}"
                css="piece-text-link"
                text="${linkDefaultText}"
                forceText="${buttonText}"
                noExternalMarker="${true}" />
        </c:set>
    </c:if>

    <c:set var="markerInfoMarkup">

        <div class="map-marker${empty cssWrapper ? '' : ' '.concat(cssWrapper)}"><%----%>
            <c:if test="${not empty markerHeading}">
                <div class="heading"><%----%>
                    ${markerHeading}
                </div><%----%>
            </c:if>
            <c:if test="${not empty markerText}">
                ${markerText}
            </c:if>
            <c:if test="${not empty markerLink}">
            <div class="link"><%----%>
                ${markerLink}
            </div><%----%>
            </c:if>
            <c:if test="${showRoute and (not empty markerData.lat) and (not empty markerData.lng)}">
                <%-- Note: Route markup is supported only by Google maps --%>
                <div class="marker-route"><%----%>
                    <div><fmt:message key="msg.page.map.route" /></div><%----%>
                    <div><fmt:message key="msg.page.map.start" /></div><%----%>
                    <form action="https://maps.google.com/maps" method="get" target="_blank" rel="noopener"><%----%>
                        <input type="text" class="form-control" size="15" maxlength="60" name="saddr" value="" /><%----%>
                        ${'<input value="'}<fmt:message key="msg.page.map.route.button" />${'" type="submit" class="btn">'}<%----%>
                        <input type="hidden" name="daddr" value="${markerData.lat},${markerData.lng}"/><%----%>
                    </form><%----%>
                </div><%----%>
            </c:if>
        </div><%----%>
    </c:set>

    <c:set target="${markerData}" property="infoMarkup" value="${markerInfoMarkup}" />
</c:if>

<jsp:doBody/>

</cms:bundle>