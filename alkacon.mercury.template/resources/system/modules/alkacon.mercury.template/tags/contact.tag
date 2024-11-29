<%@ tag pageEncoding="UTF-8"
    display-name="contact"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays contact information from the given content with support for schema.org annotation." %>


<%@ attribute name="kind" type="java.lang.String" required="false"
    description="The contact kind. Default is 'person'." %>

<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact image data." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="imageRatioLg" type="java.lang.String" required="false"
    description="Image ratio for large screens." %>

<%@ attribute name="imageTitle" type="java.lang.String" required="false"
    description="If provided, use this title for the image, otherwise generate a title from the contact name." %>

<%@ attribute name="link" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact link." %>

<%@ attribute name="name" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact name. From nested schema type contact-name." %>

<%@ attribute name="position" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact position." %>

<%@ attribute name="organization" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact organization." %>

<%@ attribute name="linkToRelated" type="java.lang.String" required="false"
    description="Link to the parent organization (for persons) or the contact persion (for organizations)." %>

<%@ attribute name="linkToDetail" type="java.lang.String" required="false"
    description="Link to the detail page." %>

<%@ attribute name="notice" type="java.lang.Object" required="false"
    description="Value wrapper for the notice." %>

<%@ attribute name="description" type="java.lang.Object" required="false"
    description="Value wrapper for the contact description." %>

<%@ attribute name="data" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact data that includes address, telephone etc. From nested schema type contact-data." %>

<%@ attribute name="locData" type="java.util.Map" required="false"
    description="A map containing the precalculated location data." %>

<%@ attribute name="linkToWebsite" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the website link. If not set, this will be read from the 'data'." %>

<%@ attribute name="address" type="java.lang.Object" required="false"
    description="Value wrapper for the contact data that includes the address (or link a to a POI). From nested schema type address." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the contact headline. Default is '3'." %>

<%@ attribute name="showName" type="java.lang.Boolean" required="false"
    description="Show the contact name." %>

<%@ attribute name="showImage" type="java.lang.Boolean" required="false"
    description="Show the contact image." %>

<%@ attribute name="showPosition" type="java.lang.Boolean" required="false"
    description="Show the contact position." %>

<%@ attribute name="showOrganization" type="java.lang.Boolean" required="false"
    description="Show the contact organization." %>

<%@ attribute name="showNotice" type="java.lang.String" required="false"
    description="Controls how the additional info is displayed. Can be either 'top', 'bottom', 'true' or 'false'. 'true' is the same as 'top'." %>

<%@ attribute name="showDescription" type="java.lang.String" required="false"
    description="Controls how the description info is displayed. Can be either 'top', 'bottom', 'true' or 'false'. 'true' is the same as 'bottom'." %>

<%@ attribute name="showFacilities" type="java.lang.Boolean" required="false"
    description="If true, show the facility information for the place / address (if available)." %>

<%@ attribute name="showAddress" type="java.lang.Boolean" required="false"
    description="Show the contact address." %>

<%@ attribute name="showAddressAlways" type="java.lang.Boolean" required="false"
    description="Always show the contact address." %>

<%@ attribute name="showPhone" type="java.lang.Boolean" required="false"
    description="Show the contact phone number." %>

<%@ attribute name="showWebsite" type="java.lang.Boolean" required="false"
    description="Show the contact website URL." %>

<%@ attribute name="websiteNewWin" type="java.lang.Boolean" required="false"
    description="Open the website URL in a new window." %>

<%@ attribute name="showEmail" type="java.lang.Boolean" required="false"
    description="Show the contact email address." %>

<%@ attribute name="showImageCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the image copyright is displayed as image overlay. Default is 'false'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Enables the zoom option for the image." %>

<%@ attribute name="showVcard" type="java.lang.Boolean" required="false"
    description="Show link to a Vcard download for the contact." %>

<%@ attribute name="labelOption" type="java.lang.String" required="false"
    description="The option for the label display." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="The option for the link display." %>

<%@ attribute name="nameSuffix" type="java.lang.String" required="false"
    description="Suffix for the name. HTML in this will NOT be escaped." %>

<%@ attribute name="addTextBox" type="java.lang.Boolean" required="false"
    description="Generate a div class='text-box' wrapper around the generated output. Default is 'true'. " %>

<%@ attribute name="escapeXml" type="java.lang.Boolean" required="false"
    description="Controls if the generated text in headings is XML escaped. Default is 'true' if not provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="addressData"        value="${empty address ? data.value.AddressChoice : address}"/>
<c:set var="addTextBox"         value="${empty addTextBox ? true : addTextBox}"/>

<c:set var="hsize"              value="${empty hsize ? 3 : hsize}"/>
<c:set var="showName"           value="${showName and (not empty name)}"/>
<c:set var="showPosition"       value="${showPosition and (not empty position)}"/>
<c:set var="showImage"          value="${showImage and (not empty image)}" />
<c:set var="showOrganization"   value="${showOrganization and (not empty organization)}"/>
<c:set var="showAddressAlways"  value="${showAddressAlways and (not empty data or not empty addressData or not empty locData)}"/>
<c:set var="showAddress"        value="${showAddressAlways or (showAddress and (not empty data or not empty addressData or not empty locData))}"/>
<c:set var="showPhone"          value="${showPhone and (not empty data)}"/>
<c:set var="showWebsite"        value="${showWebsite and ((not empty data) and (not empty data.value.Website) or (not empty linkToWebsite))}"/>
<c:set var="showEmail"          value="${showEmail and (not empty data) and (not empty data.value.Email) and (not empty data.value.Email.value.Email)}"/>
<c:set var="escapeXml"          value="${empty escapeXml ? true : escapeXml}" />

<%-- Notice is by default displayed on top of address / phone / link. Optinal placement below can be enabled by setting overrides for a template variant. --%>
<c:set var="showNote"           value="${(not empty notice) and ((showNotice eq 'true') or (showNotice eq 'top') or (showNotice eq 'bottom'))}" />
<c:set var="showNoteTop"        value="${showNote and (showNotice ne 'bottom')}" />
<c:set var="showNoteBottom"     value="${showNote and not showNoteTop}" />

<%-- Description is by default displayed below address / phone / link. Optinal placement on top can be enabled by setting overrides for a template variant. --%>
<c:set var="showDesc"           value="${(not empty description) and ((showDescription eq 'true') or (showDescription eq 'top') or (showDescription eq 'bottom'))}" />
<c:set var="showDescTop"        value="${showDesc and (showDescription eq 'top')}" />
<c:set var="showDescBottom"     value="${showDesc and not showDescTop}" />

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<%-- #### This is not a choice since a value "label-text-label-icon" is also possible #### --%>
<c:if test="${fn:contains(labelOption, 'label-text')}">
    <c:set var="showTextLabels" value="${true}" />
</c:if>
<c:if test="${fn:contains(labelOption, 'label-icon')}">
    <c:set var="showIconLabels" value="${true}" />
</c:if>
<c:if test="${fn:contains(labelOption, 'label-min')}">
    <c:set var="showTextLabels" value="${true}" />
    <c:set var="showMinLabels" value="${true}" />
</c:if>

<c:if test="${not empty link}">
    <c:choose>
        <c:when test="${not empty linkOption and fn:contains(linkOption, 'button')}">
            <c:set var="showLinkAsButton" value="${true}" />
        </c:when>
        <c:when test="${linkOption eq 'text'}">
            <c:set var="showLinkAsText" value="${true}" />
        </c:when>
    </c:choose>
</c:if>

<%-- #### Contact exposed as 'Person' or 'Organization', see http://schema.org/ #### --%>
<c:choose>
    <c:when test="${showImage and (not empty imageTitle)}">
         <c:set var="imgtitle" value="${imageTitle eq 'none' ? null : imageTitle}" />
    </c:when>
    <c:when test="${showImage and (name ne null) and name.isSet}">
        <c:set var="persontxtname">
            <c:if test="${name.value.Title.isSet}">${name.value.Title}${' '}</c:if>
            <c:if test="${name.value.FirstName.isSet}">${name.value.FirstName}${' '}</c:if>
            <c:if test="${name.value.MiddleName.isSet}">${name.value.MiddleName}${' '}</c:if>
            <c:if test="${name.value.LastName.isSet}">${name.value.LastName}${' '}</c:if>
            <c:if test="${name.value.Suffix.isSet}">${' '}${name.value.Suffix}</c:if>
        </c:set>
        <c:choose>
            <c:when test="${kind eq 'pers'}">
                <c:set var="imgtitle" value="${persontxtname}" />
            </c:when>
            <c:when test="${kind eq 'org'}">
                <c:set var="imgtitle" value="${persontxtname} (${organization})" />
            </c:when>
        </c:choose>
    </c:when>
    <c:when test="${showImage and (not empty organization) and (kind eq 'org')}">
        <c:set var="imgtitle" value="${organization}" />
    </c:when>
</c:choose>

<m:image-animated
    image="${image}"
    test="${showImage}"
    title="${imgtitle}"
    showCopyright="${showImageCopyright}"
    ratio="${imageRatio}"
    ratioLg="${imageRatioLg}"
    cssImage="photo"
    showImageZoom="${showImageZoom}">

    <c:if test="${addTextBox}"><div class="text-box"></c:if>
    <m:nl />

    <c:if test="${showName and (kind ne 'poi')}">
        <c:set var="personname">
            <c:if test="${name.value.Title.isSet}">
                <span>${name.value.Title}${' '}</span><%----%>
            </c:if>
            <c:if test="${name.value.FirstName.isSet}">
                <span> ${name.value.FirstName}</span><%----%>
            </c:if>
            <c:if test="${name.value.MiddleName.isSet}">
                <span> ${name.value.MiddleName}</span><%----%>
            </c:if>
            <c:if test="${name.value.LastName.isSet}">
                <span> ${name.value.LastName}</span><%----%>
            </c:if>
            <c:if test="${name.value.Suffix.isSet}">
                <span> ${name.value.Suffix}</span><%----%>
            </c:if>
        </c:set>
    </c:if>

    <c:choose>
        <c:when test="${kind eq 'org'}">
            <c:if test="${showOrganization}">
                <m:heading level="${hsize}" css="fn n" text="${organization}" suffix="${nameSuffix}" ade="${false}" escapeXml="${escapeXml}" />
            </c:if>
            <c:if test="${showOrganization and (showName or showPosition)}">
                <%-- In case of organization 'showOrganization' means 'showContactPerson'  --%>
                <div class="subfn"><%----%>
                    <c:if test="${showName}">
                        <div class="h${hsize + 1} org"><%----%>
                            <m:link link="${linkToRelated}">${personname}</m:link>
                        </div><%----%>
                    </c:if>
                    <c:if test="${showPosition}"><%----%>
                        <div class="pos"><%----%>
                            ${position}
                        </div><%----%>
                    </c:if>
                </div><%----%>
            </c:if>
        </c:when>
        <c:when test="${kind eq 'poi'}">
            <c:if test="${showName}">
                <m:heading level="${hsize}" css="fn n" text="${name}" suffix="${nameSuffix}" ade="${false}"  escapeXml="${escapeXml}" />
            </c:if>
        </c:when>
        <c:otherwise>
            <c:if test="${showName}">
                <m:heading level="${hsize}" css="fn n" suffix="${nameSuffix}" ade="${false}" escapeXml="${escapeXml}">
                    <jsp:attribute name="markupText">${personname}</jsp:attribute>
                </m:heading>
                <c:if test="${showPosition}">
                    <div class="h${hsize + 1} pos subfn"><%----%>
                        ${position}
                    </div><%----%>
                </c:if>
            </c:if>
            <c:if test="${showOrganization}">
                <div class="org"><%----%>
                    <m:link link="${linkToRelated}">${organization}</m:link>
                </div><%----%>
            </c:if>
        </c:otherwise>
    </c:choose>

    <c:if test="${showNoteTop}">
        <div class="note top notice">${notice}</div><%----%>
    </c:if>

    <c:if test="${showDescTop}">
        <div class="note top description">${description}</div><%----%>
    </c:if>

    <c:if test="${showAddress or showFacilities}">
        <c:if test="${empty locData}">
            <m:location-vars data="${addressData}">
                <c:set var="markerData" value="${locData}" />
            </m:location-vars>
            <c:set var="locData" value="${markerData}" />
        </c:if>

        <c:if test="${showAddress}">
            <c:set var="animatedAddress" value="${not showAddressAlways}" />
            <m:div test="${animatedAddress}" css="clickme-showme adr-p">
                <div class="adr ${animatedAddress ? 'clickme' : ''}"><%----%>
                    <c:if test="${not empty locData.streetAddress}">
                        <div class="street-address">${locData.streetAddress}</div><%----%>
                    </c:if>
                    <c:if test="${not empty locData.extendedAddress}">
                        <div class="extended-address">${locData.extendedAddress}</div><%----%>
                    </c:if>
                    <c:if test="${(not empty locData.postalCode) or (not empty locData.locality)}">
                        <div><%----%>
                            <c:if test="${not empty locData.postalCode}">
                                <span class="postal-code">${locData.postalCode}</span>${' '}<%----%>
                            </c:if>
                            <c:if test="${not empty locData.locality}">
                                <span class="locality">${locData.locality}</span><%----%>
                            </c:if>
                        </div><%----%>
                    </c:if>
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
                <c:if test="${animatedAddress}">
                    <div class="addresslink showme"><%----%>
                        <c:choose>
                            <c:when test="${showIconLabels}">
                                <m:icon-prefix icon="home" showText="${true}" showIcon="${true}">
                                    <jsp:attribute name="text">
                                        <span class="${showTextLabels ? 'with-text' : 'only-icon'}"><a><%----%>
                                            <fmt:message key="msg.setting.contact.showAddress"/>
                                        </a></span><%----%>
                                    </jsp:attribute>
                                    <jsp:attribute name="icontitle">
                                        <fmt:message key="msg.setting.contact.showAddress"/>
                                    </jsp:attribute>
                                </m:icon-prefix>
                            </c:when>
                            <c:otherwise>
                                <a class="adr"><fmt:message key="msg.setting.contact.showAddress"/></a><%----%>
                            </c:otherwise>
                        </c:choose>
                    </div><%----%>
                </c:if>
            </m:div>
        </c:if>

        <c:if test="${showFacilities and (not empty locData.facilities)}">
            <m:facility-icons
                wheelchairAccess="${locData.facilities.value.WheelchairAccess.toBoolean}"
                hearingImpaired="${locData.facilities.value.HearingImpaired.toBoolean}"
                lowVision="${locData.facilities.value.LowVision.toBoolean}"
                publicRestrooms="${locData.facilities.value.PublicRestrooms.toBoolean}"
                publicRestroomsAccessible="${locData.facilities.value.PublicRestroomsAccessible.toBoolean}"
            />
        </c:if>
    </c:if>

    <c:if test="${showPhone}">
        <c:if test="${data.value.Phone.isSet}">
            <div class="phone tablerow"><%----%>
                <m:icon-prefix icon="phone" showText="${showTextLabels}" showIcon="${showIconLabels}">
                    <jsp:attribute name="text"><fmt:message key="msg.page.contact.phone"/></jsp:attribute>
                </m:icon-prefix>
                <span><%----%>
                    <a href="tel:${fn:replace(data.value.Phone, ' ','')}" ${data.rdfa.Phone}><%----%>
                        <span class="tel">${data.value.Phone}</span><%----%>
                    </a><%----%>
                </span><%----%>
            </div><%----%>
        </c:if>
        <c:if test="${data.value.Mobile.isSet}">
            <div class="mobile tablerow"><%----%>
                <m:icon-prefix icon="mobile" showText="${showTextLabels}" showIcon="${showIconLabels}">
                    <jsp:attribute name="text"><fmt:message key="msg.page.contact.mobile"/></jsp:attribute>
                </m:icon-prefix>
                <span><%----%>
                    <a href="tel:${fn:replace(data.value.Mobile, ' ','')}" ${data.rdfa.Mobile}><%----%>
                        <span class="tel">${data.value.Mobile}</span><%----%>
                    </a><%----%>
                </span><%----%>
            </div><%----%>
        </c:if>
        <c:if test="${data.value.Fax.isSet}">
            <div class="fax tablerow"><%----%>
                <m:icon-prefix icon="fax" showText="${showTextLabels}" showIcon="${showIconLabels}">
                    <jsp:attribute name="text"><fmt:message key="msg.page.contact.fax"/></jsp:attribute>
                </m:icon-prefix>
                <span><%----%>
                    <a href="tel:${fn:replace(data.value.Fax, ' ','')}" ${data.rdfa.Fax}><%----%>
                        <span class="tel">${data.value.Fax}</span><%----%>
                    </a><%----%>
                </span><%----%>
            </div><%----%>
        </c:if>
    </c:if>

    <c:if test="${showEmail}">
        <div class="${showMinLabels ? 'mail' : 'mail tablerow'}" ${data.rdfa.Email}><%----%>
            <c:if test="${not showMinLabels}">
                <m:icon-prefix icon="envelope-o" showText="${showTextLabels}" showIcon="${showIconLabels}">
                    <jsp:attribute name="text"><fmt:message key="msg.page.contact.email"/></jsp:attribute>
                </m:icon-prefix>
            </c:if>
            <span><%----%>
                <m:email email="${data.value.Email}" linkToForm="${linkToDetail}" />
            </span><%----%>
        </div><%----%>
    </c:if>

    <c:if test="${showWebsite}">
        <c:set var="websiteLink" value="${empty linkToWebsite ? data.value.Website : linkToWebsite}" />
        <c:choose>
            <c:when test="${websiteLink.isSet and websiteLink.value.URI.isSet}">
                <c:set var="websiteURL" value="${websiteLink.value.Text.isSet ? websiteLink.value.Text.toString : websiteLink.value.URI.toLink.toString}" />
                <c:set var="websiteNewWin" value="${websiteNewWin or websiteLink.value.NewWindow.toBoolean}" />
                <c:if test="${websiteLink.value.Text.isSet}">
                    <c:set var="websiteTitle" value="${websiteLink.value.Text.toString}" />
                </c:if>
            </c:when>
            <c:when test="${websiteLink.isSet and not empty websiteLink.toString}">
                    <c:set var="websiteURL" value="${websiteLink.toLink.toString}" />
            </c:when>
        </c:choose>
        <c:if test="${not empty websiteURL}">
            <c:if test="${not websiteLink.value.Text.isSet}">
                <c:if test="${fn:startsWith(websiteURL, '/')}">
                    <c:set var="websiteURL" value="${cms.site.url}${websiteURL}" />
                </c:if>
                <c:if test="${fn:endsWith(websiteURL, '/')}">
                    <c:set var="websiteURL" value="${fn:substring(websiteURL, 0, fn:length(websiteURL)-1)}"/>
                </c:if>
                <c:choose>
                    <c:when test="${fn:startsWith(websiteURL, 'https://')}">
                        <c:set var="websiteURL" value="${fn:trim(fn:substringAfter(websiteURL, 'https://'))}" />
                    </c:when>
                    <c:when test="${fn:startsWith(websiteURL, 'http://')}">
                        <c:set var="websiteURL" value="${fn:trim(fn:substringAfter(websiteURL, 'http://'))}" />
                    </c:when>
                </c:choose>
            </c:if>
            <div class="${showMinLabels ? 'website' : 'website tablerow'}"><%----%>
                    <c:if test="${not showMinLabels}">
                    <m:icon-prefix icon="globe" showText="${showTextLabels}" showIcon="${showIconLabels}">
                        <jsp:attribute name="text"><fmt:message key="msg.page.contact.website"/></jsp:attribute>
                    </m:icon-prefix>
                </c:if>
                ${showMinLabels ? '' : '<span>'}
                        <m:link link="${websiteLink}" newWin="${websiteNewWin}">${websiteURL}</m:link><%----%>
                ${showMinLabels ? '' : '</span>'}
            </div><%----%>
        </c:if>
    </c:if>

    <c:if test="${showNoteBottom}">
        <div class="note bottom notice">${notice}</div><%----%>
    </c:if>

    <c:if test="${showDescBottom}">
        <div class="note bottom description">${description}</div><%----%>
    </c:if>

    <c:if test="${showLinkAsText}">
        <div class="contactlink"><%----%>
            <m:link link="${link}" css="piece-text-link" newWin="${websiteNewWin}" />
        </div><%----%>
    </c:if>

    <c:if test="${showVcard}">
        <div class="vcard"><%----%>
            <a href="<cms:link>/system/modules/alkacon.mercury.template/elements/contact-vcf.jsp?id=${cms.element.id}</cms:link>"><%----%>
                <fmt:message key="msg.page.contact.vcard.download"/>
            </a><%----%>
        </div><%----%>
    </c:if>

    <c:if test="${showLinkAsButton}">
        <c:choose>
            <c:when test="${linkOption eq 'button-lg'}">
                <c:set var="btnClass" value="btn" />
            </c:when>
            <c:when test="${linkOption eq 'button-full'}">
                <c:set var="btnClass" value="btn btn-block" />
            </c:when>
            <c:otherwise>
                <c:set var="btnClass" value="btn btn-sm" />
            </c:otherwise>
        </c:choose>
        <m:link link="${link}" css="contactlink ${btnClass}" newWin="${websiteNewWin}" />
    </c:if>

    <c:if test="${addTextBox}"></div><m:nl /></c:if>

</m:image-animated>

</cms:bundle>