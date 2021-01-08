<%@ tag pageEncoding="UTF-8"
    display-name="audio-player"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a player for audio media." %>

<%@ attribute name="audioUri" type="java.lang.String" required="true"
    description="The URI of the audio media to use." %>

<%@ attribute name="intro" type="java.lang.Object" required="false"
    description="The audio heading intro." %>

<%@ attribute name="headline" type="java.lang.Object" required="true"
    description="The audio heading headline." %>

<%@ attribute name="length" type="java.lang.String" required="false"
    description="The length of the audio file, used for the preview when the audio file is not loaded." %>

<%@ attribute name="date" type="java.lang.String" required="false"
    description="The date of the media file, shown in the preview when the audio file is not loaded." %>

<%@ attribute name="addMarkup" type="java.lang.String" required="false"
    description="An optional adittional markup that is appended to the generated player." %>

<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="The media preview image. Must be a nested image content."%>

<%@ attribute name="ratio" type="java.lang.String" required="false"
    description="Can be used to scale the media preview in a specific ratio.
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="showHeadline" type="java.lang.Boolean" required="false"
    description="Controls if the headline is shown in the player. Default is 'true'.
    This can be set to 'false' in case the 'addMarkup' already contains the headline." %>

<%@ attribute name="autoPlay" type="java.lang.Boolean" required="false"
    description="Controls if the media is directly played without clicking on the element first. Default is 'false'." %>

<%@ attribute name="outerDiv" type="java.lang.String" required="false"
    description="If provided, wraps the generated HTML in an outer DIV, using the agrument as CSS class attributes. " %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="cookieMessage"><fmt:message key="msg.page.privacypolicy.message.media.audio" /></c:set>
<c:set var="placeholderMessage"><fmt:message key="msg.page.placeholder.media.audio" /></c:set>
<c:set var="showHeadline" value="${empty showHeadline ? true : showHeadline}" />


<%-- Generate audio data JSON --%>
<cms:jsonobject var="audioData">
    <cms:jsonvalue key="src" value="${audioUri}" />
    <cms:jsonvalue key="autoplay" value="${autoPlay}" />
</cms:jsonobject>

<mercury:div css="${outerDiv}" test="${not empty outerDiv}">
    <c:choose>
        <c:when test="${not empty image}">
            <mercury:image-animated image="${image}" ratio="${ratio}" title="${headline}" />
        </c:when>
        <c:otherwise>
            <div class="centered">No image...</div><%----%>
        </c:otherwise>
    </c:choose>
    <div class="audio-box"><%----%>
        <div class="audio-player" data-audio='${audioData.compact}'><%----%>
            <c:if test="${showHeadline}">
                <div class="audio-headline"><%----%>
                    <c:if test="${not empty intro}">
                        <span class="intro"><c:out value="${intro}" />: </span><%----%>
                    </c:if>
                    <span class="headline"><c:out value="${headline}" /></span><%----%>
                </div><%----%>
            </c:if>
            <div class="audio-progress"><%----%>
                <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div><%----%>
            </div><%----%>
            <div class="audio-controls"><%----%>
                <div class="audio-pos">${date}</div><%----%>
                <div class="audio-buttons"><%----%>
                    <div class="fa fa-stop audio-stop"></div><%----%>
                    <div class="fa fa-play audio-play"></div><%----%>
                    <div class="fa fa-forward audio-skip"></div><%----%>
                </div><%----%>
                <div class="audio-length">${length}</div><%----%>
            </div>
        </div><%----%>
    </div><%----%>
    ${addMarkup}
</mercury:div>

</cms:bundle>



