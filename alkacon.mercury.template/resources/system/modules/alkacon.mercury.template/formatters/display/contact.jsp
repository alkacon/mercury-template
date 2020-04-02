<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">
<mercury:teaser-settings content="${content}">

<c:set var="title"                  value="${value.Title}" />

<c:choose>
    <c:when test="${value.Kind.toString eq 'org'}">
        <c:set var="kind">itemscope itemtype="https://schema.org/Organization"</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="kind">itemscope itemtype="http://schema.org/Person"</c:set>
    </c:otherwise>
</c:choose>

<c:set var="compactLayout"          value="${setting.compactLayout.toBoolean ? 'compact ' : ''}" />
<c:set var="hsizeTitle"             value="${setHsize}" />
<c:set var="hsize"                  value="${title.isSet ? hsizeTitle + 1 : hsizeTitle}" />

<mercury:teaser-piece
    cssWrapper="type-contact ${compactLayout}${setEffect}${' '}${setCssWrapper}"
    attrWrapper="${kind}"
    headline="${title}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"

    teaserType="${displayType}"
    link="${setting.linkOption.toString ne 'none' ? value.Link : null}"
    hsize="${hsizeTitle}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <mercury:contact
                kind="${value.Kind.toString}"
                image="${value.Image}"
                name="${value.Name}"
                organization="${value.Organization}"
                imageRatio="${setRatio}"
                hsize="${hsize}"
                showImageCopyright="${setShowCopyright}"
                showImage="${true}"
            />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="markupBody">
        <mercury:contact
            kind="${value.Kind.toString}"
            name="${value.Name}"
            position="${value.Position}"
            organization="${value.Organization}"
            description="${value.Description}"
            data="${value.Contact}"
            labelOption="${setting.labels.toString}"
            hsize="${hsize}"
            showName="${true}"
            showPosition="${setting.showPosition.toBoolean}"
            showAddress="${setting.showAddress.toBoolean}"
            showAddressAlways="${setting.showAddress.toString eq 'always'}"
            showOrganization="${setting.showOrganization.toBoolean}"
            showDescription="${setting.showDescription.toBoolean}"
            showPhone="${setting.showPhone.toBoolean}"
            showWebsite="${setting.showWebsite.toBoolean}"
            showEmail="${setting.showEmail.toBoolean}"
            showVcard="${setting.showVcard.toBoolean}"
        />
    </jsp:attribute>

</mercury:teaser-piece>

</mercury:teaser-settings>
</cms:formatter>
</mercury:init-messages>