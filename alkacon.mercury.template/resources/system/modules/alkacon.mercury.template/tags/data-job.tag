<%@ tag
    pageEncoding="UTF-8"
    display-name="data-job"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for jobs." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The job XML content to use for data generation."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<jsp:useBean id="jobschema" class="java.util.LinkedHashMap"/>

<c:set target="${jobschema}" property="title" value="${content.value.Title}" />
<c:if test="${content.value.Date.isSet}">
    <c:set target="${jobschema}" property="datePosted"><fmt:formatDate value="${cms:convertDate(content.value.Date)}" pattern="yyyy-MM-dd" /></c:set>
</c:if>
<c:if test="${content.value.EndDate.isSet}">
    <c:set target="${jobschema}" property="validThrough"><fmt:formatDate value="${cms:convertDate(content.value.EndDate)}" pattern="yyyy-MM-dd'T'HH:mm" /></c:set>
</c:if>
<c:if test="${content.value.Location.isSet}">
    <jsp:useBean id="joblocation" class="java.util.LinkedHashMap"/>
    <c:set target="${joblocation}" property="name" value="${content.value.Location}" />
    <c:set target="${joblocation}" property="@type" value="Place" />
    <c:set target="${jobschema}" property="jobLocation" value="${joblocation}" />
</c:if>

<c:choose>
    <c:when test="${content.value.Introduction.value.Text.isSet}">
        <c:set target="${jobschema}" property="description" value="${content.value.Introduction.value.Text}" />
    </c:when>
    <c:otherwise>
        <c:set var="textFound" value="false" />
        <c:forEach var="text" items="${content.valueList.Text}" varStatus="status">
            <c:if test="${not textFound and text.value.Text.isSet}">
                <c:set target="${jobschema}" property="description" value="${text.value.Text}" />
                <c:set var="textFound" value="true" />
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>

<c:set var="imageElement" value="" />
<c:choose>
    <c:when test="${content.value.Introduction.value.Image.isSet}">
        <c:set var="imageElement" value="${content.value.Introduction.value.Image}" />
    </c:when>
    <c:otherwise>
        <c:forEach var="text" items="${content.valueList.Text}" varStatus="status">
            <c:if test="${empty imageElement and text.value.Image.isSet}">
                <c:set var="imageElement" value="${text.value.Image}" />
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>
<c:if test="${not empty imageElement}">
    <mercury:image-vars image="${imageElement}">
        <jsp:useBean id="jobimage" class="java.util.LinkedHashMap"/>
        <c:set target="${jobimage}" property="@type" value="ImageObject" />
        <c:set target="${jobimage}" property="contenturl" value="${cms.site.url.concat(imageUrl)}" />
        <c:set target="${jobimage}" property="url" value="${cms.site.url.concat(imageUrl)}" />
        <c:set target="${jobimage}" property="width" value="${''.concat(imageWidth)}" />
        <c:set target="${jobimage}" property="height" value="${''.concat(imageHeight)}" />
        <c:if test="${not empty imageTitle}"><c:set target="${jobimage}" property="name" value="${imageTitle}" /></c:if>
        <c:if test="${not empty imageCopyright}"><c:set target="${jobimage}" property="copyrightHolder" value="${imageCopyright}" /></c:if>
        <c:set target="${jobschema}" property="image" value="${jobimage}" />
    </mercury:image-vars>
</c:if>

<c:set var="url">${cms.site.url}<cms:link>${content.filename}</cms:link></c:set>

<mercury:data-json-ld type="JobPosting" url="${url}" properties="${jobschema}" />