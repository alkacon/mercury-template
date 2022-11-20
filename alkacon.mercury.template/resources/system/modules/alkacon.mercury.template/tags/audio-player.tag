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

<%@ attribute name="copyright" type="java.lang.String" required="false"
    description="Copyright that is appended to the generated player." %>

<%@ attribute name="autoPlay" type="java.lang.Boolean" required="false"
    description="Controls if the media is directly played without clicking on the element first. Default is 'false'." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%-- Generate audio data JSON --%>
<cms:jsonobject var="audioData">
    <cms:jsonvalue key="src" value="${audioUri}" />
    <cms:jsonvalue key="autoplay" value="${autoPlay}" />
</cms:jsonobject>

<div class="audio-player" data-audio='${audioData.compact}'><%----%>
    <div class="audio-box"><%----%>
        <c:if test="${not empty headline}">
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
                <mercury:icon icon="stop" tag="div" cssWrapper="audio-stop" use="audioplayer" ariaLabel="Stop" />
                <mercury:icon icon="play" tag="div" cssWrapper="audio-play" use="audioplayer" ariaLabel="Play" />
                <mercury:icon icon="forward" tag="div" cssWrapper="audio-skip" use="audioplayer" ariaLabel="Skip" />
            </div><%----%>
            <div class="audio-length">${length}</div><%----%>
        </div>
    </div><%----%>
    <c:if test="${not empty copyright}">
        <div class="copyright"><div>&copy; ${copyright}</div></div><%----%>
    </c:if>
</div><%----%>
