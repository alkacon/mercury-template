<%@ tag pageEncoding="UTF-8"
    display-name="data-media"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for media." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<m:media-vars content="${content}" ratio="${'1-1'}">

<c:set var="value"              value="${content.value}" />
<c:choose>
    <c:when test="${isYouTube or isVideo}">
        <c:set var="mediaType"  value="${'VideoObject'}" />
    </c:when>
    <c:when test="${isSoundCloud or isAudio}">
        <c:set var="mediaType"  value="${'AudioObject'}" />
    </c:when>
    <c:otherwise>
        <c:set var="mediaType"  value="${'MediaObject'}" />
    </c:otherwise>
</c:choose>
<c:choose>
    <c:when test="${value['MetaInfo/Title'].isSet}">
        <c:set var="intro"      value="${null}" />
        <c:set var="title"      value="${value['MetaInfo/Title']}" />
    </c:when>
    <c:otherwise>
        <c:set var="intro"      value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
        <c:set var="title"      value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
    </c:otherwise>
</c:choose>
<c:choose>
    <c:when test="${value['MetaInfo/Description'].isSet}">
        <c:set var="preface"    value="${value['MetaInfo/Description']}" />
    </c:when>
    <c:otherwise>
        <c:set var="preface"    value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : (value.Preface.isSet ? value.Preface : null)}" />
    </c:otherwise>
</c:choose>
<c:set var="date"               value="${value.Date.isSet ? value.Date : content.file.dateLastModified}" />
<c:choose>
    <c:when test="${not empty image}">
        <m:image-vars image="${image}">
            <c:set var="thumbnailUrl" value="${cms.site.url.concat(imageUrl)}" />
        </m:image-vars>
    </c:when>
    <c:otherwise>
        <c:set var="thumbnailUrl" value="${jsonldThumbnailUrl}" />
    </c:otherwise>
</c:choose>


<%--
# JSON-LD Generation for Mercury media.
# See: https://schema.org/AudioObject
# See: https://schema.org/MediaObject
# See: https://schema.org/VideoObject
# See: https://developers.google.com/search/docs/appearance/structured-data/video
--%>
<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="http://schema.org" />
    <cms:jsonvalue key="@type" value="${mediaType}" />
    <cms:jsonvalue key="name">
        <c:if test="${not empty intro}">
            <c:out value="${intro.toString.concat(': ')}" />
        </c:if>
        <c:out value="${title}" />
    </cms:jsonvalue>
    <c:if test="${preface.isSet}">
        <cms:jsonvalue key="description" value="${preface.toString}" />
    </c:if>
    <c:if test="${not empty thumbnailUrl}">
        <cms:jsonvalue key="thumbnailUrl" value="${thumbnailUrl}" />
    </c:if>
    <cms:jsonvalue key="uploadDate"><fmt:formatDate value="${cms:convertDate(date)}" pattern="yyyy-MM-dd'T'HH:mm:ssXXX" /></cms:jsonvalue>
</cms:jsonobject>

<m:nl />
<script type="application/ld+json"><%----%>
    ${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}
</script><%----%>
<m:nl />

</m:media-vars>
