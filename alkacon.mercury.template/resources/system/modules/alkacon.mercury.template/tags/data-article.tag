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


<%-- Using the same logic as the elaborate display teaser --%>
<c:set var="value"      value="${content.value}" />
<c:set var="intro"      value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
<c:set var="title"      value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="preface"    value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : (value.Preface.isSet ? value.Preface : value.Paragraph.value.Text)}" />
<c:set var="image"      value="${value['TeaserData/TeaserImage'].isSet ? value['TeaserData/TeaserImage'] : (value.Image.isSet ? value.Image : value.Paragraph.value.Image)}" />
<c:set var="date"       value="${value.Date.isSet ? value.Date : content.file.dateLastModified}" />

<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="http://schema.org" />
    <cms:jsonvalue key="@type" value="Article" />

    <cms:jsonvalue key="headline">
        <c:if test="${intro.isSet}">
            <c:out value="${intro.toString.concat(': ')}" />
        </c:if>
        <c:out value="${title}" />
    </cms:jsonvalue>

    <cms:jsonvalue key="datePublished"><fmt:formatDate value="${cms:convertDate(date)}" pattern="yyyy-MM-dd'T'HH:mm" /></cms:jsonvalue>
    <cms:jsonvalue key="dateModified"><fmt:formatDate value="${cms:convertDate(content.file.dateLastModified)}" pattern="yyyy-MM-dd'T'HH:mm" /></cms:jsonvalue>
    <cms:jsonvalue key="url">${cms.site.url}<cms:link>${content.filename}</cms:link></cms:jsonvalue>
    <cms:jsonvalue key="mainEntityOfPage">${cms.site.url}<cms:link>${content.filename}</cms:link></cms:jsonvalue>

    <c:if test="${preface.isSet}">
        <cms:jsonvalue key="articleBody" value="${preface}" />
    </c:if>

    <c:if test="${image.isSet}">
        <mercury:image-vars image="${image}" createJsonLd="${true}">
            <cms:jsonvalue key="image" value="${imageJsonLd}" />
        </mercury:image-vars>
    </c:if>

    <cms:jsonobject var="author" mode="object">
        <cms:jsonvalue key="@type" value="Person" />
        <cms:jsonvalue key="name" value="${value.Author}" />
        <c:if test="${value.AuthorMail.isSet}">
            <cms:jsonvalue key="email" value="${value.AuthorMail}" />
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

<mercury:nl />
<script type="application/ld+json">${jsonLd.compact}</script>
<mercury:nl />