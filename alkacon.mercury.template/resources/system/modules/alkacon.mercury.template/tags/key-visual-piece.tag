<%@ tag pageEncoding="UTF-8"
    display-name="key-visual"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Generates a detail page key visual." %>


<%@ attribute name="showOverlay" type="java.lang.Boolean" required="false"
    description="Controls if the key visual is displayed as overlay.
    Default is 'false'." %>

<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="The image to display as key visual. Must be a nested image content."%>

<%@ attribute name="markupImage" fragment="true" required="false"
    description="Markup shown in case the visual is not an image.
    If both attributes 'markupVisual' and 'image' are provided, only the 'markupImage' will be displayed." %>

<%@ attribute name="markupHeading" fragment="true" required="false"
    description="Markup used for the heading if an overlay is generated." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="true"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="imageRatioXs" type="java.lang.String" required="false"
    description="Image ratio for small screens." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not? Default is 'false', because we assume a key visual is most likely 'above the fold'."%>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not? Default is 'true'." %>

<%@ attribute name="effect" type="java.lang.String" required="false"
    description="'class' atttributes to add to the key visual div for effects." %>

<%@ attribute name="showImageCopyright" type="java.lang.Boolean" required="true"
    description="Controls if the image copyright is displayed as image overlay." %>

<%@ attribute name="showImageSubtitle" type="java.lang.Boolean" required="true"
    description="Controls if the image subtitle is displayed below the image. Default is 'true'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="true"
    description="Controls if a zoom option for the image is displayed." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="true"
    description="Controls if ADE is enabled or not." %>

<%@ attribute name="intro" type="java.lang.Object" required="false"
    description="The optional intro text for the key visual." %>

<%@ attribute name="preface" type="java.lang.Object" required="false"
    description="The optional preface text for the key visual." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="effect" value="${(empty effect) or (effect eq 'none') ? '' : effect}" />
<c:set var="lazyLoad" value="${empty lazyLoad ? false : lazyLoad}" /><%-- assume that the key visual is "above the fold" by default --%>

<c:choose>
<c:when test="${showOverlay and image.value.Image.isSet}">
    <mercury:image-animated
        image="${image}"
        lazyLoad="${lazyLoad}"
        cssWrapper="overlay ${effect} "
        addEffectPiece="${true}"
        ade="${ade}"
        showCopyright="${showImageCopyright}"
        showImageZoom="${showImageZoom}"
        noScript="${noScript}"
        ratio="${imageRatio}"
        ratioXs="${imageRatioXs}" >

        <div class="visual-darken"></div><%----%>
        <div class="visual-overlay"><%----%>
            <jsp:invoke fragment="markupHeading"/>
        </div><%----%>
        <c:if test="${showImageSubtitle and not empty imageTitle}">
            <c:set var="visualSubtitle" value="${imageTitle}" />
        </c:if>

    </mercury:image-animated>
    <c:if test="${not empty visualSubtitle}">
        <div class="subtitle rs_skip" aria-hidden="true">${visualSubtitle}</div><%----%>
    </c:if>
</c:when>
<c:when test="${image.value.Image.isSet or not empty markupImage}">
    <c:choose>
        <c:when test="${not empty markupImage}">
            <jsp:invoke fragment="markupImage"/>
        </c:when>
        <c:otherwise>
            <mercury:image-animated
                image="${image}"
                lazyLoad="${lazyLoad}"
                cssWrapper="${effect}"
                addEffectPiece="${true}"
                ade="${ade}"
                showCopyright="${showImageCopyright}"
                showImageZoom="${showImageZoom}"
                noScript="${noScript}"
                ratio="${imageRatio}"
                ratioXs="${imageRatioXs}" >

                <c:if test="${showImageSubtitle and not empty imageTitle}">
                    <c:set var="visualSubtitle" value="${imageTitle}" />
                </c:if>
            </mercury:image-animated>
        </c:otherwise>
    </c:choose>
    <c:if test="${not empty visualSubtitle}">
        <div class="subtitle rs_skip" aria-hidden="true">${visualSubtitle}</div><%----%>
    </c:if>
</c:when>
</c:choose>