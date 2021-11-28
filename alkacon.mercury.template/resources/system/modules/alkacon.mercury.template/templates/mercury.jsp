<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:content-properties>
<mercury:template-parts containerName="mercury-page">

<jsp:attribute name="top">

<c:set var="cmsstatus" value="${cms.isEditMode ? ' opencms-page-editor' : null}${cms.isEditMode and cms.modelGroupPage ? ' opencms-group-editor' : null}" />
<c:set var="pageclass" value="${templateVariant}${allowTemplateMods ? ' '.concat(contentProperties['mercury.css.class']) : null}" />

<!DOCTYPE html>
<html lang="${cms.locale}" class="noscript${cmsstatus}${pageclass}">
<head>

<%-- Special CSS in case JavaScript is disabled --%>
<noscript><style>html.noscript .hide-noscript { display: none !important; }</style></noscript>

<script><%-- Static JavaScript that provides a 'mercury.ready()' method for additional scripts
--%>mercury=function(){var n=function(){var n=[];return{ready:function(t){n.push(t)},load:function(t){n.push(t)},getInitFunctions:function(){return n}}}(),t=function(t){if("function"!=typeof t)return n;n.ready(t)};return t.getInitFunctions=function(){return n.getInitFunctions()},t.load=function(n){this(n)},t.ready=function(n){this(n)},t}();<%--
--%>var __isOnline=${cms.isOnlineProject},<%--
--%>__scriptPath="<cms:link>%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)</cms:link>"<%--
--%></script>
<%-- Load the main JavaScript in async mode --%>
<script async src="<mercury:link-resource resource='%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)'/>"></script>

<mercury:meta-canonical renderMetaTags="${true}" >
    <mercury:meta-info
        canonicalURL="${canonicalURL}"
        contentPropertiesSearch="${contentPropertiesSearchDetail}"
    />
</mercury:meta-canonical>

<%-- Add favicon --%>
<c:set var="faviconPath" value="${empty contentPropertiesSearch['mercury.favicon'] ? '/favicon.png' : contentPropertiesSearch['mercury.favicon']}" />
<c:if test="${not (cms.vfs.existsResource[faviconPath] and cms.vfs.readResource[faviconPath].isImage)}">
    <c:set var="faviconPath">/system/modules/alkacon.mercury.theme/img/favicon.png</c:set>
</c:if>
<c:set var="favIconImage" value="${cms.vfs.readResource[faviconPath].toImage.scaleRatio['1-1']}" />
<link rel="apple-touch-icon" sizes="180x180" href="${favIconImage.scaleWidth[180]}">
<link rel="icon" type="image/png" sizes="32x32" href="${favIconImage.scaleWidth[32]}">
<link rel="icon" type="image/png" sizes="16x16" href="${favIconImage.scaleWidth[16]}">
<%-- Preload Fork Awesome --%>
<link rel="preload" href="<cms:link>/system/modules/alkacon.mercury.theme/fonts/</cms:link>forkawesome-webfont.woff2?v=1.1.7" as="font" type="font/woff2" crossorigin>

<cms:enable-ade />
<cms:headincludes type="css" />

<mercury:load-plugins group="template-head-includes" type="jsp-nocache" />

<c:if test="${allowTemplateMods}">
    <c:set var="replaceCss" value="${empty contentPropertiesSearch['mercury.replace.head'] ? 'none' : contentPropertiesSearch['mercury.replace.head']}" />
</c:if>

<c:choose>
    <c:when test="${not empty replaceCss and replaceCss ne 'none'}">
        <%-- This way an "replaceCss" JSP can override the default CSS theme. --%>
        <cms:include file="${replaceCss}" />
    </c:when>
    <c:otherwise>
        <%-- Common CSS and theme CSS --%>
        <c:set var="cssTheme" value="${empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-red.min.css' : contentPropertiesSearch['mercury.theme']}" />
        <link rel="stylesheet" href="<mercury:link-resource resource='%(link.weak:/system/modules/alkacon.mercury.theme/css/base.min.css:bf8f6ace-feab-11e8-aee0-0242ac11002b)'/>"><%----%>
        <mercury:nl />
        <link rel="stylesheet" href="<mercury:link-resource resource='${cssTheme}'/>"><%----%>
        <mercury:nl />
    </c:otherwise>
</c:choose>

<c:if test="${allowTemplateMods}">
    <%-- Additional CSS --%>
    <c:set var="extraCSS" value="${empty contentPropertiesSearch['mercury.extra.css'] ? 'none' : contentPropertiesSearch['mercury.extra.css']}" />
    <c:if test="${not empty extraCSS and (extraCSS ne 'none')}">
        <c:set var="extraCSS" value="${extraCSS}custom.css" />
        <c:if test="${cms.vfs.exists[extraCSS]}">
            <link rel="stylesheet" href="<mercury:link-resource resource='${extraCSS}'/>"><%----%>
            <mercury:nl />
        </c:if>
    </c:if>
    <%-- Additional head include, can e.g. be used to add inline CSS --%>
    <c:set var="extraHead" value="${empty contentPropertiesSearch['mercury.extra.head'] ? 'none' : contentPropertiesSearch['mercury.extra.head']}" />
    <c:if test="${not empty extraHead and (extraHead ne 'none') and cms.vfs.exists[extraHead]}">
        <cms:include file="${extraHead}" />
    </c:if>
</c:if>

</head>
<body>

<%-- Skip to main content link  --%>
<a class="btn sr-only sr-only-focusable" href="#main-content"><fmt:message key="msg.aria.skip-to-content" /></a>

</jsp:attribute>


<jsp:attribute name="middle">
<c:set var="cssgutter" value="${empty contentPropertiesSearch['mercury.css.gutter'] ? '#' : contentPropertiesSearch['mercury.css.gutter']}" />
<cms:container
    name="mercury-page"
    type="area"
    editableby="ROLE.DEVELOPER">

    <cms:param name="cssgrid" value="#" />
    <cms:param name="cssgutter" value="${cssgutter}" />
    <cms:param name="cssgutterbase" value="${cssgutter}" />

    <c:set var="message"><fmt:message key="msg.page.layout.topContainer" /></c:set>
    <mercury:container-box
        label="${message}"
        boxType="container-box"
        type="area"
        role="ROLE.DEVELOPER"
    />

</cms:container>
<mercury:nl/>
</jsp:attribute>


<jsp:attribute name="bottom">
<%-- Page information transfers OpenCms state information to JavaScript --%>
<mercury:pageinfo contentPropertiesSearch="${contentPropertiesSearch}" />

<%-- JavaScript blocking files placed at the end of the document so the pages load faster --%>
<cms:headincludes type="javascript" />

<c:if test="${allowTemplateMods}">
    <%-- Additional JS include --%>
    <c:set var="extraJS" value="${empty contentPropertiesSearch['mercury.extra.js'] ? 'none' : contentPropertiesSearch['mercury.extra.js']}" />
    <c:if test="${not empty extraJS and (extraJS ne 'none')}">
        <c:set var="extraJS" value="${extraJS}custom.js" />
        <c:if test="${cms.vfs.exists[extraJS]}">
            <script src="<mercury:link-resource resource='${extraJS}'/>"></script>
        </c:if>
    </c:if>
    <%-- Additional foot include, can e.g. be used to add scripts --%>
    <c:set var="extraFoot" value="${empty contentPropertiesSearch['mercury.extra.foot'] ? 'none' : contentPropertiesSearch['mercury.extra.foot']}" />
    <c:if test="${not empty extraFoot and extraFoot ne 'none'}"><cms:include file="${extraFoot}" /></c:if>
</c:if>

<%-- Privacy policy banner markup --%>
<mercury:privacy-policy-banner contentUri="${contentUri}" contentPropertiesSearch="${contentPropertiesSearch}" />

</body>
</html>
</jsp:attribute>

</mercury:template-parts>
</mercury:content-properties>

</cms:bundle>
