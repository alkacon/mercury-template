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
    description="Option 'class' atttributes to add to the media box div for effects." %>

<%@ attribute name="autoPlay" type="java.lang.Boolean" required="false"
    description="Controls if the media is directly played without clicking on the element first. Default is 'false'." %>



<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:media-vars content="${content}" ratio="${ratio}">

    <c:set var="markupVisualOverlay">
        <div class="centered icon"><%----%>
            <span class="fa ${icon}"></span><%----%>
            <c:if test="${caseDynamicListNoscript or caseStandardElement}">
                <mercury:alert-online showJsWarning="${true}" addNoscriptTags="${caseStandardElement}" />
            </c:if>
        </div><%----%>
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
        <c:if test="${(not empty content.value.Length and showMediaTime) or (not empty mediaDate)}">
            <div class="media-overlay-bottom"><%----%>
                <c:if test="${not empty mediaDate}"><div class="media-date">${mediaDate}</div></c:if>
                <c:if test="${not empty content.value.Length and showMediaTime}"><div class="media-length">${content.value.Length}</div></c:if>
            </div><%----%>
        </c:if>
    </c:set>

    <mercury:padding-box cssWrapper="effect-box media-box ${not autoPlay ? effect : ''}" height="${height}" width="${width}" ratio="${ratio}">
        <div class="content"><%----%>
            <c:choose>
                <c:when test="${autoPlay}">
                    ${template}
                </c:when>
                <c:otherwise>
                    <c:if test="${not empty template}">
                        <c:set var="mediaTemplate">data-preview='{"template":"${cms:encode(template)}"}'</c:set>
                    </c:if>
                    <div class="preview" ${mediaTemplate}><%----%>
                        <c:choose>
                        <c:when test="${not empty image}">
                            <mercury:image-animated image="${image}" ratio="${ratio}" title="${content.value.Title}" />
                        </c:when>
                        <c:when test="${isYouTube and not empty youTubePreviewHtml}">
                            <div class="centered image">${youTubePreviewHtml}</div><%----%>
                        </c:when>
                        </c:choose>
                        ${markupVisualOverlay}
                    </div><%----%>
                    <c:if test="${showCopyright and not empty copyright}">
                        <div class="copyright"><div>&copy; ${copyright}</div></div><%----%>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div><%----%>
    </mercury:padding-box>

    <c:if test="${showPreface and showPrefaceAsSubtitle and content.value.Preface.isSet}">
        <div class="subtitle"><c:out value="${content.value.Preface}" /></div><%----%>
    </c:if>

</mercury:media-vars>