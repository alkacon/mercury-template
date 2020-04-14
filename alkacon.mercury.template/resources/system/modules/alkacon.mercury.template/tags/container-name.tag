<%@ tag pageEncoding="UTF-8"
    display-name="container-box"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Changes technical container names to user friendly names." %>


<%@ attribute name="type" type="java.lang.String" required="false"
        description="The type of elements the container takes." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>


<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">
    <c:set var="type" value="${fn:toLowerCase(type)}" />
    <c:if test="${fn:contains(type, 'template')}">
        <c:set var="niceName"><fmt:message key="msg.page.layout.type.template"/></c:set>
        <c:set var="type" value="${fn:replace(type, 'template', niceName)}" />
    </c:if>
    <c:if test="${fn:contains(type, 'area')}">
        <c:set var="niceName"><fmt:message key="msg.page.layout.type.area"/></c:set>
        <c:set var="type" value="${fn:replace(type, 'area', niceName)}" />
    </c:if>
    <c:if test="${fn:contains(type, 'row')}">
        <c:set var="niceName"><fmt:message key="msg.page.layout.type.row"/></c:set>
        <c:set var="type" value="${fn:replace(type, 'row', niceName)}" />
    </c:if>
    <c:if test="${fn:contains(type, 'element')}">
        <c:set var="niceName"><fmt:message key="msg.page.layout.type.element"/></c:set>
        <c:set var="type" value="${fn:replace(type, 'element', niceName)}" />
    </c:if>
    <c:out value="${type}" escapeXml="${false}" />
</cms:bundle>
