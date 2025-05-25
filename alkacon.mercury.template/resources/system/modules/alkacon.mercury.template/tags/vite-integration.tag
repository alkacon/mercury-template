<%@ tag pageEncoding="UTF-8"
    display-name="vite-integration"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Vite integration." %>


<%@ attribute name="part" type="java.lang.String" required="true"
    description="Specifies the part of the vite integration." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="contentPropertiesSearch" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri]}" />
<c:set var="cssTheme" value="${empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-standard.min.css' : contentPropertiesSearch['mercury.theme']}" />

<c:if test="${not cms.isOnlineProject}">
    <%-- Vite is only supported in the offline project --%>
    <c:set var="viteSecret" value="${cms.sitemapConfig.attribute['vite.secret'].toString}" />
    <c:set var="reqSecret" value="${header['X-Vite-Secret']}" />
    <c:choose>
        <c:when test="${(not empty viteSecret) and (viteSecret eq reqSecret)}">
            <c:set var="openCmsSite" value="${header['X-Vite-OpenCms-Site']}" />
            <%-- If openCmsSite has been specified, the OpenCms site path from the current URI must start with openCmsSite --%>
            <c:if test="${(empty openCmsSite) or fn:startsWith(cms.readResource(cms.uri()).getRootPath(), openCmsSite)}">
                <%-- Set Vite path information from request heders, these will be only present in case a vite proxy is used --%>
                <c:set var="viteEnabled" value="${true}" />
                <c:set var="viteReplaceCustom" value="${header['X-Vite-Replace-Custom'] eq 'true'}" />
                <c:set var="viteMercuryScss" value="${header['X-Vite-Mercury-Scss']}" />
                <c:set var="viteMercuryJs" value="${header['X-Vite-Mercury-Js']}" />
                <c:set var="viteAdditionalCss" value="${not empty header['X-Vite-Additional-Css'] ? fn:split(header['X-Vite-Additional-Css'], ',') : null}" />
                <c:set var="viteAdditionalJs" value="${not empty header['X-Vite-Additional-Js'] ? fn:split(header['X-Vite-Additional-Js'], ',') : null}" />
            </c:if>
        </c:when>
        <c:otherwise>
            <c:if test="${(not empty viteSecret) and (not empty reqSecret)}">
                <m:log channel="error" message="Vite integration: User ${cms.requestContext.currentUser.name} send bad vite secret for site '${cms.site.siteRoot}'." />
            </c:if>
        </c:otherwise>
    </c:choose>
</c:if>

<c:choose>
    <c:when test="${part eq 'js'}">

        <c:if test="${viteEnabled}">
            <!-- Vite integration - Enable HMR: --><m:nl />
            <script type="module" src="/@vite/client"></script><m:nl />
        </c:if>
        <c:choose>
            <c:when test="${not empty viteMercuryJs}">
                <!-- Vite integration - Mercury JavaScript replaced: --><m:nl />
                <script type="module" src="${viteMercuryJs}"></script><m:nl />
            </c:when>
            <c:otherwise>
                <%-- Mirror the default code from mercury.jsp and include the default JavaScript. --%>
                <script async src="<m:link-resource resource='/system/modules/alkacon.mercury.theme/js/mercury.js' />"></script><m:nl />
            </c:otherwise>
        </c:choose>

    </c:when>
    <c:when test="${part eq 'css'}">

        <m:load-icons>
            <c:set var="cssTheme" value="${empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-standard.min.css' : contentPropertiesSearch['mercury.theme']}" />
            <c:choose>
                <c:when test="${not empty viteMercuryScss}">
                    <c:if test="${fn:endsWith(viteMercuryScss, '/')}">
                        <c:choose>
                            <c:when test="${empty param.vf}">
                                <c:set var="styleRes" value="${cms.readResource(cssTheme)}" />
                                <c:if test="${not empty styleRes}">
                                    <c:set var="resName" value="${fn:substringBefore(styleRes.name, '.')}" />
                                    <c:set var="viteMercuryScss" value="${viteMercuryScss}${viteMercuryScss.endsWith('/') ? '' : '/'}${resName}.scss" />
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <c:set var="viteMercuryScss" value="${param.vf}" />
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <!-- Vite integration - Mercury SCSS replaced: --><m:nl />
                    <link rel="stylesheet" href="${viteMercuryScss}"><m:nl />
                </c:when>
                <c:otherwise>
                    <%-- Mirror the default code from mercury.jsp and include the configured theme. --%>
                    <link rel="stylesheet" href="<m:link-resource resource='${cssTheme}' />"><m:nl />
                </c:otherwise>
            </c:choose>
        </m:load-icons>

        <c:forEach var="cssFile" items="${viteAdditionalCss}">
            <!-- Vite integration - Additional CSS: --><m:nl />
            <link rel="stylesheet" href="${cssFile}"><m:nl />
        </c:forEach>
        <c:forEach var="jsFile" items="${viteAdditionalJs}">
            <!-- Vite integration - Additional JS: --><m:nl />
            <script src="${jsFile}" defer></script><m:nl />
        </c:forEach>

    </c:when>
    <c:when test="${part eq 'mods'}">

        <c:choose>
            <c:when test="${viteReplaceCustom}">
                <%-- Use Vite to replace all custom.css / custom.js files. --%>
                <m:load-resource path="${contentPropertiesSearch['mercury.extra.css']}" defaultPath="${cms.subSitePath}" name="custom.css">
                    <!-- Vite integration - Mercury Custom CSS: --><m:nl />
                    <link rel="stylesheet" href="/@opencms-vite-css${resourcePath}"><m:nl />
                </m:load-resource>
                <m:load-resource path="${contentPropertiesSearch['mercury.extra.js']}" defaultPath="${cms.subSitePath}" name="custom.js">
                    <!-- Vite integration - Mercury Custom JS: --><m:nl />
                    <script src="/@opencms-vite-js${resourcePath}" defer></script><m:nl />
                </m:load-resource>
            </c:when>
            <c:otherwise>
                <%-- Mirror the default code from mercury.jsp and include the custom.css. --%>
                <m:load-resource path="${contentPropertiesSearch['mercury.extra.css']}" defaultPath="${cms.subSitePath}" name="custom.css">
                    <link rel="stylesheet" href="<m:link-resource resource='${resourcePath}'/>"><m:nl />
                </m:load-resource>
                <m:load-resource path="${contentPropertiesSearch['mercury.extra.js']}" defaultPath="${cms.subSitePath}" name="custom.js">
                    <script src="<m:link-resource resource='${resourcePath}'/>" defer></script><m:nl />
                </m:load-resource>
            </c:otherwise>
        </c:choose>
    </c:when>

</c:choose>