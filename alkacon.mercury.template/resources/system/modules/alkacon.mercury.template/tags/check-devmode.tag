<%@ tag pageEncoding="UTF-8"
    display-name="check-devmode"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Check if CSS / JS dev mode (Vite integration) is active." %>


<%@ attribute name="part" type="java.lang.String" required="true"
    description="Specifies the part of the template that is processed." %>

<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="false"
    description="The properties read from the URI resource with search." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%-- Vite is only supported in the offline project --%>
<c:if test="${not cms.isOnlineProject}">
    <%-- Vite secret header must be present in request --%>
    <c:set var="reqSecret" value="${header['X-Vite-Secret']}" />
    <c:if test="${not empty reqSecret}">
        <%-- Vite secret header must match secret stored in user additional info --%>
        <c:set var="viteSecret" value="${cms.requestContext.currentUser.additionalInfo['Vite-Secret']}" />
        <c:set var="partCss" value="${part eq 'css'}" />
        <c:set var="DBGHEAD" value="${partCss and (param.devdebug eq '1')}" />
        <c:choose>
            <c:when test="${(not empty viteSecret) and (viteSecret eq reqSecret)}">
                <%-- Vite user must have developer role --%>
                <m:checkprincipal type="role" name="DEVELOPER">
                    <c:set var="partJs" value="${part eq 'js'}" />
                    <c:set var="partMods" value="${part eq 'mods'}" />
                    <c:set var="partMarker" value="${part eq 'marker'}" />
                    <c:set var="openCmsSite" value="${header['X-Vite-OpenCms-Site']}" />
                    <c:set var="uriRootPath" value="${cms.readResource(cms.uri()).getRootPath()}" />
                    <m:print test="${DBGHEAD}">
                        openCmsSite (header): [${openCmsSite}]
                        uri.rootPath: ${uriRootPath}
                    </m:print>
                    <%-- If openCmsSite has been specified, the OpenCms site path from the current URI must start with openCmsSite --%>
                    <c:if test="${(empty openCmsSite) or fn:startsWith(uriRootPath, openCmsSite)}">
                        <%-- Set Vite path information from request heders, these will be only present in case a vite proxy is used --%>
                        <c:set var="viteEnabled" value="${true}" />
                        <c:set var="viteReplaceCustom" value="${header['X-Vite-Replace-Custom'] eq 'true'}" />
                        <c:set var="viteMercuryScss" value="${header['X-Vite-Mercury-Scss']}" />
                        <c:set var="viteMercuryJs" value="${header['X-Vite-Mercury-Js']}" />
                        <c:set var="viteAdditionalCss" value="${not empty header['X-Vite-Additional-Css'] ? fn:split(header['X-Vite-Additional-Css'], ',') : null}" />
                        <c:set var="viteAdditionalJs" value="${not empty header['X-Vite-Additional-Js'] ? fn:split(header['X-Vite-Additional-Js'], ',') : null}" />
                        <c:if test="${(partCss or partMarker) and fn:endsWith(viteMercuryScss, '/')}">
                            <c:choose>
                                <c:when test="${empty param.vo}">
                                    <c:set var="themeRes" value="${cms.readResource(empty contentPropertiesSearch['mercury.theme'] ? '/system/modules/alkacon.mercury.theme/css/theme-standard.min.css' : contentPropertiesSearch['mercury.theme'])}" />
                                    <c:if test="${not empty themeRes}">
                                        <c:set var="navInfo" value="${themeRes.property['NavInfo']}" />
                                        <m:print test="${DBGHEAD}">
                                            viteMercuryScss (header): [${viteMercuryScss}]
                                            contentPropertiesSearch['mercury.theme']: ${contentPropertiesSearch['mercury.theme']}
                                            themeRes.rootPath: ${themeRes.rootPath}
                                            themeRes.name: ${themeRes.name}
                                            themeRes.property['NavInfo']: ${navInfo}
                                        </m:print>
                                        <c:choose>
                                            <c:when test="${fn:startsWith(navInfo, '/@')}">
                                                <c:set var="viteMercuryScss" value="${navInfo}" />
                                            </c:when>
                                            <c:when test="${fn:startsWith(navInfo, '/themes')}">
                                                <c:set var="viteMercuryScss" value="/scss${navInfo}" />
                                            </c:when>
                                            <c:when test="${(not fn:startsWith(themeRes.rootPath, '/system/modules/')) or (fn:endsWith(viteMercuryScss, '/themes/')) or (viteMercuryScss eq '/any/')}">
                                                <c:set var="viteMercuryScss" value="${null}" />
                                            </c:when>
                                        </c:choose>
                                        <c:choose>
                                            <c:when test="${not empty viteMercuryScss}">
                                                <c:set var="resName" value="${fn:substringBefore(themeRes.name, '.')}" />
                                                <c:if test="${not empty resName}">
                                                    <c:set var="viteMercuryScss" value="${viteMercuryScss}${fn:endsWith(viteMercuryScss, '/') ? '' : '/'}${resName}.scss" />
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="viteMercuryScss" value="${null}" />
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <c:set var="viteMercuryScss" value="${param.vo}" />
                                </c:otherwise>
                            </c:choose>
                            <m:print test="${DBGHEAD}">
                                viteMercuryScss (final): ${viteMercuryScss}
                            </m:print>
                        </c:if>
                    </c:if>
                </m:checkprincipal>
            </c:when>
            <c:otherwise>
                <c:if test="${not empty viteSecret}">
                    <m:print test="${DBGHEAD}">
                        Vite error: User ${cms.requestContext.currentUser.name} send bad vite secret.
                    </m:print>
                    <m:log channel="error" message="Vite integration: User ${cms.requestContext.currentUser.name} send bad vite secret for site '${cms.site.siteRoot}'." />
                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
</c:if>

<c:choose>
    <c:when test="${not viteEnabled}">

        <%-- Vite is disabled, just execute tbe body --%>
        <jsp:doBody/>

    </c:when>
    <c:when test="${partJs}">

        <!-- Vite integration - Enable HMR: --><m:nl />
        <script type="module" src="/@vite/client"></script><m:nl />
        <c:choose>
            <c:when test="${not empty viteMercuryJs}">
                <!-- Vite integration - Mercury JavaScript replaced: --><m:nl />
                <script type="module" src="${viteMercuryJs}"></script><m:nl />
            </c:when>
            <c:otherwise>
                <jsp:doBody/>
            </c:otherwise>
        </c:choose>

    </c:when>
    <c:when test="${partCss}">

        <c:choose>
            <c:when test="${not empty viteMercuryScss}">
                <m:load-icons>
                    <!-- Vite integration - Mercury SCSS replaced: --><m:nl />
                    <link rel="stylesheet" href="${viteMercuryScss}"><m:nl />
                </m:load-icons>
            </c:when>
            <c:otherwise>
                <jsp:doBody/>
            </c:otherwise>
        </c:choose>
        <c:forEach var="cssFile" items="${viteAdditionalCss}">
            <!-- Vite integration - Additional CSS: --><m:nl />
            <link rel="stylesheet" href="${cssFile}"><m:nl />
        </c:forEach>
        <c:forEach var="jsFile" items="${viteAdditionalJs}">
            <!-- Vite integration - Additional JS: --><m:nl />
            <script src="${jsFile}" defer></script><m:nl />
        </c:forEach>

    </c:when>
    <c:when test="${partMods}">

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
                <jsp:doBody/>
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:when test="${partMarker and cms.isEditMode}">

        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <m:print delimiter="">
                <style>
                    #vite-marker {
                        display: inline-block;
                        position: fixed !important;
                        right: 16px !important;
                        top: 0px !important;
                        overflow: hidden !important;
                        width: 14px !important;
                        height: 23px !important;
                        z-index: 300000 !important;
                        svg {
                            height: 30px !important;
                            width: 30px !important;
                            margin-left: -10px !important;
                        }
                    }
                    .vite-marker-tooltip {
                        --my-tooltip-zindex: 400000;
                        --my-tooltip-max-width: 600px;
                        --my-tooltip-margin: 0px;
                        --my-tooltip-font-size: 12px;
                        --my-tooltip-color: #fff;
                        --my-tooltip-bg: #474747;
                        --my-tooltip-padding-x: 12px;
                        --my-tooltip-padding-y: 6px;
                        --my-tooltip-border-radius: 4px;
                        --my-tooltip-opacity: 0.95;
                        --my-tooltip-arrow-width: 10px;
                        --my-tooltip-arrow-height: 5px;

                        position: fixed !important;
                        transform: none !important;
                        inset: 5px 65px auto auto !important;
                        margin: 0 !important;
                        font-family: "Open Sans", sans-serif !important;

                        .tooltip-arrow {
                            position: fixed !important;
                            width: var(--my-tooltip-arrow-height) !important;
                            height: var(--my-tooltip-arrow-width) !important;
                            inset: 20px 60px auto auto !important;
                            transform: none !important;
                            &::before {
                                inset: auto auto auto auto !important;
                                border-width: calc(var(--my-tooltip-arrow-width) * .5) 0 calc(var(--my-tooltip-arrow-width) * .5) var(--my-tooltip-arrow-height) !important;
                                border-left-color: var(--my-tooltip-bg) !important;
                                border-bottom-color: transparent !important;
                            }
                        }
                        strong {
                            font-weight: 600;
                        }
                        .vite-title {
                            font-size: 15px;
                        }
                    }
                    html:not(.opencms-page-editor) {
                        #vite-marker {
                            display: none;
                        }
                    }
                </style>
                <fmt:message var="viteTitle" key="msg.page.vite.active" />
                <c:set var="viteTooltip">
                    <m:print comment="${false}" delimiter="">
                        <strong class='vite-title'>${viteTitle}</strong>
                        <c:if test="${not empty viteMercuryScss}">
                            <c:set var="viteMercuryScssShort" value="${fn:replace(viteMercuryScss, '/template-src/scss/themes/', '|')}" />
                            <br><strong>Mercury SCSS:</strong> ${viteMercuryScssShort}
                        </c:if>
                        <c:if test="${not empty viteMercuryJs}">
                            <br><strong>Mercury JS:</strong> ${viteMercuryJs}
                        </c:if>
                        <c:if test="${viteReplaceCustom}">
                            <br><strong>Custom CSS / JS</strong>
                        </c:if>
                    </m:print>
                </c:set>
                <oc-div id="vite-marker" data-bs-toggle="tooltip" data-bs-html="true" data-bs-title="${viteTooltip}" data-bs-sanitize="true" data-bs-custom-class="vite-marker-tooltip">
                    <svg xmlns="http://www.w3.org/2000/svg" width="410" height="404" fill="none" viewBox="0 0 410 404">
                        <%--
                        <path fill="url(#a)" d="m399.6 59.5-184 329a10 10 0 0 1-17.4.1L10.6 59.6A10 10 0 0 1 21 44.8l184.2 32.9c1.2.2 2.4.2 3.6 0L389 44.8a10 10 0 0 1 10.5 14.7Z"/>
                        --%>
                        <path fill="url(#b)" d="M293 1.6 156.8 28.3a5 5 0 0 0-4 4.6l-8.4 141.4a5 5 0 0 0 6.1 5.2l38-8.8a5 5 0 0 1 6 6l-11.3 55a5 5 0 0 0 6.3 5.9l23.4-7.2a5 5 0 0 1 6.4 5.8L201.4 323c-1.1 5.4 6 8.3 9 3.7l2.1-3.1 111-221.4A5 5 0 0 0 318 95l-39 7.6a5 5 0 0 1-5.7-6.3L298.7 8c1-3.6-2-7-5.7-6.3Z"/>
                        <defs>
                            <%--
                            <linearGradient id="a" x1="6" x2="235" y1="33" y2="344" gradientUnits="userSpaceOnUse"><stop stop-color="#41D1FF"/><stop offset="1" stop-color="#BD34FE"/></linearGradient>
                            --%>
                            <linearGradient id="b" x1="194.7" x2="236.1" y1="8.8" y2="293" gradientUnits="userSpaceOnUse"><stop stop-color="#FFEA83"/><stop offset=".1" stop-color="#FFDD35"/><stop offset="1" stop-color="#FFA800"/></linearGradient>
                        </defs>
                    </svg>
                </oc-div>
            </m:print>
            <m:nl />
        </cms:bundle>

    </c:when>

</c:choose>