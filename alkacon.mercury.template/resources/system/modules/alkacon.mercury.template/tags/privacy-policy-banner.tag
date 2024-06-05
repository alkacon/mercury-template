<%@ tag pageEncoding="UTF-8"
    display-name="privacy-policy-banner"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays the 'privacy policy' cookie banner." %>

<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="true"
    description="The properties read from the URI resource with search." %>

<%@ attribute name="contentUri" type="java.lang.String" required="true"
    description="The content URI to generate the cookie banner for." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${not cms.isEditMode}">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:privacy-policy-vars locatePolicyFile="${true}" contentPropertiesSearch="${contentPropertiesSearch}">

<c:if test="${not empty policyFile}">

    <c:set var="hideBanner" value="${contentPropertiesSearch['mercury.privacy.policy.nobanner'] eq 'true'}" />
    <c:set var="fallbackPage" value="${cms.readAttributeOrProperty[cms.requestContext.uri]['mercury.privacy.policy.fallback']}" />

    <c:set var="policyFileBase64"><m:obfuscate text="${policyFile}" type="base64"/></c:set>
    <c:set var="uriBase64"><m:obfuscate text="${contentUri}" type="base64"/></c:set>
    <c:set var="rootBase64"><m:obfuscate text="${cms.requestContext.siteRoot}" type="base64"/></c:set>

    <%-- Generate banner data JSON --%>
    <cms:jsonobject var="bannerData">
        <cms:jsonvalue key="policy" value="${policyFileBase64}" />
        <cms:jsonvalue key="page" value="${uriBase64}" />
        <cms:jsonvalue key="root" value="${rootBase64}" />
        <c:if test="${hideBanner}">
            <cms:jsonvalue key="display" value="0" />
        </c:if>
        <c:if test="${not empty fallbackPage}">
            <c:set var="fallbackBase64"><m:obfuscate text="${fallbackPage}" type="base64"/></c:set>
            <cms:jsonvalue key="fallback" value="${fallbackBase64}" />
        </c:if>
    </cms:jsonobject>

    <div id="privacy-policy-placeholder"></div><%----%>
    <div id="privacy-policy-banner" class="pp-banner" data-banner='${bannerData.compact}'></div><%----%>
    <m:nl />

    <noscript><%----%>
        <div id="privacy-policy-banner-noscript" class="pp-banner"><%----%>
            <div class=banner><%----%>
                <div class="container"><%----%>
                    <div class="message"><fmt:message key="msg.page.javaScript.disabled" /></div><%----%>
                </div><%----%>
            </div><%----%>
        </div><%----%>
    </noscript><%----%>
    <m:nl />

</c:if>

</m:privacy-policy-vars>

</cms:bundle>

</c:if>