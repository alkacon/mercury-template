<%@ tag pageEncoding="UTF-8"
    display-name="media-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a media content." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The media content to use." %>

<%@ attribute name="ratio" type="java.lang.String" required="true"
    description="Can be used to scale the media in a specific ratio,
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="showPrefaceAsSubtitle" type="java.lang.Boolean" required="false"
    description="Controls if the preface is displayed as subtitle below the media. Default is 'false'." %>

<%@ attribute name="showPreface" type="java.lang.Boolean" required="false"
    description="Controls if the preface is displayed. Default is 'true'." %>

<%@ attribute name="showIntro" type="java.lang.Boolean" required="false"
    description="Controls if the intro is displayed. Default is 'true'." %>

<%@ attribute name="showTitleOverlay" type="java.lang.Boolean" required="false"
    description="Controls if the title is displayed as overlay on the media. Default is 'false'." %>

<%@ attribute name="showCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the copyright is displayed. Default is 'false'." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the title overlay. Default is '2'" %>

<%@ attribute name="mediaDate" type="java.lang.String" required="false"
    description="Optional date that is displayed as overlay on the media." %>

<%@ attribute name="showMediaTime" type="java.lang.Boolean" required="false"
    description="Controls if the media time is displayed as overlay on the media. Default is 'false'." %>

<%@ attribute name="effect" type="java.lang.String" required="false"
    description="Optional 'class' atttributes to add to the media box div for effects." %>

<%@ attribute name="autoPlay" type="java.lang.Boolean" required="false"
    description="Controls if the media is directly played without clicking on the element first. Default is 'false'." %>



<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:media-vars content="${content}" ratio="${ratio}" autoPlay="${autoPlay}">

    <c:set var="addPaddingBox"      value="${not (isAudio and empty image)}" />
    <c:set var="addPlaceholder"     value="${autoPlay and not empty placeholderMessage}" />
    <c:set var="effect"             value="${(empty effect) or (effect eq 'none') ? '' : effect.concat(' effect-piece')}" />

    <c:set var="markupVisualOverlay">
        <c:if test="${not isAudio}">
            <div class="centered icon"><%----%>
                <span class="fa ${icon}"></span><%----%>
                <c:if test="${caseDynamicListNoscript or caseStandardElement}">
                    <mercury:alert-online showJsWarning="${true}" addNoscriptTags="${caseStandardElement}" />
                </c:if>
            </div><%----%>
        </c:if>
        <c:if test="${showTitleOverlay}">
            <c:set var="hsize" value="${empty hsize ? 2 : hsize}" />
            <c:set var="introHeadline">
                <mercury:intro-headline
                    intro="${empty showIntro or showIntro ? content.value.Intro : null}"
                    headline="${content.value.Title}"
                    level="${hsize}"
                />
                <mercury:heading
                    text="${content.value.Preface}"
                    level="${hsize + 1}"
                    css="sub-header"
                    test="${showPreface and not showPrefaceAsSubtitle}" />
            </c:set>
            <c:if test="${not empty introHeadline}">
                <div class="media-overlay-top">${introHeadline}</div>
            </c:if>
        </c:if>
        <c:if test="${not isAudio}">
            <c:if test="${(not empty content.value.Length and showMediaTime) or (not empty mediaDate)}">
                <div class="media-overlay-bottom"><%----%>
                    <c:if test="${not empty mediaDate}"><div class="media-date">${mediaDate}</div></c:if>
                    <c:if test="${not empty content.value.Length and showMediaTime}"><div class="media-length">${content.value.Length}</div></c:if>
                </div><%----%>
            </c:if>
        </c:if>
    </c:set>

    <mercury:padding-box
        cssWrapper="media-box ${not autoPlay ? effect : ''}"
        height="${height}"
        width="${width}"
        ratio="${usedRatio}"
        test="${addPaddingBox}">

        <div class="content${addPaddingBox ? '' : ' compact' }"><%----%>
            <c:if test="${not empty template}">
                <c:set var="mediaTemplate"><%--
                    --%>data-preview='{"template":"${cms:encode(template)}"}'<%--
                    --%><mercury:data-external-cookies modal="${isAudio or not autoPlay}" message="${cookieMessage}" />
                </c:set>
            </c:if>
             <div class="preview${autoPlay ? ' ensure-external-cookies' : ''}${addPlaceholder ? ' placeholder' : ''}"<%--
            --%>${mediaTemplate}<%--
            --%><c:if test="${addPlaceholder}">${' '}data-placeholder="${placeholderMessage}"</c:if><%--
            --%>${'>'}
                <c:choose>
                    <c:when test="${isAudio}">
                        <c:if test="${not empty image}">
                            <mercury:image-animated image="${image}" ratio="${usedRatio}" title="${content.value.Title}" />
                        </c:if>
                        <mercury:audio-player
                            audioUri="${content.value.MediaContent.value.Audio.value.URI.toLink}"
                            intro="${empty showIntro or showIntro ? content.value.Intro : null}"
                            headline="${hsize == 0 ? content.value.Title : null}"
                            length="${showMediaTime ? content.value.Length : null}"
                            date="${empty mediaDate ? '0:00' : mediaDate}"
                            copyright="${showCopyright ? copyright : null}"
                            autoPlay="${autoPlay}"
                        />
                        ${markupVisualOverlay}
                    </c:when>
                    <c:when test="${not autoPlay}">
                        <c:choose>
                            <c:when test="${not empty image}">
                                <mercury:image-animated image="${image}" ratio="${usedRatio}" title="${content.value.Title}" />
                            </c:when>
                            <c:when test="${not empty mediaPreviewHtml}">
                                <div class="centered image">${mediaPreviewHtml}</div><%----%>
                            </c:when>
                        </c:choose>
                        ${markupVisualOverlay}
                    </c:when>
                    <c:when test="${autoPlay}">
                        <mercury:alert-online showJsWarning="${true}" addNoscriptTags="${true}" />
                    </c:when>
                </c:choose>
            </div><%----%>
            <c:if test="${not isAudio and not autoPlay and showCopyright and ((not empty copyright) or (not empty mediaCopyright))}">
                <div class="copyright"><div>&copy; ${empty copyright ? mediaCopyright : copyright}</div></div><%----%>
            </c:if>
        </div><%----%>
    </mercury:padding-box>

    <c:if test="${showPreface and showPrefaceAsSubtitle and content.value.Preface.isSet}">
        <div class="subtitle"><c:out value="${content.value.Preface}" /></div><%----%>
    </c:if>

</mercury:media-vars>