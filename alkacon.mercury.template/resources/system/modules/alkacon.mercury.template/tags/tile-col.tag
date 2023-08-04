<%@tag pageEncoding="UTF-8"
    display-name="tile-col"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a tile-col image tile." %>


<%@ attribute name="tileWrapper" type="java.lang.String" required="false"
    description="'class' selectors added to the generated outer div for the tile." %>

<%@ attribute name="boxWrapper" type="java.lang.String" required="false"
    description="'class' selectors added to the generated inner div.content-box. Must start with a space ' ' if not empty." %>

<%@ attribute name="overlayWrapper" type="java.lang.String" required="false"
    description="If set, the tile is rendered as 'full overlay' with this wrapper added to the tile text." %>

<%@ attribute name="heading" type="java.lang.Object" required="false"
    description="The optional tile heading." %>

<%@ attribute name="text" type="java.lang.Object" required="false"
    description="The optional tile text." %>

<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="The image to use for the tile. Must be a nested image content value wrapper."%>

<%@ attribute name="link" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="The optional tile link. Must be a link value wrapper."%>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the tile heading." %>

<%@ attribute name="textAlignment" type="java.lang.String" required="false"
    description="Controls the alignment of the text elements. Default is left aligned." %>

<%@ attribute name="textOption" type="java.lang.String" required="false"
    description="Controls if the tag body text is displayed or not. Default is 'Display as normal text'." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="Controls if and how the link is displayed. Default is 'hide'." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio. Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="showImageCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the image copyright is displayed as image overlay. Default is 'false'." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated content. Default is 'false' if not provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:choose>
    <c:when test="${overlayWrapper eq 'boxbg'}">
        <c:set var="fullOverlay"        value="${true}" />
        <c:set var="fullOverlayCss"     value="full-overlay boxbg-overlay" />
    </c:when>
    <c:when test="${overlayWrapper eq 'true'}">
        <c:set var="fullOverlay"        value="${true}" />
        <c:set var="fullOverlayCss"     value="full-overlay" />
    </c:when>
    <c:otherwise>
        <c:set var="fullOverlay"        value="${false}" />
    </c:otherwise>
</c:choose>

<c:set var="linkFullTile"       value="${empty linkFullTile or linkFullTile}" />
<c:set var="linkOption"         value="${empty linkOption ? 'hide' : linkOption}" />
<c:set var="linkFullTile"       value="${(linkOption ne 'hide') and link.isSet and (not (fullOverlay and (linkOption ne 'none')))}" />

<mercury:nl />
<div class="${tileWrapper}"><%----%>

    <div class="content-box ${boxWrapper}"><%----%>

        <mercury:link link="${value.Link}" test="${linkFullTile}">

            <c:choose>
                <c:when test="${not empty image}">
                    <cms:addparams>
                        <cms:param name="cssgrid" value="${tileClass}" />
                        <mercury:image-animated
                            image="${image}"
                            ratio="${imageRatio}"
                            addEffectBox="${true}"
                            ade="${ade and not linkFullTile}"
                            title="${heading}">
                            <c:set var="imageCopyright" value="${imageCopyrightHtml}" scope="request" />
                        </mercury:image-animated>
                    </cms:addparams>
                </c:when>
                <c:otherwise>
                    <mercury:padding-box ratio="${imageRatio}" defaultRatio="4-3" />
                </c:otherwise>
            </c:choose>

            <c:set var="tileText">
                <mercury:section-piece
                    cssWrapper="${textAlignment}"
                    heading="${heading}"
                    pieceLayout="${1}"
                    text="${text}"
                    link="${link}"
                    hsize="${hsize}"
                    linkOption="${fullOverlay and (linkOption ne 'hide') ? linkOption : 'none'}"
                    textOption="${textOption}"
                    ade="${ade and not linkFullTile}"
                    emptyWarning="${false}"
                />
            </c:set>

            <c:if test="${not empty tileText}">
                <div class="${fullOverlay ? fullOverlayCss : 'text-overlay'}"><%----%>
                    ${tileText}
                </div><%----%>
            </c:if>

            <c:if test="${showImageCopyright and not empty imageCopyright}">
                <div class="copyright">${imageCopyright}</div><%----%>
            </c:if>

        </mercury:link>

    </div><%----%>
</div><%----%>
<mercury:nl />