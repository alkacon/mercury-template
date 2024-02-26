<%@ tag pageEncoding="UTF-8"
    display-name="list-supported-types"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Checks if the types used in a list are supported" %>


<%@ attribute name="config" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The list configuration." %>

<%@ attribute name="types" type="java.util.List" required="true"
    description="The list of supported types." %>


<%@ variable name-given="isTypesSupported" scope="AT_END" declare="true" variable-class="java.lang.Boolean"
    description="Flag, indicating if all types used in the list are supported." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${cms.isEditMode}">

<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="validTypes" value="${''}" />
<c:forEach var="typeName" items="${types}">
    <c:set var="typeKey">type.${typeName}.name</c:set>
    <c:set var="niceName">
        <mercury:workplace-message locale="${cms.workplaceLocale}" key="${typeKey}" />
    </c:set>
    <c:set var="validTypes" value="${not empty validTypes ? validTypes.concat(', &quot;') : '&quot;'}" />
    <c:set var="validTypes" value="${validTypes.concat(niceName).concat('&quot;')}" />
</c:forEach>

<c:set var="invalidTypes" value="${''}" />
<c:set var="listTypes"  value="${config.valueList.TypesToCollect}" />
<c:forEach var="type" items="${listTypes}">
    <c:set var="typeName" value="${fn:substringBefore(type, ':')}" />
    <c:if test="${not fn:contains(types, typeName)}">
        <c:set var="typeKey">type.${typeName}.name</c:set>
        <c:set var="niceName">
            <mercury:workplace-message locale="${cms.workplaceLocale}" key="${typeKey}" />
        </c:set>
        <c:set var="invalidTypes" value="${not empty invalidTypes ? invalidTypes.concat(', &quot;') : '&quot;'}" />
        <c:set var="invalidTypes" value="${invalidTypes.concat(niceName).concat('&quot;')}" />
    </c:if>
</c:forEach>

<c:set var="isTypesSupported" value="${true}" />
<c:if test="${not empty invalidTypes}">
    <c:set var="isTypesSupported" value="${false}" />
    <c:if test="">
    </c:if>
    <mercury:alert type="warning">
        <jsp:attribute name="head">
            <fmt:message key="msg.error.list.wrongType.head" />
        </jsp:attribute>
        <jsp:attribute name="text">
            <p>${config.value.Title}</p><%----%>
            <c:choose>
                <c:when test="${fn:contains(invalidTypes, ',')}">
                    <fmt:message key="msg.error.list.invalidTypes">
                        <fmt:param>${invalidTypes}</fmt:param>
                        <fmt:param>${validTypes}</fmt:param>
                    </fmt:message>
                </c:when>
                <c:otherwise>
                    <fmt:message key="msg.error.list.invalidType">
                        <fmt:param>${invalidTypes}</fmt:param>
                        <fmt:param>${validTypes}</fmt:param>
                    </fmt:message>
                </c:otherwise>
            </c:choose>
        </jsp:attribute>
    </mercury:alert>
</c:if>

</cms:bundle>

</c:if>
