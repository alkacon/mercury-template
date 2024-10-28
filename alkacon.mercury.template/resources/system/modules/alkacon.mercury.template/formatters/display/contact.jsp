<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<m:init-messages>

<cms:formatter var="content" val="value">
<m:teaser-settings content="${content}">

<c:set var="title"                  value="${value.Title}" />

<c:set var="compactLayout"          value="${setting.compactLayout.toBoolean ? ' compact' : ''}" />

<c:set var="showOrganization"       value="${setting.showOrganization.toBoolean or (setting.showOrganization.toString eq 'link')}" />
<c:set var="showOrganizationLink"   value="${showOrganization and (setting.showOrganization.toString eq 'link')}" />
<c:set var="showPosition"           value="${setting.showPosition.toBoolean}" />
<c:set var="showAddress"            value="${setting.showAddress.toString eq 'true'}" />
<c:set var="showAddressAlways"      value="${setting.showAddress.toString eq 'always'}" />
<c:set var="showTitle"              value="${setting.showTitle.toBoolean}" />
<c:set var="showNotice"             value="${setting.showNotice.toString}" />
<c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
<c:set var="showPhone"              value="${setting.showPhone.toBoolean}" />
<c:set var="showWebsite"            value="${setting.showWebsite.toBoolean}" />
<c:set var="showEmail"              value="${setting.showEmail.toBoolean}" />
<c:set var="showVcard"              value="${setting.showVcard.toBoolean}" />

<c:set var="linkTarget"             value="${setting.linkTarget.toString}" />
<c:set var="labelOption"            value="${setting.labels.toString}" />
<c:set var="websiteNewWin"          value="${setting.websiteNewWin.toBoolean}" />

<c:set var="hsizeTitle"             value="${setHsize}" />
<c:set var="hsize"                  value="${showTitle and title.isSet ? hsizeTitle + 1 : hsizeTitle}" />


<m:contact-vars
    content="${content}"
    showPosition="${showPosition}"
    showOrganization="${showOrganization}">

<c:set var="linkTarget"             value="${(setLinkOption ne 'none') and (linkTarget ne 'none') ? (linkTarget eq 'detail' ? linkToDetail : value.Link) : null}" />
<c:set var="image"                  value="${value.Image.isSet ? value.Image : (value.Paragraph.value.Image.isSet ? value.Paragraph.value.Image : null)}" />
<c:set var="description"            value="${value.Description.isSet ? value.Description : (value.Paragraph.value.Text.isSet ? value.Paragraph.value.Text : null)}" />


<m:teaser-piece
    cssWrapper="type-contact ${kindCss}${compactLayout}${setCssWrapperAll}"
    attrWrapper="${kind}"
    headline="${showTitle and (valName ne title) ? title : null}"
    headlineSuffix="${setOrderBadge}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"
    piecePreMarkup="${setElementPreMarkup}"

    teaserType="${displayType}"
    link="${linkTarget}"
    linkOption="${setLinkOption}"
    buttonText="${setButtonText}"
    hsize="${hsizeTitle}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <m:contact
                kind="${valKind}"
                image="${image}"
                name="${valKind eq 'org' ? null : valName}"
                organization="${valOrganization}"
                imageRatio="${setRatio}"
                imageRatioLg="${setRatioXs}"
                hsize="${hsize}"
                showImageCopyright="${setShowCopyright}"
                showImage="${true}"
            />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="markupBody">
        <m:contact
            kind="${valKind}"
            name="${valName}"
            position="${valPosition}"
            organization="${valOrganization}"
            notice="${value.Notice}"
            description="${description}"
            data="${value.Contact}"
            address="${valAddress}"
            labelOption="${labelOption}"
            linkToRelated="${showOrganizationLink ? valLinkToRelated : null}"
            linkToDetail="${linkToDetail}"
            linkToWebsite="${valLinkToWebsite}"
            hsize="${hsize}"
            showName="${setShowName}"
            showPosition="${setShowPosition}"
            showAddress="${showAddress}"
            showAddressAlways="${showAddressAlways}"
            showOrganization="${setShowOrganization}"
            showNotice="${showNotice}"
            showDescription="${showDescription}"
            showPhone="${showPhone}"
            showWebsite="${showWebsite}"
            websiteNewWin="${websiteNewWin}"
            showEmail="${showEmail}"
            showVcard="${showVcard}"
        />
    </jsp:attribute>

</m:teaser-piece>
</m:contact-vars>

</m:teaser-settings>
</cms:formatter>
</m:init-messages>