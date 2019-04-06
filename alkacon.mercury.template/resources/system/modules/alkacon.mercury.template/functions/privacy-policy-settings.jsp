<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    import="org.opencms.file.*, org.opencms.main.*, org.opencms.util.*"
    trimDirectiveWhitespaces="true" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury"%>

<c:set var="policyfile" value="${cms.vfs.readPropertiesSearch[cms.requestContext.uri]['mercury.privacy.policy']}" />

<c:if test="${not empty policyfile}">
<c:set var="policySettings" value="${cms:jsonToMap(leer)}" />
<c:set target="${policySettings}" property="cssWrapper" value="${cms.element.settings.cssWrapper}" />
<mercury:display
    file="${policyfile}"
    formatter="%(link.weak:/system/modules/alkacon.mercury.template/formatters/privacy-policy/settings.xml:c540a604-b12d-451f-8e71-a738cc47487d)"
    settings="${policySettings}"
/>
</c:if>