<%@ tag pageEncoding="UTF-8"
    display-name="map-marker-info"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a marker info window for use on maps." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content element to generate the marker info window for.
    Currently supported types are 'place / poi', 'contact information', 'person' and 'organization'." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="Optional CSS wrapper classes added to the generated marker info div." %>

<%@ attribute name="linkDisplay" type="java.lang.String" required="false"
    description="Controls if and how the link is displayed. Default is 'text'." %>

<%@ attribute name="showRoute" type="java.lang.Boolean" required="false"
    description="If true, show route option in the marker info window. Currently only supported for Google maps, not OSM." %>

<%@ attribute name="showFacilities" type="java.lang.Boolean" required="false"
    description="If true, show the facility information in the marker info window." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="value"                          value="${content.value}" />

<c:choose>
    <c:when test="${content.typeName eq 'm-poi'}">
        <c:set var="isPoi"                  value="${true}" />
        <c:set var="isValidType"            value="${true}" />
    </c:when>
    <c:when test="${content.typeName eq 'm-organization'}">
        <c:set var="isOrganizaton"          value="${true}" />
        <c:set var="isValidType"            value="${true}" />
        <c:set var="addrData"               value="${value.Contact.value.AddressChoice}" />
    </c:when>
    <c:when test="${content.typeName eq 'm-person'}">
        <c:set var="isPerson"               value="${true}" />
        <c:set var="isValidType"            value="${true}" />
        <c:set var="addrData"               value="${value.Contact.value.AddressChoice}" />
    </c:when>
    <c:when test="${content.typeName eq 'm-contact'}">
        <c:set var="isContact"              value="${true}" />
        <c:set var="isValidType"            value="${true}" />
        <c:set var="addrData"               value="${value.Contact.value.AddressChoice}" />
    </c:when>
</c:choose>

<c:if test="${isValidType}">

    <m:location-vars data="${empty addrData ? content : addrData}" addMapInfo="true">

        <c:choose>
            <c:when test="${isPoi}">
                <c:set var="heading">
                    <h3 class="fn n">${locData.name}</h3><%----%>
                </c:set>
                <c:set var="link"                   value="${locData.poiLink}" />
                <fmt:message var="linkDefaultText"  key="msg.page.map.link.default.text" />
            </c:when>
            <c:otherwise>
                <m:contact-vars
                content="${content}"
                showPosition="${showPosition}"
                showOrganization="${showOrganization}">
                    <c:set var="heading">
                        <m:contact
                            kind="${valKind}"
                            name="${valName}"
                            position="${valPosition}"
                            organization="${valOrganization}"
                            showName="${true}"
                            showOrganization="${isOrganizaton}"
                            addTextBox="${false}"
                        />
                    </c:set>
                <fmt:message var="linkDefaultText"  key="msg.page.moreLink" />
                </m:contact-vars>
            </c:otherwise>
        </c:choose>

        <c:if test="${empty link}">
            <c:set var="pageUri"                value="${cms.requestContext.folderUri}" />
            <c:set var="link"><cms:link baseUri="${pageUri}">${content.filename}</cms:link></c:set>
            <c:set var="useLinkDefaultText"     value="${true}" />
        </c:if>

        <c:set var="showLink"                   value="${not empty link and (linkDisplay ne 'none')}" />

        <m:piece
            cssWrapper="map-marker${empty cssWrapper ? '' : ' '.concat(cssWrapper)}"
            pieceLayout="${0}">

            <jsp:attribute name="heading">
                <c:if test="${not empty heading}">
                    ${heading}
                </c:if>
            </jsp:attribute>

            <jsp:attribute name="text">

                <c:if test="${showFacilities and (not empty locData.facilities)}">
                    <m:facility-icons
                        wheelchairAccess="${locData.facilities.value.WheelchairAccess.toBoolean}"
                        hearingImpaired="${locData.facilities.value.HearingImpaired.toBoolean}"
                        lowVision="${locData.facilities.value.LowVision.toBoolean}"
                        publicRestrooms="${locData.facilities.value.PublicRestrooms.toBoolean}"
                        publicRestroomsAccessible="${locData.facilities.value.PublicRestroomsAccessible.toBoolean}"
                    />
                </c:if>

                <div class="adr"><%----%>
                    <div class="street-address">${locData.streetAddress}</div><%----%>
                    <c:if test="${not empty locData.extendedAddress}">
                        <div class="extended-address">${locData.extendedAddress}</div><%----%>
                    </c:if>
                    <div><%----%>
                        <span class="postal-code">${locData.postalCode}</span>${' '}<%----%>
                        <span class="locality">${locData.locality}</span><%----%>
                    </div><%----%>
                    <c:if test="${(not empty locData.region) or (not empty locData.country)}">
                        <div><%----%>
                            <c:if test="${not empty locData.region}">
                                <span class="region">${locData.region}${' '}</span><%----%>
                            </c:if>
                            <c:if test="${not empty locData.country}">
                                <span class="country-name">${locData.country}</span><%----%>
                            </c:if>
                        </div><%----%>
                    </c:if>
                </div><%----%>

                <%-- Note: Route markup is supported only by Google maps --%>
                <c:if test="${showRoute}">
                    <div class="marker-route"><%----%>
                        <div><fmt:message key="msg.page.map.route" /></div><%----%>
                        <div><fmt:message key="msg.page.map.start" /></div><%----%>
                        <form action="https://maps.google.com/maps" method="get" target="_blank" rel="noopener"><%----%>
                            <input type="text" class="form-control" size="15" maxlength="60" name="saddr" value="" /><%----%>
                            ${'<input value="'}<fmt:message key="msg.page.map.route.button" />${'" type="submit" class="btn">'}<%----%>
                            <input type="hidden" name="daddr" value="${locData.lat},${locData.lng}"/><%----%>
                        </form><%----%>
                    </div><%----%>
                </c:if>

            </jsp:attribute>

            <jsp:attribute name="link">
                <c:if test="${showLink}">
                    <c:set var="linkForceText" value="${useLinkDefaultText ? linkDefaultText : null}" />
                    <c:choose>
                        <c:when test="${linkDisplay eq 'button-full'}">
                            <c:set var="linkCss" value="btn btn-block piece-btn" />
                        </c:when>
                        <c:when test="${linkDisplay eq 'button-sm'}">
                            <c:set var="linkCss" value="btn btn-sm piece-btn" />
                        </c:when>
                        <c:when test="${linkDisplay eq 'text'}">
                            <c:set var="linkCss" value="piece-text-link" />
                        </c:when>
                        <c:otherwise>
                            <%-- default is 'button' --%>
                            <c:set var="linkCss" value="btn piece-btn teaser-btn" />
                        </c:otherwise>
                    </c:choose>
                    <m:link
                        link="${link}"
                        css="${linkCss}"
                        forceText="${linkForceText}"
                        title="${cms:stripHtml(heading)}"
                        noExternalMarker="${true}" />
                </c:if>
            </jsp:attribute>

        </m:piece>

    </m:location-vars>
</c:if>

</cms:bundle>