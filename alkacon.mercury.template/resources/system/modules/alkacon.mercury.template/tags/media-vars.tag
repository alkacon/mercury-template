<%@ tag pageEncoding="UTF-8"
    display-name="media-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Reads a media content and sets a series of variables for quick acesss." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The media content to use." %>

<%@ attribute name="ratio" type="java.lang.String" required="true"
    description="Can be used to scale the media in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="autoPlay" type="java.lang.Boolean" required="false"
    description="Controls if the media is directly played without clicking on the element first. Default is 'false'." %>


<%@ variable name-given="image" declare="true"
    description="The optional image of the media file, as set in the content." %>

<%@ variable name-given="copyright" declare="true"
    description="The optional copyright of the media file, as set in the content." %>

<%@ variable name-given="width" declare="true"
    description="The width of the media file, taken from the ratio." %>

<%@ variable name-given="height" declare="true"
    description="The height of the media file, taken from the ratio." %>

<%@ variable name-given="usedRatio" declare="true"
    description="The ratio actually used for the media display, considering defaults if no ratio has been provided.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ variable name-given="isYouTube" declare="true"
    description="If true, the media file is a YouTube video." %>

<%@ variable name-given="isSoundCloud" declare="true"
    description="If true, the media file is a SoundCloud audio track." %>

<%@ variable name-given="isVideo" declare="true"
    description="If true, the media file is an external video." %>

<%@ variable name-given="isAudio" declare="true"
    description="If true, the media file is an external audio track." %>

<%@ variable name-given="isFlexible" declare="true"
    description="If true, the media is created form a flexible embed code." %>

<%@ variable name-given="youTubeId" declare="true"
    description="The ID of the YouTube video." %>

<%@ variable name-given="youTubePreviewImg" declare="true"
    description="The preview image for the YouTube video." %>

<%@ variable name-given="template" declare="true"
    description="The template to use for the media file." %>

<%@ variable name-given="icon" declare="true"
    description="The overlay icon for the media file." %>

<%@ variable name-given="flexibleType" declare="true"
    description="If isFlexible=true, this provides more information about the type of flexible content.
    Currently supported return values are 'facebook', 'twitter' or 'main'.
    This can e.g. be used later to render the preview with a special CSS selector based to the name provided." %>

<%@ variable name-given="mediaPreviewHtml" declare="true"
    description="Optional HTML markup for media video preview that uses images taken directly from the external media server." %>

<%@ variable name-given="cssClass" declare="true"
    description="An additional CSS class to be used in the HTML generated later." %>

<%@ variable name-given="cookieMessage" declare="true"
    description="The message to display if external cookies have not been accepted." %>

<%@ variable name-given="placeholderMessage" declare="true"
    description="The message to display for the placeholder (only for autoplay media element)." %>


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


<c:set var="width" value="${cms:mathRound(cms:toNumber(fn:substringBefore(ratio, '-'), 4))}" />
<c:set var="height" value="${cms:mathRound(cms:toNumber(fn:substringAfter(ratio, '-'), 3))}" />
<c:set var="usedRatio" value="${width}-${height}" />

<c:choose>
    <c:when test="${content.value.MediaContent.value.YouTube.isSet}">
        <c:set var="isYouTube" value="${true}" />
    </c:when>
    <c:when test="${content.value.MediaContent.value.SoundCloud.isSet}">
        <c:set var="isSoundCloud" value="${true}" />
    </c:when>
    <c:when test="${content.value.MediaContent.value.Video.isSet}">
        <c:set var="isVideo" value="${true}" />
    </c:when>
    <c:when test="${content.value.MediaContent.value.Audio.isSet}">
        <c:set var="isAudio" value="${true}" />
    </c:when>
    <c:when test="${content.value.MediaContent.value.Flexible.isSet}">
        <c:set var="isFlexible" value="${true}" />
    </c:when>
</c:choose>

<mercury:list-element-status>

<c:if test="${content.value.Image.isSet}">
    <c:set var="image" value="${content.value.Image}" />
</c:if>

<c:if test="${content.value.Copyright.isSet}">
    <c:set var="copyright" value="${content.value.Copyright}" />
</c:if>

<c:set var="mediaPreviewHtml" value="${null}" />

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:choose>

    <c:when test="${isYouTube}">
        <c:set var="cookieMessage"><fmt:message key="msg.page.privacypolicy.message.media.youtube" /></c:set>
        <c:set var="placeholderMessage"><fmt:message key="msg.page.placeholder.media.youtube" /></c:set>
        <c:set var="youTubeId" value="${content.value.MediaContent.value.YouTube.value.YouTubeId}" />
        <c:set var="defaultPreview"><mercury:attribute-schema-param param="mercuryYouTubePreviewDefault" /></c:set>
        <c:set var="youTubePreviewImg" value="${content.value.MediaContent.value.YouTube.value.YouTubePreview.isSet
            ? content.value.MediaContent.value.YouTube.value.YouTubePreview
            : defaultPreview}"
        />
        <c:set var="youTubePreviewImg" value="${youTubePreviewImg eq 'fallback'
            ? not empty image ? 'none' : 'hqdefault.jpg'
            : youTubePreviewImg}"
        />
        <c:set var="template"><%--
        --%><iframe src="https://www.youtube-nocookie.com/embed/${youTubeId}?<%--
            --%>autoplay=1&rel=0&iv_load_policy=3&modestbranding=1" <%--
            --%>style="border: none;" allow="autoplay; encrypted-media" allowfullscreen><%--
        --%></iframe><%----%>
        </c:set>
        <c:choose>
            <c:when test="${content.value.MediaContent.value.YouTube.value.Icon.isSet}">
                <c:set var="icon" value="${content.value.MediaContent.value.YouTube.value.Icon}" />
            </c:when>
            <c:otherwise>
                <c:set var="icon" value="youtube-play" />
            </c:otherwise>
        </c:choose>
        <c:set var="cssClass" value="video" />

        <c:if test="${youTubePreviewImg ne 'none'}">
            <c:set var="mediaPreviewHtml">
                <c:set var="srcSet"><%--
                --%>https://img.youtube.com/vi/${youTubeId}/default.jpg 120w, <%--
                --%>https://img.youtube.com/vi/${youTubeId}/hqdefault.jpg 480w<%--
                --%></c:set>
                <c:if test="${not (youTubePreviewImg eq 'hqdefault.jpg')}">
                    <c:set var="srcSet" value="${srcSet}, https://img.youtube.com/vi/${youTubeId}/${youTubePreviewImg} 640w" />
                </c:if>
                <mercury:image-lazyload
                    srcUrl="https://img.youtube.com/vi/${youTubeId}/${youTubePreviewImg}"
                    srcSet="${srcSet}"
                    alt="${placeholderMessage} - ${content.value.Title}"
                    cssImage="animated"
                    noScript="${caseStandardElement}"
                    lazyLoad="${not caseDynamicListNoscript}"
                />
            </c:set>
       </c:if>
    </c:when>

    <c:when test="${isSoundCloud}">
        <c:set var="cookieMessage"><fmt:message key="msg.page.privacypolicy.message.media.soundcloud" /></c:set>
        <c:set var="placeholderMessage"><fmt:message key="msg.page.placeholder.media.soundcloud" /></c:set>
        <c:set var="soundCloudTrackId" value="${content.value.MediaContent.value.SoundCloud.value.SoundCloudTrackId}" />
        <c:set var="template"><%--
            --%><iframe width="100%" height="100%" scrolling="no" style="border: none;" allow="autoplay" <%--
            --%>src="https://w.soundcloud.com/player/?url=<%--
                --%>https%3A//api.soundcloud.com/tracks/${soundCloudTrackId}&<%--
                    --%>auto_play=true&<%--
                    --%>color=%23XXcolor-main-themeXX&<%--
                    --%>buying=false&<%--
                    --%>sharing=true&<%--
                    --%>show_user=true&<%--
                    --%>hide_related=true&<%--
                    --%>show_comments=false&<%--
                    --%>show_reposts=false&<%--
                    --%>show_teaser=false&<%--
                    --%>visual=true"><%--
        --%></iframe><%----%>
        </c:set>
        <c:choose>
            <c:when test="${content.value.MediaContent.value.SoundCloud.value.Icon.isSet}">
                <c:set var="icon" value="${content.value.MediaContent.value.SoundCloud.value.Icon}" />
            </c:when>
            <c:otherwise>
                <c:set var="icon" value="soundcloud" />
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:when test="${isVideo}">
        <c:set var="cookieMessage"><fmt:message key="msg.page.privacypolicy.message.media.video" /></c:set>
        <c:set var="placeholderMessage"><fmt:message key="msg.page.placeholder.media.video" /></c:set>
        <c:set var="videoData" value="${content.value.MediaContent.value.Video.value.Data}" />
        <c:choose>
            <c:when test="${fn:startsWith(videoData,'{')}">
                <c:set var="videoData" value="${cms:jsonToMap(videoData)}" />
                <c:set var="videoSrc" value="${videoData['preview-url']}" />
                <c:set var="videoCopyright" value="${videoData['copyright']}" />
                <c:set var="videoPreviewImg" value="${videoData['webimage']}" />
                <c:set var="extPreviewImg" value="${not empty videoPreviewImg}" />
                <c:set var="embedFromBynder" value="${empty videoSrc}" />
                <c:if test="${embedFromBynder}">
                    <c:set var="mamVideoId" value="${videoData['id']}" />
                    <c:set var="mamVideoAccountUrl" value="${videoData['account-url']}" />
                </c:if>
            </c:when>
            <c:otherwise>
                <c:set var="videoSrc" value="${videoData}" />
                <c:if test="${image.isSet}">
                    <c:set var="videoPreviewImg" value="${image.value.Image.toLink}" />
                </c:if>
            </c:otherwise>
        </c:choose>
        <c:set var="template">
            <c:choose>
                <c:when test="${embedFromBynder}">
                    <div data-bynder-widget="video-item" data-media-id="${mamVideoId}" data-autoplay="true" data-muted="false" ><%--
                    --%><script <%--
                        --%>id="bynder-widgets-js" <%--
                        --%>data-account-url="${mamVideoAccountUrl}" <%--
                        --%>data-language="${cms.locale.language}" <%--
                        --%>src="https://d8ejoa1fys2rk.cloudfront.net/bynder-embed/latest/bynder-embed.js"><%----%>
                        </script><%--
                    --%></div><%----%>
                </c:when>
                <c:otherwise>
                    <video <%--
                        --%>class="fitin" <%--
                        --%>controls <%--
                        --%>autoplay <%--
                        --%>preload="auto" <%--
                        --%>src="${videoSrc}" <%--
                        --%><c:if test="${not empty videoPreviewImg}">poster="${videoPreviewImg}"></c:if><%----%>
                    </video><%----%>
                </c:otherwise>
            </c:choose>
        </c:set>
        <c:if test="${extPreviewImg and (not empty videoPreviewImg) and (videoPreviewImg ne 'none')}">
            <c:set var="mediaPreviewHtml">
                <c:set var="srcSet"><%--
                --%>${fn:replace(videoPreviewImg, 'webimage', 'thul')} 250w, <%--
                --%>${videoPreviewImg} 800w</c:set>
                <mercury:image-lazyload
                    srcUrl="${videoPreviewImg}"
                    srcSet="${srcSet}"
                    alt="${content.value.Title}"
                    cssImage="animated"
                    noScript="${caseStandardElement}"
                    lazyLoad="${not caseDynamicListNoscript}"
                />
            </c:set>
        </c:if>
        <c:if test="${(empty copyright) and (not empty videoCopyright) and (videoCopyright ne 'none')}">
            <c:set var="copyright" value="${videoCopyright}" />
        </c:if>
        <c:choose>
            <c:when test="${content.value.MediaContent.value.Video.value.Icon.isSet}">
                <c:set var="icon" value="${content.value.MediaContent.value.Video.value.Icon}" />
            </c:when>
            <c:otherwise>
                <c:set var="icon" value="youtube-play" />
            </c:otherwise>
        </c:choose>
        <c:set var="cssClass" value="video" />
    </c:when>

    <c:when test="${isAudio}">
        <c:set var="cookieMessage"><fmt:message key="msg.page.privacypolicy.message.media.audio" /></c:set>
        <c:set var="template" value="audio" />
    </c:when>

    <c:when test="${isFlexible}">
        <c:set var="cookieMessage"><fmt:message key="msg.page.privacypolicy.message.media.generic" /></c:set>
        <c:set var="placeholderMessage"><fmt:message key="msg.page.placeholder.media.generic" /></c:set>
        <c:set var="template" value="${content.value.MediaContent.value.Flexible.value.Code}" />
        <c:choose>
            <c:when test="${content.value.MediaContent.value.Flexible.value.Icon.isSet}">
                <c:set var="icon" value="${content.value.MediaContent.value.Flexible.value.Icon}" />
                <c:choose>
                    <c:when test="${fn:startsWith(icon, 'facebook')}">
                        <c:set var="flexibleType" value="facebook" />
                    </c:when>
                    <c:when test="${fn:startsWith(icon, 'twitter')}">
                        <c:set var="flexibleType" value="twitter" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="flexibleType" value="main" />
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <c:set var="icon" value="play" />
            </c:otherwise>
        </c:choose>
    </c:when>

</c:choose>

</cms:bundle>

</mercury:list-element-status>


<jsp:doBody/>