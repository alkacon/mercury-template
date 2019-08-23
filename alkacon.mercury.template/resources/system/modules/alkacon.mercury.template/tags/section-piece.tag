<%@tag
    pageEncoding="UTF-8"
    display-name="section"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a content section of paragraph." %>

<%@ attribute name="pieceLayout" type="java.lang.Integer" required="true"
    description="The layout option to generate. Valid values are 0 to 9.
    // 0. Heading, Image, Text, Link (full width)
    // 1. Image, Heading, Text, Link (full width)
    // 2. Heading on top, Image left, Text and Link right (separate column)
    // 3. Heading on top, Image right, Text and Link left (separate column)
    // 4. Heading on top, Image left, Text and Link right (floating around image)
    // 5. Heading on top, Image right, Text and Link left (floating around image)
    // 6. Image left, Heading, Text and Link right (separate column)
    // 7. Image right, Heading, Text and Link left (separate column)
    // 8. Image left, Heading, Text and Link right (floating around image)
    // 9. Image right, Heading, Text and Link left (floating around image)
    " %>

<%@ attribute name="sizeMobile" type="java.lang.Integer" required="false"
    description="Mobile grid size for the visual. Valid values are 1 to 12. Default is 7." %>

<%@ attribute name="sizeDesktop" type="java.lang.Integer" required="false"
    description="Desktop grid size for the visual if displayed in a column. Valid values are 1 to 12. Default is 4." %>

<%@ attribute name="heading" type="java.lang.Object" required="false"
    description="The optional section heading." %>

<%@ attribute name="image" type="java.lang.Object" required="false"
    description="The image to display as visual." %>

<%@ attribute name="text" type="java.lang.Object" required="false"
    description="The optional section text." %>

<%@ attribute name="link" type="java.lang.Object" required="false"
    description="The optional section link." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the section heading." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio,
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' selectors to add to the generated div surrounding the section." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attributes to add to the generated div surrounding section." %>

<%@ attribute name="textOption" type="java.lang.String" required="false"
    description="Controls if the tag body text is displayed or not. Default is 'Display as normal text'." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="Controls if and how the link is displayed. Default is 'button'." %>

<%@ attribute name="headingOption" type="java.lang.String" required="false"
    description="Controls how the heading is displayed. Default is 'full'." %>

<%@ attribute name="showImageCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the image copyright is displayed as image overlay. Default is 'true'." %>

<%@ attribute name="showImageSubtitle" type="java.lang.Boolean" required="false"
    description="Controls if the image subtitle is displayed below the image. Default is 'true'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Controls if a zoom option for the image is displayed. Default is 'true'." %>

<%@ attribute name="showImageLink" type="java.lang.Boolean" required="false"
    description="Controls if image is linked or not. Default is 'false'." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Controls if ADE is enabled or not. Default is 'true'." %>

<%@ attribute name="emptyWarning" type="java.lang.Boolean" required="false"
    description="If 'true', a warning is shown in offline mode in case no content has been generated. Default is 'true'." %>

<%@ attribute name="markupVisual" fragment="true" required="false"
    description="Markup shown for the visual if the visual is not an image.
    If both attributes 'markupVisual' and 'image' are provided, only the 'markupVisual' will be displayed." %>

<%@ attribute name="markupText" fragment="true" required="false"
    description="Markup shown for the text if the text is not an XML content value.
    If both attributes 'markupText' and 'text' are provided, only the 'markupText' will be displayed." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="ade"                value="${empty ade ? true : ade}" />
<c:set var="linkHeading"        value="${empty linkOption or empty link ? false : (linkOption eq 'heading')}" />
<c:set var="hsize"              value="${empty hsize ? 2 : (hsize < 1 ? (linkHeading ? 3 : hsize) : hsize)}" />
<c:set var="showText"           value="${empty text and empty markupText ? false : (empty textOption ? true : (textOption ne 'none'))}" />
<c:set var="showVisual"         value="${empty image and empty markupVisual ? false : (empty sizeDesktop ? true : sizeDesktop != 0)}" />
<c:set var="showHeading"        value="${empty heading or (hsize < 1) ? false : (empty headingOption ? true : (headingOption ne 'none'))}" />
<c:set var="showLinkOption"     value="${empty linkOption or linkHeading ? true : (linkOption ne 'none') and (linkOption ne 'false') }" />
<c:set var="showLink"           value="${empty link or linkHeading ? false : showLinkOption}" />
<c:set var="defaultText"        value="${showText and empty markupText}" />

<c:choose>
<c:when test="${showHeading or showText or showVisual or showLink}">
    <mercury:piece
        cssWrapper="${cssWrapper}"
        pieceLayout="${pieceLayout}"
        sizeDesktop="${sizeDesktop}"
        sizeMobile="${sizeMobile}"
        cssText="${showText and (textOption ne 'default') ? textOption: ''}"
        attrVisual="${ade ? image.rdfaAttr : null}"
        attrBody="${ade and showLinkOption and (empty link or (link.exists and not link.isSet)) ? link.rdfaAttr : null}"
        cssBody="${defaultText ? 'default' :_null}"
        attrText="${ade ? text.rdfaAttr : null}"
        attrLink="${ade ? link.rdfaAttr : null}">

        <jsp:attribute name="heading">
            <c:if test="${showHeading}">
                <mercury:link link="${link}" css="piece-heading-link" test="${linkHeading}">
                    <mercury:heading text="${heading}" level="${hsize}" ade="${linkHeading ? false : ade}" css="piece-heading" />
                </mercury:link>
            </c:if>
        </jsp:attribute>

        <jsp:attribute name="visual">
            <c:choose>
                <c:when test="${showVisual and empty markupVisual}">
                    <c:set var="showImageLink"  value="${empty showImageLink ? false : showImageLink}" />
                    <c:set var="showImageZoom" value="${empty showImageZoom ? true : showImageZoom}" />
                    <mercury:link link="${link}" test="${showImageLink}" setTitle="${true}" >
                        <mercury:image-animated
                            image="${image}"
                            ratio="${imageRatio}"
                            setTitle="${not showImageLink}"
                            showImageZoom="${showImageZoom}"
                            ade="${ade}">
                            <c:if test="${showImageCopyright and not empty imageCopyright}">
                                <div class="copyright"><div>${imageCopyright}</div></div><%----%>
                            </c:if>
                            <c:set var="imageSubtext">
                                <c:if test="${showImageSubtitle and not empty imageTitle}">
                                    <div class="subtitle">${imageTitle}</div><%----%>
                                </c:if>
                            </c:set>
                            <c:set var="emptyImage" value="${empty imageBean}" />
                        </mercury:image-animated>
                    </mercury:link>
                    <c:out value="${imageSubtext}" escapeXml="false" />
                </c:when>
                <c:when test="${showVisual}">
                    <jsp:invoke fragment="markupVisual"/>
                </c:when>
            </c:choose>
        </jsp:attribute>

        <jsp:attribute name="text">
            <c:choose>
                <c:when test="${defaultText}">
                    <c:out value="${text}" escapeXml="false" />
                </c:when>
                <c:when test="${showText}">
                    <jsp:invoke fragment="markupText"/>
                </c:when>
            </c:choose>
        </jsp:attribute>

        <jsp:attribute name="link">
            <c:if test="${showLink}">
                <c:choose>
                    <c:when test="${linkOption eq 'button-full'}">
                        <c:set var="linkCss" value="btn btn-block piece-btn" />
                    </c:when>
                    <c:when test="${linkOption eq 'text'}">
                        <c:set var="linkCss" value="piece-text-link" />
                    </c:when>
                    <c:otherwise>
                        <%-- default is 'button' --%>
                        <c:set var="linkCss" value="btn piece-btn" />
                    </c:otherwise>
                </c:choose>
                <mercury:link link="${link}" css="${linkCss}"/>
            </c:if>
        </jsp:attribute>

    </mercury:piece>
</c:when>
<c:when test="${cms.isEditMode and (empty emptyWarning or emptyWarning)}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <mercury:alert type="warning">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.section.empty.head" />
            </jsp:attribute>
            <jsp:attribute name="text">
                <div><fmt:message key="msg.page.section.empty.text" /></div>
                <div class="small">${cms.element.sitePath}</div>
            </jsp:attribute>
        </mercury:alert>
    </cms:bundle>
</c:when>
</c:choose>