<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    import="org.opencms.file.*, org.opencms.main.*, org.opencms.util.*"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">


<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="wallsioURL"             value="${setting.wallsioURL.toString}" />
<c:set var="wallsioTheme"           value="${setting.wallsioTheme.isSetNotNone ? setting.wallsioTheme.toString : null}" />
<c:set var="wallsioPosts"           value="${setting.wallsioPosts.toInteger(0)}" />
<c:set var="wallsioColumns"         value="${setting.wallsioColumns.toInteger(0)}" />
<c:set var="wallsioRemoveMargin"    value="${setting.wallsioRemoveMargin.toBoolean}" />
<c:set var="wallsioShowLoadMore"    value="${setting.wallsioShowLoadMore.toBoolean}" />

<c:choose>
<c:when test="${not empty wallsioURL}">

    <c:set var="htmlId"             value="wallsio${fn:replace(cms.element.editorHash().hashCode(), '-', '_')}" />
    <c:set var="wallsioURL"         value="${fn:trim(wallsioURL)}" />

    <c:if test="${not empty wallsioTheme}">
        <c:set var="paramTheme"     value="&amp;theme=${wallsioTheme}" />
    </c:if>

    <c:if test="${wallsioPosts > 0}">
        <c:set var="paramPosts"     value="&amp;initial_posts=${wallsioPosts}" />
    </c:if>

    <c:if test="${wallsioColumns > 0}">
        <c:set var="paramColumns"   value="&amp;columns=${wallsioColumns}" />
    </c:if>

    <c:if test="${wallsioShowLoadMore}">
        <c:set var="loadMoreData"><%--
        --%>data-injectloadmorebutton="1" <%--
        --%>data-loadmoretext="<fmt:message key="msg.page.list.pagination.more" />" <%--
        --%>data-loadmorecount="${wallsioPosts > 0 ? wallsioPosts : ''}" <%--
    --%></c:set>
    </c:if>

    <c:set var="wallsioScript">
        <script src="https://walls.io/js/wallsio-widget-1.2.js" <%--
        --%>data-wallurl="${wallsioURL}?nobackground=1&amp;show_header=0${paramTheme}${paramPosts}${paramColumns}" <%--
        --%>data-width="100%" <%--
        --%>data-autoheight="1" <%--
        --%>data-height="800" <%--
        --%>${loadMoreData} <%--
        --%>data-lazyload="1"></script><%----%>
    </c:set>
    <c:set var="wallsioScript" value="${cms:encode(wallsioScript)}" />

    <fmt:message var="cookieMessage" key="msg.page.privacypolicy.message.wallsio" />

    <div class="element type-wallsio pivot force-init ${cssWrapper}${wallsioRemoveMargin ? ' remove-margin' : ''}" data-external-cookies='{"message":"${cookieMessage}"}'><%----%>
        ${cms.reloadMarker}<%----%>

        <div id="${htmlId}" class="wallsio-container"></div><%----%>

        <script><%--
    --%>function init${htmlId}($, DEBUG) {<%--
        --%>if (PrivacyPolicy.cookiesAcceptedExternal()){<%--
            --%>$("#${htmlId}").append(decodeURIComponent('${wallsioScript}'));<%--
        --%>}<%--
    --%>}<%--
    --%>mercury.ready(init${htmlId});<%--
    --%></script><%----%>

        <m:alert-online showJsWarning="${true}" >
            <jsp:attribute name="text">
                <fmt:message key="msg.page.noscript.wallsio" />
            </jsp:attribute>
        </m:alert-online>

    </div><%----%>
    <m:nl />

</c:when>
<c:when test="${cms.isEditMode}">
    <m:alert type="error">
        <jsp:attribute name="head">
            <fmt:message key="msg.page.wallsio.noURL" />
        </jsp:attribute>
    </m:alert>
</c:when>
</c:choose>

</cms:bundle>