<%@ tag pageEncoding="UTF-8"
    display-name="media-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Reads a media content and sets a series of variables for quick acesss." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The media content to use." %>

<%@ attribute name="ratio" type="java.lang.String" required="true"
    description="Can be used to scale the media in a specific ratio,
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>


<%@ variable name-given="image" declare="true"
    description="The optional image of the media file, as set in the content." %>

<%@ variable name-given="copyright" declare="true"
    description="The optional copyright of the media file, as set in the content." %>

<%@ variable name-given="width" declare="true"
    description="The width of the media file, taken from the ratio." %>

<%@ variable name-given="height" declare="true"
    description="The height of the media file, taken from the ratio." %>

<%@ variable name-given="isYouTube" declare="true"
    description="If true, the media file is a YouTube video." %>

<%@ variable name-given="isFlexible" declare="true"
    description="If true, the media is created form a flexible embed code." %>

<%@ variable name-given="youTubeId" declare="true"
    description="The ID of the YouTube video." %>

<%@ variable name-given="youTubePreviewImg" declare="true"
    description="The preview image for the YouTube video." %>

<%@ variable name-given="youTubePreviewHtml" declare="true"
    description="The full HTML markup for the YouTube video preview image." %>

<%@ variable name-given="template" declare="true"
    description="The template to use for the media file." %>

<%@ variable name-given="icon" declare="true"
    description="The overlay icon for the media file." %>

<%@ variable name-given="cssClass" declare="true"
    description="An additional CSS class to be used in the HTML generated later." %>


<%@ variable name-given="caseNotInList" declare="true" %>
<%@ variable name-given="caseStaticList" declare="true" %>
<%@ variable name-given="caseStandardElement" declare="true" %>
<%@ variable name-given="caseDynamicListAjax" declare="true" %>
<%@ variable name-given="caseDynamicListNoscript" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:list-element-status>

<c:set var="width" value="${cms:toNumber(fn:substringBefore(ratio, '-'), 4)}" />
<c:set var="height" value="${cms:toNumber(fn:substringAfter(ratio, '-'), 3)}" />

<c:if test="${content.value.Image.isSet}">
    <c:set var="image" value="${content.value.Image}" />
</c:if>

<c:if test="${content.value.Copyright.isSet}">
    <c:set var="copyright" value="${content.value.Copyright}" />
</c:if>

<c:choose>

<c:when test="${content.value.MediaContent.value.YouTube.isSet}">
    <c:set var="isYouTube" value="${true}" />
    <c:set var="youTubeId" value="${content.value.MediaContent.value.YouTube.value.YouTubeId}" />
    <c:set var="defaultPreview"><mercury:schema-param param="mercuryYouTubePreviewDefault" /></c:set>
    <c:set var="youTubePreviewImg" value="${content.value.MediaContent.value.YouTube.value.YouTubePreview.isSet ?
        content.value.MediaContent.value.YouTube.value.YouTubePreview : defaultPreview}" />
    <c:set var="template"><%--
    --%><iframe src="https://www.youtube-nocookie.com/embed/${youTubeId}?<%--
        --%>autoplay=1&rel=0&iv_load_policy=3&modestbranding=1" <%--
        --%>style="border: none;" allow="autoplay; encrypted-media" allowfullscreen><%--
    --%></iframe><%----%>
    </c:set>
    <c:set var="icon" value="fa-youtube-play" />
    <c:set var="cssClass" value="video" />

    <c:choose>
        <c:when test="${youTubePreviewImg eq 'none'}">
            <c:set var="youTubePreviewHtml" value="${null}" />
        </c:when>
        <c:otherwise>
            <c:set var="youTubePreviewHtml">
                <c:set var="srcSet"><%--
                --%>https://img.youtube.com/vi/${youTubeId}/default.jpg 120w, <%--
                --%>https://img.youtube.com/vi/${youTubeId}/hqdefault.jpg 480w</c:set>
                <c:if test="${not (youTubePreviewImg eq 'hqdefault.jpg')}">
                    <c:set var="srcSet" value="${srcSet}, https://img.youtube.com/vi/${youTubeId}/${youTubePreviewImg} 640w" />
                </c:if>
                <mercury:image-lazyload
                    srcUrl="https://img.youtube.com/vi/${youTubeId}/${youTubePreviewImg}"
                    srcSet="${srcSet}"
                    alt="${content.value.Title}"
                    cssImage="animated"
                    noScript="${caseStandardElement}"
                    lazyLoad="${not caseDynamicListNoscript}"
                />
            </c:set>
        </c:otherwise>
    </c:choose>
</c:when>

<c:when test="${content.value.MediaContent.value.Flexible.isSet}">
    <c:set var="isFlexible" value="${true}" />
    <c:set var="template" value="${content.value.MediaContent.value.Flexible.value.Code}" />
    <c:choose>
        <c:when test="${content.value.MediaContent.value.Flexible.value.Icon.isSet}">
            <c:set var="icon" value="fa-${content.value.MediaContent.value.Flexible.value.Icon}" />
        </c:when>
        <c:otherwise>
            <c:set var="icon" value="fa-play" />
        </c:otherwise>
    </c:choose>
</c:when>

</c:choose>

<jsp:doBody/>

</mercury:list-element-status>