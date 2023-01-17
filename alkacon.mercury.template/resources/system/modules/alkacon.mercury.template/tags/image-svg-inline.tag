<%@ tag pageEncoding="UTF-8"
    display-name="image-svg-inline"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Inlines an SVG image." %>


<%@ attribute name="imagebean" type="org.opencms.jsp.util.CmsJspImageBean" required="true"
    description="The image bean that points to the SVG to inline."%>

<%@ attribute name="width" type="java.lang.Integer" required="false"
    description="Width of the target image." %>

<%@ attribute name="height" type="java.lang.Integer" required="false"
    description="Height of the target image." %>

<%@ attribute name="heightPercentage" type="java.lang.String" required="false"
    description="Height of the target image in percentage relative to the target image width.
    Required for box size calculation." %>

<%@ attribute name="alt" type="java.lang.String" required="false"
    description="'alt' atttribute to set on the generated SVG tag." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="'title' atttribute to set on the generated SVG tag." %>

<%@ attribute name="copyright" type="java.lang.String" required="false"
    description="Copyright information to display as an image overlay.
    If this is emtpy, no copyright overlay will be displayed." %>

<%@ attribute name="cssImage" type="java.lang.String" required="false"
    description="'class' atttribute to set directly on the generated img tag."%>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the src-box div surrounding the generated img." %>

<%@ attribute name="attrImage" type="java.lang.String" required="false"
    description="Attribute(s) to add directly to the generated img tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the src-box div surrounding the generated img." %>

<%@ attribute name="zoomData" type="java.lang.String" required="false"
    description="Zoom data attribute added directly to the generated image tag." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:nl />
<mercury:padding-box
    cssWrapper="image-src-box ${cssWrapper}"
    attrWrapper="${attrWrapper}"
    heightPercentage="${heightPercentage}"
    width="${width}"
    height="${height}">

    <c:set var="svgTitle" value="${empty alt ? title : alt}" />

    <span class="svg-inline img${empty cssImage ? '' : ' '.concat(cssImage)}"
        <c:if test="${not empty svgTitle}">${' '}title="${svgTitle}"</c:if>
        <c:if test="${not empty attrImage}">${' '}${attrImage}</c:if>
        <c:if test="${not empty zoomData}">
            <fmt:setLocale value="${cms.locale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                ${' '}${zoomData}
                ${' '}aria-label="${not empty alt ? alt.concat(' - ') : ''}
                <fmt:message key="msg.aria.click-to-enlarge" />
                ${'\" '}role="button" tabindex="0"<%----%>
            </cms:bundle>
        </c:if><%--
--%>><%----%>

    <c:out value="${imagebean.resource.content}" escapeXml="${false}" />

    </span><%----%>

    <c:if test="${not empty copyright}">
        <div class="copyright image-copyright" aria-hidden="true"><%----%>
            ${copyright}
        </div><%----%>
    </c:if>

</mercury:padding-box>