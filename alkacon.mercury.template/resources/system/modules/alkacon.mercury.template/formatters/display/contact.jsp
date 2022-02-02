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

<c:set var="compactLayout"          value="${setting.compactLayout.toBoolean ? ' compact' : ''}" />
<c:set var="hsizeTitle"             value="${setHsize}" />
<c:set var="hsize"                  value="${title.isSet ? hsizeTitle + 1 : hsizeTitle}" />

<c:set var="showOrganization"       value="${setting.showOrganization.toBoolean}" />
<c:set var="showName"               value="${setting.showName.useDefault('true').toBoolean}" />
<c:set var="showPosition"           value="${setting.showPosition.toBoolean}" />
<c:set var="showAddress"            value="${setting.showAddress.toString eq 'true'}" />
<c:set var="showAddressAlways"      value="${setting.showAddress.toString eq 'always'}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showPhone"              value="${setting.showPhone.toBoolean}" />
<c:set var="showWebsite"            value="${setting.showWebsite.toBoolean}" />
<c:set var="showEmail"              value="${setting.showEmail.toBoolean}" />
<c:set var="showVcard"              value="${setting.showVcard.toBoolean}" />

<c:set var="labelOption"            value="${setting.labels.toString}" />
<c:set var="websiteNewWin"          value="${setting.websiteNewWin.toBoolean}" />

<c:set var="valKind"                value="${value.Kind.isSet ? value.Kind : setting.schemaKind.toString}" /><%-- Note: '.useDefault()' does not work in lists --%>

<mercury:contact-vars
    content="${content}"
    kind="${valKind}"
    showName="${showName}"
    showPosition="${showPosition}"
    showOrganization="${showOrganization}">

<mercury:teaser-piece
    cssWrapper="type-contact ${kindCss}${compactLayout}${setCssWrapper}${setEffect}"
    attrWrapper="${kind}"
    headline="${title}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"

    teaserType="${displayType}"
    link="${setting.linkOption.toString ne 'none' ? value.Link : null}"
    linkOption="${setLinkOption}"
    hsize="${hsizeTitle}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <mercury:contact
                kind="${valKind}"
                image="${value.Image}"
                name="${valName}"
                organization="${valOrganization}"
                imageRatio="${setRatio}"
                hsize="${hsize}"
                showImageCopyright="${setShowCopyright}"
                showImage="${true}"
            />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="markupBody">
        <mercury:contact
            kind="${valKind}"
            name="${valName}"
            position="${valPosition}"
            organization="${valOrganization}"
            description="${value.Description}"
            data="${value.Contact}"
            address="${valAddress}"
            labelOption="${labelOption}"
            hsize="${hsize}"
            showName="${setShowName}"
            showPosition="${setShowPosition}"
            showAddress="${showAddress}"
            showAddressAlways="${showAddressAlways}"
            showOrganization="${setShowOrganization}"
            showDescription="${showDescription}"
            showPhone="${showPhone}"
            showWebsite="${showWebsite}"
            websiteNewWin="${websiteNewWin}"
            showEmail="${showEmail}"
            showVcard="${showVcard}"
        />
    </jsp:attribute>

</mercury:teaser-piece>
</mercury:contact-vars>

</mercury:teaser-settings>
</cms:formatter>
</mercury:init-messages>