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
    <c:set var="viteMercuryTgt" value="${cms.isOnlineProject ? null : header['Vite-mercury-tgt']}" />
    <%-- If a Mercury traget path has been specified, the site template must include this as a substring --%>
    <c:if test="${(empty viteMercuryTgt) or fn:contains(cssTheme, viteMercuryTgt)}">
        <%-- Set Vite path information from request heders, these will be only present in case a vite proxy is used --%>
        <c:set var="viteCssPath" value="${cms.isOnlineProject ? null : header['Vite-css-path']}" />
        <c:set var="viteMercurySrc" value="${cms.isOnlineProject ? null : header['Vite-mercury-src']}" />
        <c:set var="viteMercuryJs" value="${cms.isOnlineProject ? null : header['Vite-mercury-js']}" />
    </c:if>
</c:if>

<c:choose>
    <c:when test="${part eq 'js'}">

        <c:choose>
            <c:when test="${(not empty viteMercuryJs)}">
                <%-- Use Vite to replace the main Mercury JavaScript --%>
                <!-- Vite integration - Mercury JavaScript replaced: --><m:nl />
                <script type="module" src="/@vite/client"></script><m:nl />
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
            <c:if test="${(empty viteMercuryJs) and ((not empty viteMercurySrc) or (not empty viteCssPath))}">
                <%-- Add 'magic' line to enable Vite HMR if it has not already been set above. --%>
                <script type="module" src="/@vite/client"></script><m:nl />
            </c:if>
            <c:choose>
                <c:when test="${(not empty viteMercurySrc)}">
                    <%-- Use Vite to replace the main Mercury theme SCSS file. --%>
                    <!-- Vite integration - Mercury SCSS replaced: --><m:nl />
                    <link rel="stylesheet" href="${viteMercurySrc}"><m:nl />
                </c:when>
                <c:otherwise>
                    <%-- Mirror the default code from mercury.jsp and include the configured theme. --%>
                    <c:set var="cssTheme" value="${empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-standard.min.css' : contentPropertiesSearch['mercury.theme']}" />
                    <link rel="stylesheet" href="<m:link-resource resource='${cssTheme}' />"><m:nl />
                </c:otherwise>
            </c:choose>
            <c:if test="${not empty viteCssPath}">
                <%-- Allow an additional custom CSS file from Vite. --%>
                <!-- Vite integration - Custom CSS: --><m:nl />
                <link rel="stylesheet" href="${viteCssPath}"><m:nl />
            </c:if>
        </m:load-icons>

    </c:when>
</c:choose>