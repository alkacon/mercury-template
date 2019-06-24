<%@ tag
    pageEncoding="UTF-8"
    display-name="contact"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays contact information from the given content with support for schema.org annotation." %>

<%@ attribute name="kind" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact kind. Standard string." %>

<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact image data." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="link" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact link." %>

<%@ attribute name="name" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact name. From nested schema type contact-name." %>

<%@ attribute name="position" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact position." %>

<%@ attribute name="organization" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact organization." %>

<%@ attribute name="description" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact description." %>

<%@ attribute name="data" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="Value wrapper for the contact data that includes address, telephone etc. From nested schema type contact-data." %>

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

<%@ attribute name="showDescription" type="java.lang.Boolean" required="false"
    description="Show the contact description." %>

<%@ attribute name="showAddress" type="java.lang.Boolean" required="false"
    description="Show the contact address." %>

<%@ attribute name="showAddressAlways" type="java.lang.Boolean" required="false"
    description="Always show the contact address." %>

<%@ attribute name="showPhone" type="java.lang.Boolean" required="false"
    description="Show the contact phone number." %>

<%@ attribute name="showWebsite" type="java.lang.Boolean" required="false"
    description="Show the contact website URL." %>

<%@ attribute name="showEmail" type="java.lang.Boolean" required="false"
    description="Show the contact email address." %>

<%@ attribute name="showVcard" type="java.lang.Boolean" required="false"
    description="Show link to a Vcard download for the contact." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Enables the zoom option for the image." %>

<%@ attribute name="labelOption" type="java.lang.String" required="false"
    description="The option for the label display." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="The option for the link display." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="hsize"              value="${empty hsize ? 3 : hsize}"/>
<c:set var="showName"           value="${showName and name.isSet}"/>
<c:set var="showImage"          value="${showImage and image.isSet}" />
<c:set var="showOrganization"   value="${showOrganization and organization.isSet}"/>
<c:set var="showDescription"    value="${showDescription and description.isSet}"/>
<c:set var="showAddressAlways"  value="${showAddressAlways and data.isSet}"/>
<c:set var="showAddress"        value="${showAddressAlways or (showAddress and data.isSet)}"/>
<c:set var="showPhone"          value="${showPhone and data.isSet}"/>
<c:set var="showWebsite"        value="${showWebsite and data.isSet and data.value.Website.isSet}"/>
<c:set var="showEmail"          value="${showEmail and data.isSet and data.value.Email.isSet and data.value.Email.value.Email.isSet}"/>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<%-- #### This is not choice since a value "label-text-label-icon" is also possible #### --%>
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

<c:if test="${link.isSet}">
    <c:choose>
        <c:when test="${linkOption eq 'button'}">
            <c:set var="showLinkAsButton" value="${true}" />
        </c:when>
        <c:when test="${linkOption eq 'text'}">
            <c:set var="showLinkAsText" value="${true}" />
        </c:when>
    </c:choose>
</c:if>

<%-- #### Contact exposed as 'Person' or 'Organization', see http://schema.org/ #### --%>
<c:if test="${showImage and name.isSet}">
    <c:set var="persontxtname">
        <c:if test="${name.value.Title.isSet}">${name.value.Title}${' '}</c:if>
        ${name.value.FirstName}${' '}
        <c:if test="${name.value.MiddleName.isSet}">${name.value.MiddleName}${' '}</c:if>
        ${name.value.LastName}
        <c:if test="${name.value.Suffix.isSet}">${' '}${name.value.Suffix}</c:if>
    </c:set>
    <c:choose>
        <c:when test="${kind eq 'person'}">
            <c:set var="imgtitle" value="${persontxtname}" />
        </c:when>
        <c:when test="${kind eq 'org'}">
            <c:set var="imgtitle" value="${persontxtname} (${organization})" />
        </c:when>
    </c:choose>
</c:if>

<mercury:image-animated
    image="${image}"
    test="${showImage}"
    title="${imgtitle}"
    ratio="${imageRatio}"
    cssImage="photo"
    attrImage='itemprop="image"'
    showImageZoom="${showImageZoom}"
>

    <c:if test="${showName or showOrganization or showDescription or showAddress or showPhone or showEmail or showLinkAsButton}">
        <div class="text-box">
<%----%>

            <c:set var="personname">
                <c:if test="${name.value.Title.isSet}"><span itemprop="honorificPrefix" ${name.value.Title.rdfaAttr}>${name.value.Title} </span></c:if>
                <span itemprop="givenName" ${name.value.FirstName.rdfaAttr}> ${name.value.FirstName}</span><%----%>
                <c:if test="${name.value.MiddleName.isSet}"><span itemprop="additionalName" ${name.value.MiddleName.rdfaAttr}> ${name.value.MiddleName}</span></c:if>
                <span itemprop="familyName" ${name.value.LastName.rdfaAttr}> ${name.value.LastName}</span><%----%>
                <c:if test="${name.value.Suffix.isSet}"><span itemprop="honorificSuffix"  ${name.value.Suffix.rdfaAttr}> ${name.value.Suffix}</span></c:if>
            </c:set>

            <c:choose>
                <c:when test="${kind eq 'org'}">
                    <c:choose>
                        <c:when test="${showOrganization}">
                            <mercury:heading level="${hsize}" css="fn n" attr="itemprop='name'" text="${organization}" ade="${true}"/>
                            <c:if test="${showPosition and position.isSet}">
                                <div class="h${hsize + 1} pos" itemprop="description" class="title" ${position.rdfaAttr}><%----%>
                                    ${position}
                                </div><%----%>
                            </c:if>
                        </c:when>
                        <c:when test="${not showOrganization and organization.isSet and showAddress}">
                            <mercury:heading level="${hsize}" css="fn n disp-n" attr="itemprop='name'" text="${organization}" ade="${false}"/>
                        </c:when>
                    </c:choose>
                    <c:if test="${showName}">
                        <div class="org" itemprop="employee" itemscope itemtype="http://schema.org/Person">${personname}</div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <c:if test="${showName}">
                        <mercury:heading level="${hsize}" css="fn n" attr="itemprop='name'" ade="${false}">
                            <jsp:attribute name="markupText">${personname}</jsp:attribute>
                        </mercury:heading>
                        <c:if test="${showPosition and position.isSet}">
                            <div class="h${hsize + 1} pos" itemprop="description" class="title" ${position.rdfaAttr}><%----%>
                                ${position}
                            </div><%----%>
                        </c:if>
                    </c:if>
                    <c:if test="${showOrganization}">
                        <div class="org" itemprop="worksFor" ${organization.rdfaAttr}>${organization}</div><%----%>
                    </c:if>
                </c:otherwise>
            </c:choose>

            <c:if test="${showAddress}">
                <mercury:location-data data="${data.value.AddressChoice}">

                    <c:set var="animatedAddress" value="${not showAddressAlways}" />
                    <div ${animatedAddress ? 'class="clickme-showme"' : ''}><%----%>
                        <div class="adr ${animatedAddress ? 'clickme' : ''}" <%--
                        --%>itemprop="address" itemscope <%--
                        --%>itemtype="http://schema.org/PostalAddress"><%----%>
                            <div itemprop="streetAddress" class="street-address">${locData.streetAddress}</div><%----%>
                            <c:if test="${not empty locData.extendedAddress}">
                                <div itemprop="streetAddress" class="extended-address">${locData.extendedAddress}</div><%----%>
                            </c:if>
                            <div><%----%>
                                <span itemprop="postalCode" class="postal-code">${locData.postalCode}</span>${' '}<%----%>
                                <span itemprop="addressLocality" class="locality">${locData.locality}</span><%----%>
                            </div><%----%>
                            <c:if test="${(not empty locData.region) or (not empty locData.country)}">
                                <div><%----%>
                                    <c:if test="${not empty locData.region}">
                                        <span itemprop="addressRegion" class="region">${locData.region}${' '}</span><%----%>
                                    </c:if>
                                    <c:if test="${not empty locData.country}">
                                        <span itemprop="addressCountry" class="country-name">${locData.country}</span><%----%>
                                    </c:if>
                                </div><%----%>
                            </c:if>
                        </div><%----%>
                        <c:if test="${animatedAddress}">
                            <div class="addresslink showme"><%----%>
                                <c:choose>
                                    <c:when test="${showIconLabels}">
                                        <mercury:icon-prefix icon="home" showText="${true}" showIcon="${true}">
                                            <jsp:attribute name="text">
                                                <span class="${showTextLabels ? 'with-text' : 'only-icon'}"><a><%----%>
                                                    <fmt:message key="msg.setting.contact.showAddress"/>
                                                </a></span><%----%>
                                            </jsp:attribute>
                                            <jsp:attribute name="icontitle">
                                                <fmt:message key="msg.setting.contact.showAddress"/>
                                            </jsp:attribute>
                                        </mercury:icon-prefix>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="adr"><fmt:message key="msg.setting.contact.showAddress"/></a><%----%>
                                    </c:otherwise>
                                </c:choose>
                            </div><%----%>
                        </c:if>
                    </div><%----%>
                </mercury:location-data>
            </c:if>

            <c:if test="${showPhone}">
                <c:if test="${data.value.Phone.isSet}">
                    <div class="phone tablerow"><%----%>
                        <mercury:icon-prefix icon="phone" showText="${showTextLabels}" showIcon="${showIconLabels}">
                            <jsp:attribute name="text"><fmt:message key="msg.page.contact.phone"/></jsp:attribute>
                        </mercury:icon-prefix>
                        <span><%----%>
                            <a href="tel:${fn:replace(data.value.Phone, ' ','')}" ${data.rdfa.Phone}><%----%>
                                <span itemprop="telephone" class="tel">${data.value.Phone}</span><%----%>
                            </a><%----%>
                        </span><%----%>
                    </div><%----%>
                </c:if>
                <c:if test="${data.value.Mobile.isSet}">
                    <div class="mobile tablerow"><%----%>
                        <mercury:icon-prefix icon="mobile" showText="${showTextLabels}" showIcon="${showIconLabels}">
                            <jsp:attribute name="text"><fmt:message key="msg.page.contact.mobile"/></jsp:attribute>
                        </mercury:icon-prefix>
                        <span><%----%>
                            <a href="tel:${fn:replace(data.value.Mobile, ' ','')}" ${data.rdfa.Mobile}><%----%>
                                <span itemprop="telephone" class="tel">${data.value.Mobile}</span><%----%>
                            </a><%----%>
                        </span><%----%>
                    </div><%----%>
                </c:if>
                <c:if test="${data.value.Fax.isSet}">
                    <div class="fax tablerow"><%----%>
                        <mercury:icon-prefix icon="fax" showText="${showTextLabels}" showIcon="${showIconLabels}">
                            <jsp:attribute name="text"><fmt:message key="msg.page.contact.fax"/></jsp:attribute>
                        </mercury:icon-prefix>
                        <span><%----%>
                            <a href="tel:${fn:replace(data.value.Fax, ' ','')}" ${data.rdfa.Fax}><%----%>
                                <span itemprop="faxNumber" class="tel">${data.value.Fax}</span><%----%>
                            </a><%----%>
                        </span><%----%>
                    </div><%----%>
                </c:if>
            </c:if>

            <c:if test="${showEmail}">
                <div class="${showMinLabels ? 'mail' : 'mail tablerow'}" ${data.rdfa.Email}><%----%>
                    <c:if test="${not showMinLabels}">
                        <mercury:icon-prefix icon="envelope-o" showText="${showTextLabels}" showIcon="${showIconLabels}">
                            <jsp:attribute name="text"><fmt:message key="msg.page.contact.email"/></jsp:attribute>
                        </mercury:icon-prefix>
                    </c:if>
                    <mercury:email email="${data.value.Email}">
                        <jsp:attribute name="placeholder"><fmt:message key="msg.page.contact.obfuscatedemail"/></jsp:attribute>
                    </mercury:email>
                </div><%----%>
            </c:if>

            <c:set var="linkattr">itemprop="url"</c:set>
            <c:if test="${showWebsite}">
                <div class="${showMinLabels ? 'website' : 'website tablerow'}"><%----%>
                     <c:if test="${not showMinLabels}">
                        <mercury:icon-prefix icon="globe" showText="${showTextLabels}" showIcon="${showIconLabels}">
                            <jsp:attribute name="text"><fmt:message key="msg.page.contact.website"/></jsp:attribute>
                        </mercury:icon-prefix>
                    </c:if>
                    <span><%----%>
                         <mercury:link link="${data.value.Website}" attr="${linkattr}">${data.value.Website.toLink}</mercury:link><%----%>
                    </span><%----%>
                </div><%----%>
                <c:set var="linkattr" value="" />
            </c:if>

            <c:if test="${showDescription}">
                <div itemprop="description" class="note" ${description.rdfaAttr}>${description}</div><%----%>
            </c:if>

            <c:if test="${showLinkAsText}">
                <div class="contactlink"><%----%>
                    <mercury:link link="${link}" attr="${linkattr}" />
                </div><%----%>
            </c:if>

            <c:if test="${showVcard}">
                <div class="vcard"><%----%>
                    <a href="<cms:link>/system/modules/alkacon.mercury.template/elements/contact.vcf?id=${cms.element.id}</cms:link>"><%----%>
                        <fmt:message key="msg.page.contact.vcard.download"/>
                    </a><%----%>
                </div><%----%>
            </c:if>

            <c:if test="${showLinkAsButton}">
                <mercury:link link="${link}" css="contactlink btn btn-sm" attr="${linkattr}" />
            </c:if>

        </div>
<%----%>
    </c:if>
</mercury:image-animated>
</cms:bundle>