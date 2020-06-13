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

<c:choose>
    <c:when test="${not empty policyfile and cms.vfs.existsResource[policyfile]}">
        <cms:addparams>
            <cms:param name="policyformat" value="json" />
            <mercury:display
                file="${policyfile}"
                baseUri="${page}"
            />
        </cms:addparams>
    </c:when>
    <c:otherwise>
        <cms:jsonobject var="errorData">
            <cms:jsonobject key="error">
                <cms:jsonvalue key="policyfile" value="${policyfile}" />
                <cms:jsonvalue key="page" value="${page}" />
            </cms:jsonobject>
        </cms:jsonobject>
        <%----%>${errorData.compact}<%----%>
    </c:otherwise>
</c:choose>