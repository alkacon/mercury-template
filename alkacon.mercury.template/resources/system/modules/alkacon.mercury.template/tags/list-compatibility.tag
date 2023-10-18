<%@ tag pageEncoding="UTF-8"
    display-name="list-compatibility"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Checks if the list and the shown types are compatible" %>


<%@ attribute name="settings" type="java.util.Map" required="true"
    description="The element settings for the list, containing also the merged settings from the display formatters." %>

<%@ attribute name="types" type="java.util.List" required="true"
    description="The types to show (as their display formatters as list of CmsJspContentAccessValueWrapper)" %>

<%@ attribute name="isStaticList" type="java.lang.Boolean" required="false"
    description="Flag, indicating if list compatibility should be checked for the static list or for the dynamic list." %>

<%@ attribute name="listTitle" type="java.lang.String" required="true"
    description="The list title shown in the displayed incompatibility message." %>

<%@ attribute name="customType" type="java.lang.String" required="false"
    description="Required in case a custom list type is to be loaded, different from the default 'static' or 'dynamic' lists.
    Note that for custom list types, it is required to always include a colon ':' in the list type in the diyplay formatter configuration.
    Example: 'listtype:teasertype'.
    If this is set the 'isStaticList' is ignored." %>


<%@ variable name-given="isCompatible" scope="AT_END" declare="true" variable-class="java.lang.Boolean"
    description="Flag, indicating if all compatibility conditions for the list are met." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="incompatibleWithList" value="${false}" />
<c:set var="incompatibleGroups" value="${false}" />

<c:set var="requiredListType" value="${empty customType ? (isStaticList ? 'static' : 'dynamic') : customType}" />

<c:forEach var="type" items="${types}">

    <c:if test="${not incompatibleGroups and not incompatibleWithList}">
        <%-- Continue the loop only as long as no incompatibility is found --%>

        <c:set var="compatibilityKey" value="${type.contentValue.formatterId}_displayType" />
        <c:set var="configuredGroup" value="${settings[compatibilityKey]}" />

        <c:if test="${(not empty customType) or fn:contains(configuredGroup,':')}">
            <c:set var="configuredList" value="${fn:substringBefore(configuredGroup, ':')}" />
            <c:set var="configuredGroup" value="${fn:substringAfter(configuredGroup, ':')}" />
            <c:if test="${requiredListType ne configuredList}">
                <c:set var="incompatibleWithList" value="${true}" />
            </c:if>
        </c:if>

        <c:if test="${not empty configuredGroup}">
            <c:choose>
                <c:when test="${empty requiredGroup}">
                    <c:set var="requiredGroup" value="${configuredGroup}" />
                </c:when>
                <c:when test="${not (configuredGroup eq requiredGroup)}">
                    <c:set var="incompatibleGroups" value="${true}" />
                </c:when>
            </c:choose>
        </c:if>
    </c:if>

</c:forEach>

<c:set var="isCompatible" value="${not incompatibleGroups and not incompatibleWithList}" />

<c:if test="${not isCompatible && cms.isEditMode}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
    <c:choose>
        <c:when test="${incompatibleWithList}">
            <mercury:alert type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.error.list.wrongType.head" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.error.list.wrongType.text">
                        <fmt:param>${listTitle}</fmt:param>
                    </fmt:message>
                </jsp:attribute>
            </mercury:alert>
       </c:when>
       <c:when test="${incompatibleGroups}">
            <mercury:alert type="warning">
                <jsp:attribute name="head">
                    <fmt:message key="msg.error.list.wrongType.head" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.error.list.wrongDisplay.text">
                        <fmt:param>${listTitle}</fmt:param>
                    </fmt:message>
                </jsp:attribute>
            </mercury:alert>
       </c:when>
    </c:choose>
    </cms:bundle>
</c:if>
