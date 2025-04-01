<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams replaceInvalid="bad_param" />

<c:set var="policyfile"><m:obfuscate text="${param.policy}" type="base64dec" /></c:set>
<%-- Note: Using c:out to XML escape the parameters again, since the transmission was base64 encoded so cms:secureparams has no effect --%>
<c:set var="policyfile"><c:out value="${policyfile}"/></c:set>
<c:set var="page"><m:obfuscate text="${param.page}" type="base64dec" /></c:set>
<c:set var="page"><c:out value="${page}"/></c:set>
<c:set var="siteRoot"><m:obfuscate text="${param.root}" type="base64dec" /></c:set>
<c:set var="siteRoot"><c:out value="${siteRoot}"/></c:set>
<c:set var="isMercury" value="${empty param.template or (param.template eq 'mercury')}" />

<c:if test="${not empty policyfile and not empty siteRoot}">
    <m:set-siteroot siteRoot="${siteRoot}" />
    <c:set var="policyRes" value="${cms.vfs.readResource[policyfile]}" />
    <c:if test="${(not empty policyRes) and isMercury and (policyRes.typeName ne 'm-privacypolicy')}">
        <%-- policy file is not of the required type, try to find matching type --%>
        <c:set var="originalPolicyfile" value="${policyfile}" />
        <c:set var="policyfile">${policyRes.sitePathFolder}mercury-${policyRes.name}</c:set>
        <c:set var="policyRes" value="${cms.vfs.readResource[policyfile]}" />
    </c:if>
</c:if>

<c:choose>
    <c:when test="${not empty policyRes}">
        <c:if test="${fn:startsWith(page, '/shared/')}">
            <%-- use the root path of the policy file to locate the formatter in case the target is in the shared folder --%>
            <c:set var="page" value="${policyRes.rootPath}" />
        </c:if>
        <cms:addparams>
            <cms:param name="template" value="mercury" />
            <cms:param name="path" value="${page}" />
            <m:display
                file="${policyfile}"
                baseUri="${page}"
            />
        </cms:addparams>
    </c:when>
    <c:otherwise>
        <cms:jsonobject var="errorData">
            <cms:jsonobject key="error">
                <cms:jsonvalue key="root" value="${siteRoot}" />
                <cms:jsonvalue key="page" value="${page}" />
                <cms:jsonvalue key="policyfile" value="${policyfile}" />
                <c:if test="${not empty originalPolicyfile}">
                    <cms:jsonvalue key="originalPolicyfile" value="${originalPolicyfile}" />
                </c:if>
            </cms:jsonobject>
        </cms:jsonobject>
        <%----%>${errorData.compact}<%----%>
    </c:otherwise>
</c:choose>