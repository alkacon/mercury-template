<%@ tag pageEncoding="UTF-8"
    display-name="instancedate"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Formats an instance date."%>

<%@ attribute name="date" type="org.opencms.jsp.util.CmsJspInstanceDateBean" required="true"
    description="The date to format." %>

<%@ attribute name="format" type="java.lang.String" required="true"
    description="The format for the date, or 'none' which means no date will be shown." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:if test="${(not empty date) and (date.start.time > 0) and (format != 'none')}">
    <fmt:setLocale value="${cms.locale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <c:if test="${fn:startsWith(format, 'fmt-')}">
            <c:set var="formatKey">msg.setting.dateFormat.${fn:substringAfter(format, 'fmt-')}.format</c:set>
            <c:set var="format"><fmt:message key="${formatKey}"/></c:set>
        </c:if>
        <c:if test="${(empty format) or fn:startsWith(format, '??')}">
            <c:set var="formatKey">msg.setting.dateFormat.DEFAULT.format</c:set>
            <c:set var="format"><fmt:message key="${formatKey}"/></c:set>
            <c:if test="${fn:startsWith(format, '??')}">
                <c:set var="format">d. MMM yyyy|H:mm</c:set>
            </c:if>
        </c:if>
    </cms:bundle>
    <c:out value="${date.format[format]}" escapeXml="false" />
</c:if>
