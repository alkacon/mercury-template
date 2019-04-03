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

<c:set var="containerName"><cms:property name="template.container" file="search" default="mercury-page" /></c:set>
<mercury:template-parts containerName="${containerName}">

<jsp:attribute name="top">

<c:set var="cmsstatus">${cms.isEditMode ? 'opencms-page-editor ' : ''}${cms.isEditMode and cms.modelGroupPage ? 'opencms-group-editor ' : ''}</c:set>
<!DOCTYPE html>
<html lang="${cms.locale}" class="noscript ${cmsstatus}">

<head>
<noscript>
<style>html.noscript .hide-noscript { display: none; }</style>
</noscript>

<c:set var="jsThemeRes" value="${cms.vfs.readResource['%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)']}" />
<script>
mercury=function(){var n=function(){var n=[];return{ready:function(t){n.push(t)},load:function(t){n.push(t)},getInitFunctions:function(){return n}}}(),t=function(t){if("function"!=typeof t)return n;n.ready(t)};return t.getInitFunctions=function(){return n.getInitFunctions()},t.load=function(n){this(n)},t.ready=function(n){this(n)},t}();
var __isOnline=${cms.isOnlineProject},
__scriptPath="<cms:link>%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)</cms:link>"
</script>
<script async src="<cms:link>${jsThemeRes.sitePath}?ver=${jsThemeRes.dateLastModified}</cms:link>"></script>

<mercury:meta-info/>

<c:set var="faviconPath">${cms.subSitePath}favicon.png</c:set>
<c:if test="${not cms.vfs.existsResource[faviconPath]}">
    <c:set var="faviconPath">system/modules/alkacon.mercury.theme/img/favicon_120.png</c:set>
</c:if>

<link rel="apple-touch-icon" href="<cms:link>${faviconPath}</cms:link>">
<link rel="icon" href="<cms:link>${faviconPath}</cms:link>" type="image/png">

<cms:enable-ade />
<cms:headincludes type="css" />

<c:set var="cssTheme"><cms:property name="template.theme" file="search" default="/system/modules/alkacon.mercury.theme/css/theme-red.min.css" /></c:set>
<c:set var="cssCommonRes" value="${cms.vfs.readResource['%(link.weak:/system/modules/alkacon.mercury.theme/css/base.min.css:bf8f6ace-feab-11e8-aee0-0242ac11002b)']}" />
<c:set var="cssThemeRes" value="${cms.vfs.readResource[cssTheme]}" />
<link rel="stylesheet" href="<cms:link>${cssCommonRes.sitePath}?ver=${cssCommonRes.dateLastModified}</cms:link>">
<link rel="stylesheet" href="<cms:link>${cssThemeRes.sitePath}?ver=${cssThemeRes.dateLastModified}</cms:link>">

</head>
<body>
</jsp:attribute>


<jsp:attribute name="middle">
<cms:container
    name="${containerName}"
    type="area"
    editableby="ROLE.DEVELOPER">

    <cms:param name="cssgrid" value="#" />

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
</jsp:attribute>


<jsp:attribute name="bottom">
<%-- Page information transfers OpenCms state information to JavaScript --%>
<mercury:pageinfo />

<%-- JavaScript blocking files placed at the end of the document so the pages load faster --%>
<cms:headincludes type="javascript" />

<%-- Privacy policy markup is inserted last --%>
<mercury:privacy-policy-banner />

</body>
</html>
</jsp:attribute>

</mercury:template-parts>





