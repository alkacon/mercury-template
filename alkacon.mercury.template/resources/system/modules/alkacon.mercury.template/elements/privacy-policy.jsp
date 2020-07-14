<%@page pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />

<c:set var="policyfile"><mercury:obfuscate text="${param.policy}" type="base64dec" /></c:set>
<c:set var="page"><mercury:obfuscate text="${param.page}" type="base64dec" /></c:set>
<c:set var="siteRoot"><mercury:obfuscate text="${param.root}" type="base64dec" /></c:set>
<c:set var="isMercury" value="${empty param.template or (param.template eq 'mercury')}" />

<c:if test="${not empty policyfile and not empty siteRoot}">
    <mercury:set-siteroot siteRoot="${siteRoot}" />
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
        <cms:addparams>
            <cms:param name="template" value="mercury" />
            <cms:param name="path" value="${page}" />
            <mercury:display
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