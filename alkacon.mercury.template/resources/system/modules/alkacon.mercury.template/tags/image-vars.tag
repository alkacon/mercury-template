<%@ tag pageEncoding="UTF-8"
    display-name="image-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Reads an image from the VFS and sets a series of variables for quick acesss."%>


<%@ attribute name="image" type="java.lang.Object" required="true"
    description="The image to format. Must be a either a nested image content OR
    a VFS path to the image that should be read." %>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio,
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="escapeCopyright" type="java.lang.Boolean" required="false"
    description="If true, the image copyright text is escaped (for usage in HTML attributes)." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="Default title used in case title of image is not set."%>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated content.
    Default is 'true' if not provided." %>

<%@ variable name-given="imageBean" declare="true"
    variable-class="org.opencms.jsp.util.CmsJspImageBean"
    description="The image bean for the image." %>

<%@ variable name-given="imageLink" declare="true"
    description="The internal resource path of the image, including optional scaling parameters." %>

<%@ variable name-given="imageUnscaledLink" declare="true"
    description="The internal resource path of the image, without optional scaling parameters." %>

<%@ variable name-given="imageUrl" declare="true"
    description="The external URL of the image." %>

<%@ variable name-given="imageCopyright" declare="true"
    description="The copyright text." %>

<%@ variable name-given="imageCopyrightHtml" declare="true"
    description="The copyright text with HTML enties instead of (c)." %>

<%@ variable name-given="imageTitle" declare="true"
    description="The title of the image." %>

<%@ variable name-given="imageTitleCopyright" declare="true"
    description="The combination of title and copyright." %>

<%@ variable name-given="imageWidth" declare="true"
    description="The width of the image in pixel." %>

<%@ variable name-given="imageHeight" declare="true"
    description="The height of the image in pixel." %>

<%@ variable name-given="imageDndAttr" declare="true"
    description="The DND attribute for the image." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>


<c:set var="imageLink" value="" />
<c:set var="imageUrl" value="" />
<c:set var="imageUnscaledLink" value="" />
<c:set var="imageCopyright" value="" />
<c:set var="imageCopyrightHtml" value="" />
<c:set var="imageTitle" value="" />
<c:set var="imageWidth" value="" />
<c:set var="imageHeight" value="" />
<c:set var="imageDndAttr" value="" />

<c:choose>
    <c:when test="${cms:isWrapper(image)}">
        <c:set var="isXmlContent" value="${true}" />
        <c:choose>
            <c:when test="${image.value.Image.isSet}">
                <c:set var="imageLink" value="${image.value.Image}" />
                <c:set var="imageDndAttr" value="${ade ? image.value.Image.imageDndAttr : ''}" />
            </c:when>
            <c:when test="${image.value.Uri.isSet}">
                <c:set var="imageLink" value="${image.value.Uri}" />
                <c:set var="imageDndAttr" value="${ade ? image.value.Uri.imageDndAttr : ''}" />
            </c:when>
            <c:when test="${image.isSet and (image.typeName == 'OpenCmsVfsFile')}">
                <c:set var="imageLink" value="${image}" />
                <c:set var="imageDndAttr" value="${ade ? image.imageDndAttr : ''}" />
            </c:when>
        </c:choose>
        <c:if test="${not empty imageLink}">
            <c:set var="imageBean" value="${imageLink.toImage}" />
        </c:if>
    </c:when>
    <c:when test="${image['class'].simpleName eq 'CmsJspImageBean'}">
        <c:set var="isXmlContent" value="${false}" />
        <c:set var="imageBean" value="${image}" />
        <c:set var="imageLink" value="${image.srcUrl}" />
    </c:when>
    <c:when test="${image['class'].simpleName eq 'String'}">
        <c:set var="isXmlContent" value="${false}" />
        <cms:scaleImage var="imageBean" src="${image}"/>
        <c:if test="${not empty imageBean}">
            <c:set var="imageLink" value="${image}" />
        </c:if>
    </c:when>
</c:choose>

<c:if test="${not empty imageBean}">
<%-- We only initialize the other stuff if the image bean was initialized --%>

    <c:set var="escapeCopyright"        value="${empty escapeCopyright ? true : escapeCopyright}" />
    <c:set var="ade"                    value="${empty ade ? true : ade}" />

    <%-- Apply a global quality factor of 75% for JPEG compression --%>
    <%-- OpenCms SimAPI otherwise applies 95% which makes images more than twice as large --%>
    <c:set target="${imageBean}" property="quality" value="${75}" />

    <c:if test="${(not empty ratio) and (ratio != 'none')}">
        <c:set var="imageBean" value="${imageBean.scaleRatio[ratio]}" />
    </c:if>

    <c:set var="imageUnscaledLink" value="${imageBean.vfsUri}" />
    <c:set var="imageUrl" value="${imageBean.srcUrl}" />
    <c:set var="imageWidth" value="${imageBean.scaler.width}" />
    <c:set var="imageHeight" value="${imageBean.scaler.height}" />

    <%--
        For the copyright, we check if this is set in the content first,
        if not we try to read it from the property.
    --%>
    <c:choose>
        <c:when test="${isXmlContent and image.value.Copyright.isSet}">
            <c:set var="imageCopyright">${image.value.Copyright}</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="imageCopyright"><cms:property name="Copyright" file="${imageUnscaledLink}" locale="${cms.locale}" default="" /></c:set>
        </c:otherwise>
    </c:choose>

    <%--
        Set the image title from the dedicated field, if not set try the property.
    --%>
    <c:choose>
        <c:when test="${isXmlContent and image.value.Title.isSet}">
            <c:set var="imageTitle">${image.value.Title}</c:set>
        </c:when>
        <c:when test="${not empty title}">
            <c:set var="imageTitle">${title}</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="imageTitle"><cms:property name="Title" file="${imageUnscaledLink}" locale="${cms.locale}" default="" /></c:set>
        </c:otherwise>
    </c:choose>
    <c:set var="imageTitleCopyright">${fn:replace(imageTitle, '"', '')}</c:set>

    <%--
        Add copyright symbol. Make sure &copy; is replaced
        with (c) since title attributes will not properly display HTML entities.
    --%>
    <c:if test="${not empty imageCopyright}">
        <c:set var="imageCopyright">${fn:replace(imageCopyright, '"', '')}</c:set>
        <c:choose>
            <c:when test="${escapeCopyright}">
                <c:set var="imageCopyright">${fn:replace(imageCopyright, '&copy;', '(c)')}</c:set>
                <c:if test="${not fn:contains(imageCopyright, '(c)')}">
                    <c:set var="imageCopyright">${'(c)'}${' '}${imageCopyright}</c:set>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:set var="imageCopyright">${fn:replace(imageCopyright, '(c)', '&copy;')}</c:set>
                <c:if test="${not fn:contains(imageCopyright, '&copy;')}">
                    <c:set var="imageCopyright">${'&copy;'}${' '}${imageCopyright}</c:set>
                </c:if>
            </c:otherwise>
        </c:choose>

        <c:set var="imageCopyrightHtml">${fn:replace(imageCopyright, '(c)', '&copy;')}</c:set>
        <c:set var="imageTitleCopyright">${imageTitle}${' '}${imageCopyright}</c:set>
    </c:if>

</c:if>

<jsp:doBody/>