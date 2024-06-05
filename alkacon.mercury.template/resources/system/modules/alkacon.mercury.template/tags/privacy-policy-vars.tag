<%@ tag pageEncoding="UTF-8"
    display-name="privacy-policy-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Reads the policy content and sets a series of variables for quick access." %>


<%@ attribute name="locatePolicyFile" type="java.lang.Boolean" required="false"
    description="If 'true', the policy resource file is located. The location is written to the variable 'policyFile'." %>

<%@ attribute name="setPolicyLinks" type="java.lang.Boolean" required="false"
    description="If 'true', then the links to the imprint page etc. are read from the policy file and stored in variables." %>

<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="false"
    description="The properties read from the content page URI resource with search. If not set  and 'locatePolicyFile' ist 'true', this will be read based on the value of 'cms.requestContext.uri'." %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="false"
    description="The privacy policy configuration content access bean. If not set and 'setPolicyLinks' is 'true', then 'cms.requestContext.uri' will be used to locate the policy content file first." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%@ variable name-given="policyFile"                declare="true" %>
<%@ variable name-given="policyBaseUri"             declare="true" %>
<%@ variable name-given="policyContent"             declare="true" %>

<%@ variable name-given="policyLinkImprint"         declare="true" %>
<%@ variable name-given="policyLinkPolicy"          declare="true" %>
<%@ variable name-given="policyLinkLegal"           declare="true" %>

<%@ variable name-given="policyTextImprint"         declare="true" %>
<%@ variable name-given="policyTextPolicy"          declare="true" %>
<%@ variable name-given="policyTextLegal"           declare="true" %>

<%@ variable name-given="hasPolicyLinks"            declare="true" %>

<%@ variable name-given="policyTest"                declare="true" %>


<c:set var="policyBaseUri" value="${cms.requestContext.uri}" />
<c:set var="policyContent" value="${content}" />

<c:if test="${locatePolicyFile or (setPolicyLinks and empty policyContent)}">

    <c:if test="${empty contentPropertiesSearch}">
        <%-- Do not use contentUri for properties, always read from the request context URI. This is identical to the m:content-properties.tag --%>
        <c:set var="contentPropertiesSearch" value="${cms.vfs.readPropertiesSearch[policyBaseUri]}" />
    </c:if>

    <c:set var="policyFile" value="${empty contentPropertiesSearch['mercury.privacy.policy'] ? null : contentPropertiesSearch['mercury.privacy.policy']}" />
    <c:set var="policyFile" value="${policyFile eq 'none' ? null : policyFile}" />

    <c:if test="${not empty policyFile}">
        <c:if test="${not fn:startsWith(policyFile, '/')}">
            <c:set var="subSitePolicy" value="${cms.subSitePath.concat('.content/').concat(policyFile)}" />
            <c:set var="sitePolicy" value="${'/.content/'.concat(policyFile)}" />
            <c:set var="policyFile" value="${cms.vfs.exists[subSitePolicy] ? subSitePolicy : sitePolicy}" />
        </c:if>
        <c:if test="${setPolicyLinks and empty policyContent}">
            <c:set var="policyContent" value="${cms.vfs.readXml[policyFile]}" />
        </c:if>
    </c:if>

</c:if>

<c:if test="${setPolicyLinks}">

    <fmt:setLocale value="${cms.locale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <c:set var="value" value="${policyContent.value}" />

    <c:set var="policyLinkImprint" value="${value.LinkImprint.value.URI.toLink}" />
    <c:if test="${empty policyLinkImprint}">
        <c:set var="policyLinkImprint" value="${cms.functionDetailPageExact['Imprint']}" />
        <c:if test="${not fn:startsWith(policyLinkImprint, '/') and not fn:startsWith(policyLinkImprint, 'http')}">
            <c:set var="policyLinkImprint" value="${null}" />
        </c:if>
    </c:if>
    <c:if test="${not empty policyLinkImprint}">
        <c:set var="hasPolicyLinks" value="${true}" />
        <c:set var="policyTextImprint" value="${value.LinkImprint.value.Text.toString}" />
        <c:if test="${empty policyTextImprint}">
            <fmt:message var="policyTextImprint" key="msg.page.privacypolicy.link.imprint" />
        </c:if>
    </c:if>

    <c:set var="policyLinkPolicy" value="${value.LinkPolicy.value.URI.toLink}" />
    <c:if test="${empty policyLinkPolicy}">
        <c:set var="policyLinkPolicy" value="${cms.functionDetailPageExact['Datenschutz']}" />
        <c:if test="${not fn:startsWith(policyLinkPolicy, '/') and not fn:startsWith(policyLinkPolicy, 'http')}">
            <c:set var="policyLinkPolicy" value="${null}" />
        </c:if>
    </c:if>
    <c:if test="${not empty policyLinkPolicy}">
        <c:set var="hasPolicyLinks" value="${true}" />
        <c:set var="policyTextPolicy" value="${value.LinkPolicy.value.Text.toString}" />
        <c:if test="${empty policyTextPolicy}">
            <fmt:message var="policyTextPolicy" key="msg.page.privacypolicy.link.policy" />
        </c:if>
    </c:if>

    <c:set var="policyLinkLegal" value="${value.LinkLegal.value.URI.toLink}" />
    <c:if test="${empty policyLinkLegal}">
        <c:set var="policyLinkLegal" value="${cms.functionDetailPageExact['Rechtliche Hinweise']}" />
        <c:if test="${not fn:startsWith(policyLinkLegal, '/') and not fn:startsWith(policyLinkLegal, 'http')}">
            <c:set var="policyLinkLegal" value="${null}" />
        </c:if>
    </c:if>
    <c:if test="${not empty policyLinkLegal}">
        <c:set var="hasPolicyLinks" value="${true}" />
        <c:set var="policyTextLegal" value="${value.LinkLegal.value.Text.toString}" />
        <c:if test="${empty policyTextLegal}">
            <fmt:message var="policyTextLegal" key="msg.page.privacypolicy.link.legal" />
        </c:if>
    </c:if>

    </cms:bundle>

</c:if>

<jsp:doBody />
