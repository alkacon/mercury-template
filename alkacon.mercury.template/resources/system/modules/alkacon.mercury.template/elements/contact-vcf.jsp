<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="uid" value="${cms:convertUUID(param.id)}" />
<c:set var="content" value="${cms.vfs.xml[uid]}" />
<c:set var="value" value="${content.value}" />

<m:contact-vars
    content="${content}"
    showPosition="${showPosition}"
    showOrganization="${showOrganization}">

<c:choose>
    <c:when test="${valKind eq 'org'}">
        <c:set var="fullname" value="${value.Organization}" />
        <c:set var="kind" value="organization" />
    </c:when>
    <c:when test="${valKind eq 'poi'}">
        <c:set var="fullname" value="${value.Title}" />
        <c:set var="kind" value="location" />
    </c:when>
    <c:otherwise>
        <c:set var="fullname">
            ${value.Name.value.Title}${' '}
            ${value.Name.value.FirstName}${' '}
            ${value.Name.value.MiddleName}${' '}
            ${value.Name.value.LastName}${' '}
            ${value.Name.value.Suffix}
        </c:set>
        <c:set var="kind" value="individual" />
    </c:otherwise>
</c:choose>

<m:set-content-disposition name="${fullname}" suffix=".vcf" /><%--

--%>
BEGIN:VCARD
VERSION:3.0<%--

--%>
FN;CHARSET=utf-8:${fullname}<%--

--%>
N;CHARSET=utf-8:${value.Name.value.LastName}${';'}
${value.Name.value.FirstName}${';'}
${value.Name.value.MiddleName}${';'}
${value.Name.value.Title}${';'}
${value.Name.value.Suffix}<%--

--%>
KIND:${kind}

<c:if test="${value.Organization.isSet}">
ORG;CHARSET=utf-8:${value.Organization}
</c:if><%--

--%>

<c:if test="${value.Position.isSet}">
TITLE;CHARSET=utf-8:${value.Position}
</c:if>
<m:location-vars data="${valKind ne 'poi' ? value.Contact.value.AddressChoice : content}">

ADR;CHARSET=utf-8;type=WORK:;;${locData.streetAddress}${';'}
${locData.locality}${';'}
${locData.region}${';'}
${locData.postalCode}${';'}
${locData.country}

</m:location-vars>

<c:if test="${value.Image.isSet}">
<m:image-vars image="${value.Image}">
<c:if test="${not empty imageLink}">
PHOTO;TYPE=JPEG:${cms.requestContext.requestMatcher}<cms:link>${imageLink}</cms:link>
</c:if>
</m:image-vars>
</c:if>

<c:if test="${not empty value.Contact.value.Phone}">
TEL;type=WORK;type=VOICE:${value.Contact.value.Phone}
</c:if>

<c:if test="${not empty value.Contact.value.Mobile}">
TEL;type=CELL;type=VOICE:${value.Contact.value.Mobile}
</c:if>

<c:if test="${not empty value.Contact.value.Fax}">
TEL;type=WORK;type=FAX:${value.Contact.value.Fax}
</c:if>

<c:if test="${not empty value.Contact.value.Website}">
URL:${value.Contact.value.Website}
</c:if>

<c:if test="${not empty value.Contact.value.Email and not empty value.Contact.value.Email.value.Email}">
EMAIL;type=INTERNET;type=WORK:${value.Contact.value.Email.value.Email}
</c:if>

<c:if test="${not empty value.Description}">
NOTE;CHARSET=utf-8:${cms:escapeJavaScript(cms:stripHtml(value.Description))}
</c:if>

<c:choose>
    <c:when test="${valKind eq 'org'}">
X-ABShowAs:COMPANY
    </c:when>
    <c:otherwise>
    </c:otherwise>
</c:choose><%--

--%>
END:VCARD

</m:contact-vars>
