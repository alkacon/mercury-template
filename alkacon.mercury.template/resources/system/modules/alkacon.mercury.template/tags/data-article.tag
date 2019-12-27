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


<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="http://schema.org" />
    <cms:jsonvalue key="@type" value="Article" />

    <cms:jsonvalue key="headline">
        <c:if test="${content.value.Intro.isSet}">
            <c:out value="${content.value.Intro.toString.concat(': ')}" />
        </c:if>
        <c:out value="${content.value.Title}" />
    </cms:jsonvalue>

    <c:set var="datePublished" value="${content.value.Date.isSet ? content.value.Date : content.file.dateLastModified}" />
    <cms:jsonvalue key="datePublished"><fmt:formatDate value="${cms:convertDate(datePublished)}" pattern="yyyy-MM-dd'T'HH:mm" /></cms:jsonvalue>
    <cms:jsonvalue key="dateModified"><fmt:formatDate value="${cms:convertDate(content.file.dateLastModified)}" pattern="yyyy-MM-dd'T'HH:mm" /></cms:jsonvalue>
    <cms:jsonvalue key="url">${cms.site.url}<cms:link>${content.filename}</cms:link></cms:jsonvalue>
    <cms:jsonvalue key="mainEntityOfPage">${cms.site.url}<cms:link>${content.filename}</cms:link></cms:jsonvalue>

    <c:choose>
        <c:when test="${content.value.Preface.isSet}">
            <cms:jsonvalue key="articleBody" value="${content.value.Preface}" />
        </c:when>
        <c:otherwise>
            <c:set var="textFound" value="false" />
            <c:forEach var="paragraph" items="${content.valueList.Paragraph}" varStatus="status">
                <c:if test="${not textFound and paragraph.value.Text.isSet}">
                    <cms:jsonvalue key="articleBody" value="${paragraph.value.Text}" />
                    <c:set var="textFound" value="${true}" />
                </c:if>
            </c:forEach>
        </c:otherwise>
    </c:choose>

    <c:set var="imageElement" value="" />
    <c:choose>
        <c:when test="${content.value.TeaserImage.isSet}">
            <c:set var="imageElement" value="${content.value.TeaserImage}" />
        </c:when>
        <c:otherwise>
            <c:forEach var="paragraph" items="${content.valueList.Paragraph}" varStatus="status">
                <c:if test="${empty imageElement and paragraph.value.Image.isSet}">
                    <c:set var="imageElement" value="${paragraph.value.Image}" />
                </c:if>
            </c:forEach>
        </c:otherwise>
    </c:choose>
    <c:if test="${not empty imageElement}">
        <mercury:image-vars image="${imageElement}" createJsonLd="${true}">
            <cms:jsonvalue key="image" value="${imageJsonLd}" />
        </mercury:image-vars>
    </c:if>

    <cms:jsonobject var="author" mode="object">
        <cms:jsonvalue key="@type" value="Person" />
        <cms:jsonvalue key="name" value="${content.value.Author}" />
        <c:if test="${content.value.AuthorMail.isSet}">
            <cms:jsonvalue key="email" value="${content.value.AuthorMail}" />
        </c:if>
    </cms:jsonobject>
    <cms:jsonvalue key="author" value="${author}" />

    <%-- Publisher is mandatory. According to schema.org, person is possible but not accepted by Google --%>
    <c:set var="publisherName" value="${content.wrap.propertySearch['site.publisher']}" />
    <c:if test="${not empty publisherName}">
        <cms:jsonobject var="publisher" mode="object">
            <cms:jsonvalue key="@type" value="Organization" />
            <cms:jsonvalue key="name" value="${publisherName}" />
            <c:set var="publisherLogo" value="${content.wrap.propertySearch['site.publisher.logo']}" />
            <c:if test="${not empty publisherLogo and cms.vfs.existsResource[publisherLogo]}">
                <cms:jsonobject key="logo">
                    <cms:jsonvalue key="@type" value="ImageObject" />
                    <cms:jsonvalue key="url" value="${cms.site.url}${cms.vfs.readResource[publisherLogo].link}" />
                </cms:jsonobject>
            </c:if>
        </cms:jsonobject>
    </c:if>
    <cms:jsonvalue key="publisher" value="${empty publisherName ? author : publisher}" />

</cms:jsonobject>

<script type="application/ld+json">${jsonLd.compact}</script>
