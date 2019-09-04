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

<mercury:content-properties>
<mercury:template-parts containerName="mercury-page">

<jsp:attribute name="top">

<c:set var="cmsstatus">${cms.isEditMode ? 'opencms-page-editor ' : ''}${cms.isEditMode and cms.modelGroupPage ? 'opencms-group-editor ' : ''}</c:set>
<c:set var="pageclass">${contentProperties['mercury.css.class']}</c:set>

<!DOCTYPE html>
<html lang="${cms.locale}" class="noscript ${cmsstatus}${empty pageclass ? '' : ' '}${pageclass}">
<head>

<%-- Special CSS in case JavaScript is disabled --%>
<noscript><style>html.noscript .hide-noscript { display: none; }</style></noscript>

<script>
<%-- Static JavaScript that provides a 'mercury.ready()' method for additional scripts --%>
mercury=function(){var n=function(){var n=[];return{ready:function(t){n.push(t)},load:function(t){n.push(t)},getInitFunctions:function(){return n}}}(),t=function(t){if("function"!=typeof t)return n;n.ready(t)};return t.getInitFunctions=function(){return n.getInitFunctions()},t.load=function(n){this(n)},t.ready=function(n){this(n)},t}();
var __isOnline=${cms.isOnlineProject},
__scriptPath="<cms:link>%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)</cms:link>"
</script>
<%-- Load the main JavaScript in async mode --%>
<c:set var="jsThemeRes" value="${cms.vfs.readResource['%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)']}" />
<script async src="<cms:link>${jsThemeRes.sitePath}?ver=${jsThemeRes.dateLastModified}</cms:link>"></script>

<mercury:meta-info contentUri="${contentUri}" contentPropertiesSearch="${contentPropertiesSearchDetail}" />

<%-- Add favicon --%>
<c:set var="faviconPath" value="${empty contentPropertiesSearch['mercury.favicon'] ? '/favicon.png' : contentPropertiesSearch['mercury.favicon']}" />
<c:if test="${not (cms.vfs.existsResource[faviconPath] and cms.vfs.readResource[faviconPath].isImage)}">
    <c:set var="faviconPath">/system/modules/alkacon.mercury.theme/img/favicon.png</c:set>
</c:if>
<c:set var="favIconImage" value="${cms.vfs.readResource[faviconPath].toImage.scaleRatio['1-1']}" />
<link rel="apple-touch-icon" sizes="180x180" href="${favIconImage.scaleWidth[180]}">
<link rel="icon" type="image/png" sizes="32x32" href="${favIconImage.scaleWidth[32]}">
<link rel="icon" type="image/png" sizes="16x16" href="${favIconImage.scaleWidth[16]}">

<cms:enable-ade />
<cms:headincludes type="css" />

<c:set var="replaceCss" value="${empty contentPropertiesSearch['mercury.replace.head'] ? 'none' : contentPropertiesSearch['mercury.replace.head']}" />
<c:choose>
    <c:when test="${not empty replaceCss and replaceCss ne 'none'}">
        <%-- This way an "replaceCss" JSP can override the default CSS theme. --%>
        <cms:include file="${replaceCss}" />
    </c:when>
    <c:otherwise>
        <%-- Common CSS and theme CSS --%>
        <c:set var="cssTheme" value="${empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-red.min.css' : contentPropertiesSearch['mercury.theme']}" />
        <c:set var="cssCommonRes" value="${cms.vfs.readResource['%(link.weak:/system/modules/alkacon.mercury.theme/css/base.min.css:bf8f6ace-feab-11e8-aee0-0242ac11002b)']}" />
        <link rel="stylesheet" href="<cms:link>${cssCommonRes.sitePath}?ver=${cssCommonRes.dateLastModified}</cms:link>">
        <c:set var="cssThemeRes" value="${cms.vfs.readResource[cssTheme]}" />
        <link rel="stylesheet" href="<cms:link>${cssThemeRes.sitePath}?ver=${cssThemeRes.dateLastModified}</cms:link>">
    </c:otherwise>
</c:choose>

<%-- Additional extra CSS --%>
<c:set var="extraCSS" value="${empty contentPropertiesSearch['mercury.extra.css'] ? 'none' : contentPropertiesSearch['mercury.extra.css']}" />
<c:if test="${not empty extraCSS and (extraCSS ne 'none')}">
    <c:set var="extraCSS" value="${extraCSS}custom.css" />
    <c:if test="${cms.vfs.exists[extraCSS]}">
        <c:set var="cssExtraCSS" value="${cms.vfs.readResource[extraCSS]}" />
        <link rel="stylesheet" href="<cms:link>${cssExtraCSS.sitePath}?ver=${cssExtraCSS.dateLastModified}</cms:link>">
    </c:if>
</c:if>

<%-- Additional extra head include, can e.g. be used to add inline CSS --%>
<c:set var="extraHead" value="${empty contentPropertiesSearch['mercury.extra.head'] ? 'none' : contentPropertiesSearch['mercury.extra.head']}" />
<c:if test="${not empty extraHead and (extraHead ne 'none') and cms.vfs.exists[extraHead]}">
    <cms:include file="${extraHead}" />
</c:if>

</head>
<body>
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

    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <c:set var="message"><fmt:message key="msg.page.layout.topContainer" /></c:set>
    </cms:bundle>

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

<c:set var="extraJS" value="${empty contentPropertiesSearch['mercury.extra.js'] ? 'none' : contentPropertiesSearch['mercury.extra.js']}" />
<c:if test="${not empty extraJS and (extraJS ne 'none')}">
    <c:set var="extraJS" value="${extraJS}custom.js" />
    <c:if test="${cms.vfs.exists[extraCSS]}">
        <c:set var="jsExtraJS" value="${cms.vfs.readResource[extraJS]}" />
        <script src="<cms:link>${jsExtraJS.sitePath}?ver=${jsExtraJS.dateLastModified}</cms:link>"></script>
    </c:if>
</c:if>

<c:set var="extraFoot" value="${empty contentPropertiesSearch['mercury.extra.foot'] ? 'none' : contentPropertiesSearch['mercury.extra.foot']}" />
<c:if test="${not empty extraFoot and extraFoot ne 'none'}"><cms:include file="${extraFoot}" /></c:if>

<%-- Privacy policy markup is inserted last --%>
<mercury:privacy-policy-banner contentUri="${contentUri}" contentPropertiesSearch="${contentPropertiesSearch}" />

</body>
</html>
</jsp:attribute>

</mercury:template-parts>
</mercury:content-properties>
