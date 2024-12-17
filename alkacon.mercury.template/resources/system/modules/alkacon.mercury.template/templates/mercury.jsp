<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:content-properties>
<m:template-parts containerName="mercury-page">

<jsp:attribute name="top">

<c:set var="cmsstatus" value="${cms.isEditMode ? ' opencms-page-editor' : null}${cms.isEditMode and cms.modelGroupPage ? ' opencms-group-editor' : null}" />
<c:set var="pageclass" value="${templateVariant}${allowTemplateMods ? ' '.concat(contentProperties['mercury.css.class']) : null}" />

<c:set var="canonicalLinks">
    <m:meta-canonical renderMetaTags="${true}" >
        <m:meta-info canonicalURL="${canonicalURL}" contentPropertiesSearch="${contentPropertiesSearchDetail}" />
    </m:meta-canonical>
</c:set>

<!DOCTYPE html>
<html lang="${cms.locale}" class="noscript${cmsstatus}${pageclass}">
<head>

<%-- Special CSS in case JavaScript is disabled --%>
<noscript><style>html.noscript .hide-noscript { display: none !important; }</style></noscript>
<script>document.documentElement.classList.remove("noscript");document.documentElement.classList.add("hasscript");</script>
<%-- Static JavaScript that provides a 'mercury.ready()' method for additional scripts --%>
<m:print script="${true}">
<script>
mercury = function(){
    var n=function(){
        var n=[];
        return{
            ready: function(t){
                n.push(t)
            },
            getInitFunctions: function(){
                return n
            }
        }
    }(),
    t=function(t){
        if("function"!=typeof t) return n;
        n.ready(t)
    };
    return t.getInitFunctions=function(){
        return n.getInitFunctions()
    },
    t.ready=function(n){
        this(n)
    },
    t
}();
var __isOnline=${cms.isOnlineProject},
    __scriptPath="<cms:link>%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)</cms:link>"
</script>
</m:print>

<%-- Load the main JavaScript in async mode --%>
<script async src="<m:link-resource resource='%(link.weak:/system/modules/alkacon.mercury.theme/js/mercury.js:2cf5d884-fea8-11e8-aee0-0242ac11002b)'/>"></script>

${canonicalLinks}

<cms:enable-ade />

<m:load-plugins group="js-async" />
<m:load-plugins group="js-defer" />
<m:load-plugins group="template-head-includes" type="jsp" />

<c:choose>
    <c:when test="${empty cms.plugins['custom-css']}">
        <%-- Use default CSS configuration --%>
        <m:load-icons>
            <c:set var="cssTheme" value="${empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-standard.min.css' : contentPropertiesSearch['mercury.theme']}" />
            <link rel="stylesheet" href="<m:link-resource resource='${cssTheme}'/>"><%----%>
            <m:nl />
        </m:load-icons>
    </c:when>
    <c:otherwise>
        <%-- Use custom CSS plugin --%>
        <m:load-plugins group="custom-css" type="jsp" />
    </c:otherwise>
</c:choose>

<%-- Include CSS from plugins after main Mercury CSS --%>
<m:load-plugins group="css" />
<m:load-plugins group="css-inline" />

<%-- Include additional CSS / JS from Mercury template modifications (if allowed) --%>
<c:if test="${allowTemplateMods}">
    <m:load-resource path="${contentPropertiesSearch['mercury.extra.css']}" defaultPath="${cms.subSitePath}" name="custom.css">
        <link rel="stylesheet" href="<m:link-resource resource='${resourcePath}'/>"><m:nl />
    </m:load-resource>
    <m:load-resource path="${contentPropertiesSearch['mercury.extra.js']}" defaultPath="${cms.subSitePath}" name="custom.js">
        <script src="<m:link-resource resource='${resourcePath}'/>" defer></script><m:nl />
    </m:load-resource>
</c:if>

<c:choose>
    <c:when test="${empty cms.plugins['custom-favicon']}">
        <%-- Use default favicon configuration --%>
        <c:set var="faviconPath" value="${empty contentPropertiesSearch['mercury.favicon'] ? '/favicon.png' : contentPropertiesSearch['mercury.favicon']}" />
        <c:if test="${not (cms.vfs.existsResource[faviconPath] and cms.vfs.readResource[faviconPath].isImage)}">
            <c:set var="faviconPath">/system/modules/alkacon.mercury.theme/img/favicon.png</c:set>
        </c:if>
        <c:set var="favIconImage" value="${cms.vfs.readResource[faviconPath].toImage.scaleRatio['1-1']}" />
        <link rel="apple-touch-icon" sizes="180x180" href="${favIconImage.scaleWidth[180]}"><m:nl />
        <link rel="icon" type="image/png" sizes="32x32" href="${favIconImage.scaleWidth[32]}"><m:nl />
        <link rel="icon" type="image/png" sizes="16x16" href="${favIconImage.scaleWidth[16]}"><m:nl />
    </c:when>
    <c:otherwise>
        <%-- Use custom favicon plugin --%>
        <m:load-plugins group="custom-favicon" type="jsp" />
    </c:otherwise>
</c:choose>

</head>
<body>

<%-- Skip to main content links  --%>
<a class="btn visually-hidden-focusable-fixed" id="skip-to-content" href="#main-content"><fmt:message key="msg.aria.skip-to-content" /></a><%----%>

</jsp:attribute>


<jsp:attribute name="middle">
<c:choose>
    <c:when test="${empty cms.plugins['custom-page-container']}">
        <c:set var="cssgutter" value="${empty contentPropertiesSearch['mercury.css.gutter'] ? '#' : contentPropertiesSearch['mercury.css.gutter']}" />
        <cms:container
            name="mercury-page"
            type="area"
            editableby="ROLE.DEVELOPER">

            <cms:param name="cssgrid" value="#" />
            <cms:param name="cssgutter" value="${cssgutter}" />
            <cms:param name="cssgutterbase" value="${cssgutter}" />

            <c:set var="message"><fmt:message key="msg.page.layout.topContainer" /></c:set>
            <m:container-box
                label="${message}"
                boxType="container-box"
                type="area"
                role="ROLE.DEVELOPER"
            />

        </cms:container>
        <m:nl/>
    </c:when>
    <c:otherwise>
        <%-- Use custom main container plugin --%>
        <m:load-plugins group="custom-page-container" type="jsp" />
    </c:otherwise>
</c:choose>
</jsp:attribute>


<jsp:attribute name="bottom">
<%-- Page information transfers OpenCms state information to JavaScript --%>
<m:pageinfo contentPropertiesSearch="${contentPropertiesSearch}" />

<%-- Load custom body plugins --%>
<m:load-plugins group="custom-body" type="jsp" />

<%-- Include custom foot if allowed --%>
<c:if test="${allowTemplateIncludes}">
     <m:load-resource path="${contentPropertiesSearch['mercury.extra.foot']}">
         <cms:include file="${resourcePath}" cacheable="false" /><m:nl />
     </m:load-resource>
</c:if>

<%-- Privacy policy banner markup --%>
<m:privacy-policy-banner contentUri="${contentUri}" contentPropertiesSearch="${contentPropertiesSearch}" />

</body>
</html>
</jsp:attribute>

</m:template-parts>
</m:content-properties>

</cms:bundle>
