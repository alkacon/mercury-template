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


<%-- #### Contact exposed as 'Person', see http://schema.org/Person #### --%>

<c:choose>
    <c:when test="${value.Kind eq 'org'}">
        <c:set var="kind">itemscope itemtype="https://schema.org/Organization"</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="kind">itemscope itemtype="http://schema.org/Person"</c:set>
    </c:otherwise>
</c:choose>

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="pieceLayout"            value="${setting.pieceLayout.toInteger}" />
<c:set var="showImageZoom"          value="${setting.showImageZoom.toBoolean}" />
<c:set var="imageRatio"             value="${setting.imageRatio.toString}" />
<c:set var="showImage"              value="${(imageRatio ne 'no-img') and value.Image.value.Image.isSet}" />
<c:set var="effect"                 value="${showImage and setting.effect.isSetNotNone ? setting.effect.toString : null}" />
<c:set var="setSizeDesktop"         value="${setting.pieceSizeDesktop.toInteger}" />
<c:set var="setSizeMobile"          value="${setting.pieceSizeMobile.toInteger}" />

<c:set var="compactLayout"          value="${setting.compactLayout.toBoolean ? 'compact' : ''}" />
<c:set var="ade"                    value="${true}" />

<c:set var="hsizeTitle"             value="${hsize}" />
<c:set var="hsize"                  value="${value.Title.isSet ? hsize + 1 : hsize}" />

<mercury:nl />

<mercury:section-piece
    cssWrapper="element type-contact ${compactLayout}${' '}${cssWrapper}${empty effect ? '' : ' '.concat(effect)}"
    pieceLayout="${pieceLayout}"
    attrWrapper="${kind}"
    heading="${value.Title}"
    hsize="${hsizeTitle}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setSizeMobile}"
    ade="${false}">

    <jsp:attribute name="markupVisual">
        <c:if test="${showImage}">
            <mercury:contact
                kind="${value.Kind}"
                image="${value.Image}"
                name="${value.Name}"
                organization="${value.Organization}"
                imageRatio="${cms.element.settings.imageRatio}"
                link="${value.Link}"
                linkOption="${setting.linkOption.toString eq 'imageOverlay' ? 'imageOverlay' : ''}"
                hsize="${hsize}"
                showImage="${true}"
                showImageZoom="${showImageZoom}"
            />
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="markupText">
        <mercury:contact
            kind="${value.Kind}"
            link="${value.Link}"
            name="${value.Name}"
            position="${value.Position}"
            organization="${value.Organization}"
            description="${value.Description}"
            data="${value.Contact}"
            labelOption="${setting.labels.toString}"
            linkOption="${setting.linkOption.toString}"
            hsize="${hsize}"
            showName="${true}"
            showPosition="${setting.showPosition.toBoolean}"
            showAddress="${setting.showAddress.toString == 'true'}"
            showAddressAlways="${setting.showAddress.toString == 'always'}"
            showOrganization="${setting.showOrganization.toBoolean}"
            showDescription="${setting.showDescription.toBoolean}"
            showPhone="${setting.showPhone.toBoolean}"
            showWebsite="${setting.showWebsite.toBoolean}"
            showEmail="${setting.showEmail.toBoolean}"
            showVcard="${setting.showVcard.toBoolean}"
        />
    </jsp:attribute>
</mercury:section-piece>

</cms:formatter>
</mercury:init-messages>