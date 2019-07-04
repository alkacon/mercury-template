<%@page
    buffer="none"
    session="false"
    pageEncoding="UTF-8"
    trimDirectiveWhitespaces="true" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />

<!DOCTYPE html>
<html>
<body>
<c:set var="policyfile"><mercury:obfuscate text="${param.policy}" type="base64dec" /></c:set>
<c:set var="page"><mercury:obfuscate text="${param.page}" type="base64dec" /></c:set>

<c:choose>
    <c:when test="${not empty policyfile and cms.vfs.existsResource[policyfile]}">
        <mercury:display
            file="${policyfile}"
            baseUri="${page}"
        />
    </c:when>
    <c:otherwise>
        <!-- policy: [${policyfile}] -->
    </c:otherwise>
</c:choose>

</body>
</html>

