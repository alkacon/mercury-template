<%@ tag
    pageEncoding="UTF-8"
    display-name="image-simple"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a responsive image without additional markup." %>


<%@ attribute name="image" type="java.lang.Object" required="true"
    description="The image to display. Must be a either a nested image content OR
    a VFS path to the image that should be read." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="Text used in the image 'alt' and 'title' attributes."%>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio,
    Allowed valued are: '1-1', '4-3', '3-2', '16-9', '2-1' and '2,35-1'" %>

<%@ attribute name="width" type="java.lang.String" required="false"
    description="The optional image width to use, will be added as attribute to the image tag." %>

<%@ attribute name="lazyLoad" type="java.lang.Boolean" required="false"
    description="Use lazy loading or not?"%>

<%@ attribute name="noScript" type="java.lang.Boolean" required="false"
    description="Generate noscript tags for lazy loading images?"%>

<%@ attribute name="sizes" type="java.lang.String" required="false"
    description="Container sizes to create image variations for." %>

<%@ attribute name="cssImage" type="java.lang.String" required="false"
    description="'class' atttribute to set directly on the generated img tag."%>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttribute to set on the src-box div surrounding the generated img." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated content.
    Default is 'false' if not provided." %>

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

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:image-vars
    image="${image}"
    ratio="${ratio}"
    title="${title}"
    ade="${empty ade ? false : ade}">

<c:if test="${not empty imageBean}">

    <mercury:image-srcset
        imagebean="${imageBean}"
        alt="${imageTitle}"
        sizes="${sizes}"
        title="${imageTitleCopyright}"
        lazyLoad="${lazyLoad}"
        noScript="${noScript}"
        attrWrapper="${imageDndAttr}"
        cssImage="${cssImage}"
        cssWrapper="${cssWrapper}"
    />

</c:if>

<%-- ####### JSP body inserted here ######## --%>
<jsp:doBody/>
<%-- ####### /JSP body inserted here ######## --%>

</mercury:image-vars>