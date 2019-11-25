<%@ tag pageEncoding="UTF-8"
    display-name="image-animated"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a responsive image with optional animation effects." %>


<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="The image to format. Must be a nested image content."%>

<%@ attribute name="sizes" type="java.lang.String" required="false"
    description="Container sizes to create image variations for." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="Text used in the image 'alt' and 'title' attributes."%>

<%@ attribute name="setTitle" type="java.lang.Boolean" required="false"
    description="If 'true' then a title attribute from the image attributes is added to the generated image tag.
    Default is 'true' if not provided." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated content.
    Default is 'false' if not provided." %>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images or not?
    Default is 'true'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Enables a zoom option for the image." %>

<%@ attribute name="addEffectBox" type="java.lang.Boolean" required="false"
    description="Adds an CSS selectors required for anmiantion effects. Default is 'true'." %>

<%@ attribute name="cssImage" type="java.lang.String" required="false"
    description="'class' atttribute to set directly on the generated img tag."%>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the src-box div surrounding the generated img." %>

<%@ attribute name="attrImage" type="java.lang.String" required="false"
    description="Attribute(s) to add directly to the generated img tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attribute(s) to add on the src-box div surrounding the generated img." %>

<%@ attribute name="test" type="java.lang.String" required="false"
    description="Can be used to defer the decision to actually create the markup around the body to the calling element.
    If not set or 'true', the markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and just the body of the tag is returned. "%>


<%-- ####### These variables are actually set in the mercury:image-vars tag included ####### --%>
<%@ variable name-given="imageBean" declare="true" variable-class="org.opencms.jsp.util.CmsJspImageBean" %>
<%@ variable name-given="imageLink" declare="true" %>
<%@ variable name-given="imageUnscaledLink" declare="true" %>
<%@ variable name-given="imageUrl" declare="true" %>
<%@ variable name-given="imageCopyright" declare="true" %>
<%@ variable name-given="imageCopyrightHtml" declare="true" %>
<%@ variable name-given="imageTitle" declare="true" %>
<%@ variable name-given="imageTitleCopyright" declare="true" %>
<%@ variable name-given="imageWidth" declare="true" %>
<%@ variable name-given="imageHeight" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:image-vars
    image="${image}"
    ratio="${ratio}"
    title="${title}"
    ade="${empty ade ? false : ade}">

<c:set var="test" value="${empty test ? true : test}" />
<c:set var="addEffectBox" value="${empty addEffectBox ? true : addEffectBox}" />
<c:set var="setTitle" value="${empty setTitle ? true : setTitle}" />

<c:choose>

<c:when test="${not empty imageBean and test}">
    <c:if test="${showImageZoom}">
        <c:set var="zoomData">
            <mercury:image-zoomdata
                src="${imageUrl}"
                title="${imageTitle}"
                copyright="${imageCopyrightHtml}"
                height="${imageHeight}"
                width="${imageWidth}"
            />
        </c:set>
    </c:if>
    <div class="${addEffectBox ? 'effect-box ':''}${cssWrapper}" ${attrWrapper}><%----%>
        <mercury:image-srcset
            imagebean="${imageBean}"
            sizes="${sizes}"
            alt="${imageTitle}"
            title="${setTitle ? imageTitleCopyright : null}"
            cssImage="${addEffectBox ? 'animated ':''}${cssImage}"
            cssWrapper="${showImageZoom ? 'zoomer' : ''}"
            attrImage="${attrImage}"
            attrWrapper="${imageDndAttr}"
            zoomData="${zoomData}"
            noScript="${noScript}"
        />
        <%-- ####### JSP body inserted here ######## --%>
        <jsp:doBody/>
        <%-- ####### /JSP body inserted here ######## --%>
    </div><%----%>
    <mercury:nl />
</c:when>

<c:otherwise>
    <c:if test="${cms.isEditMode and test}">
        <%-- ###### No image: Output warning in offline version ###### --%>
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <mercury:alert type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.page.noImage" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.page.noImage.hint" />
                </jsp:attribute>
            </mercury:alert>
        </cms:bundle>
    </c:if>
    <%-- ####### JSP body inserted here ######## --%>
    <jsp:doBody/>
    <%-- ####### /JSP body inserted here ######## --%>
</c:otherwise>

</c:choose>

</mercury:image-vars>