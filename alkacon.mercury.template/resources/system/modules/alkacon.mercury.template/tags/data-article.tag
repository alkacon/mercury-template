<%@ tag pageEncoding="UTF-8"
    display-name="data-blog"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for blog articles." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The blog XML content to use for data generation."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<jsp:useBean id="articleschema" class="java.util.LinkedHashMap"/>

<c:set target="${articleschema}" property="name" value="${content.value.Title}" />
<c:set target="${articleschema}" property="headline" value="${content.value.Title}" />
<c:if test="${content.value.Date.isSet}">
    <c:set target="${articleschema}" property="datePublished"><fmt:formatDate value="${cms:convertDate(content.value.Date)}" pattern="yyyy-MM-dd'T'HH:mm" /></c:set>
</c:if>
<c:set target="${articleschema}" property="dateModified"><fmt:formatDate value="${cms:convertDate(content.file.dateLastModified)}" pattern="yyyy-MM-dd'T'HH:mm" /></c:set>

<c:choose>
    <c:when test="${content.value.Teaser.isSet}">
        <c:set target="${articleschema}" property="articleBody" value="${content.value.Teaser}" />
    </c:when>
    <c:otherwise>
        <c:set var="textFound" value="false" />
        <c:forEach var="text" items="${content.valueList.Paragraph}" varStatus="status">
            <c:if test="${not textFound and text.value.Text.isSet}">
                <c:set target="${articleschema}" property="articleBody" value="${text.value.Text}" />
                <c:set var="textFound" value="true" />
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>

<c:set var="imageElement" value="" />
<c:choose>
    <c:when test="${content.value.TeaserImage.isSet}">
        <c:set var="imageElement" value="${content.value.TeaserImage}" />
        <c:set var="imagePath">${cms.site.url}<cms:link>${content.value.TeaserImage}</cms:link></c:set>
         <c:set target="${articleschema}" property="image" value="${imagePath}" />
    </c:when>
    <c:otherwise>
        <c:forEach var="text" items="${content.valueList.Paragraph}" varStatus="status">
            <c:if test="${empty imageElement and text.value.Image.isSet}">
                <c:set var="imageElement" value="${text.value.Image}" />
                <mercury:image-vars image="${imageElement}">
                    <jsp:useBean id="articleimage" class="java.util.LinkedHashMap"/>
                    <c:set target="${articleimage}" property="@type" value="ImageObject" />
                    <c:set target="${articleimage}" property="contenturl" value="${cms.site.url.concat(imageUrl)}" />
                    <c:set target="${articleimage}" property="url" value="${cms.site.url.concat(imageUrl)}" />
                    <c:set target="${articleimage}" property="width" value="${''.concat(imageWidth)}" />
                    <c:set target="${articleimage}" property="height" value="${''.concat(imageHeight)}" />
                    <c:if test="${not empty imageTitle}"><c:set target="${articleimage}" property="name" value="${imageTitle}" /></c:if>
                    <c:if test="${not empty imageCopyright}"><c:set target="${articleimage}" property="copyrightHolder" value="${imageCopyright}" /></c:if>
                    <c:set target="${articleschema}" property="image" value="${articleimage}" />
                </mercury:image-vars>
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>

<jsp:useBean id="articleauthor" class="java.util.LinkedHashMap"/>
<c:set target="${articleauthor}" property="@type" value="Person" />
<c:set target="${articleauthor}" property="name" value="${content.value.Author}" />
<c:if test="${content.value.AuthorMail.isSet}">
    <c:set target="${articleauthor}" property="email" value="${content.value.AuthorMail}" />
</c:if>
<c:set target="${articleschema}" property="author" value="${articleauthor}" />

<%-- Publisher is mandatory. According to schema.org, person is possible but not accepted by Google --%>
<c:set var="publisher" value="${content.wrap.propertySearch['site.publisher']}" />
<c:choose>
<c:when test="${not empty publisher}">
    <jsp:useBean id="articlepublisher" class="java.util.LinkedHashMap"/>
    <c:set target="${articlepublisher}" property="@type" value="Organization" />
    <c:set target="${articlepublisher}" property="name" value="${publisher}" />
    <c:set var="publogo" value="${content.wrap.propertySearch['site.publisher.logo']}" />
    <c:if test="${not empty publogo and cms.vfs.existsResource[publogo]}">
        <c:set var="publogores" value="${cms.vfs.readResource[publogo]}" />
        <jsp:useBean id="publisherlogo" class="java.util.LinkedHashMap"/>
        <c:set target="${publisherlogo}" property="@type" value="ImageObject" />
        <c:set target="${publisherlogo}" property="url" value="${cms.site.url}${publogores.link}" />
        <c:set target="${articlepublisher}" property="logo" value="${publisherlogo}" />
    </c:if>
    <c:set target="${articleschema}" property="publisher" value="${articlepublisher}" />
</c:when>
<c:otherwise>
    <c:set target="${articleschema}" property="publisher" value="${articleauthor}" />
</c:otherwise>
</c:choose>

<c:set var="url">${cms.site.url}<cms:link>${content.filename}</cms:link></c:set>
<c:set target="${articleschema}" property="mainEntityOfPage" value="${url}" />

<mercury:data-json-ld type="Article" url="${url}" properties="${articleschema}" />