<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    import="org.opencms.file.*, org.opencms.main.*, org.opencms.util.*"
    trimDirectiveWhitespaces="true" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury"%>

<mercury:content-properties>
    <c:set var="policyfile" value="${empty contentPropertiesSearch['mercury.privacy.policy'] ? 'none' : contentPropertiesSearch['mercury.privacy.policy']}" />

    <c:choose>
        <c:when test="${not empty policyfile and policyfile ne 'none'}">
            <c:set var="policyfile" value="${fn:startsWith(policyfile, '/') ? policyfile : cms.subSitePath.concat('.content/').concat(policyfile)}" />
        </c:when>
        <c:otherwise>
             <c:set var="policyfile" value="${null}" />
        </c:otherwise>
    </c:choose>

    <c:choose>
        <c:when test="${not empty policyfile and cms.vfs.exists[policyfile]}">
            <c:set var="policySettings" value="${cms:jsonToMap(leer)}" />
            <c:set target="${policySettings}" property="cssWrapper" value="${cms.element.settings.cssWrapper}" />
            <mercury:display
                file="${policyfile}"
                formatter="%(link.weak:/system/modules/alkacon.mercury.template/formatters/privacy-policy/settings.xml:c540a604-b12d-451f-8e71-a738cc47487d)"
                settings="${policySettings}"
            />
        </c:when>
        <c:otherwise>
            <fmt:setLocale value="${cms.locale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                <mercury:alert type="warning">
                    <jsp:attribute name="head">
                        <fmt:message key="msg.page.policyfile.missing" />
                    </jsp:attribute>
                </mercury:alert>
            </cms:bundle>
        </c:otherwise>
    </c:choose>
</mercury:content-properties>
