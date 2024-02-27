<%@ tag pageEncoding="UTF-8"
    display-name="list-compatibility"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Checks if the list and the shown types are compatible" %>


<%@ attribute name="settings" type="java.util.Map" required="true"
    description="The element settings for the list, containing also the merged settings from the display formatters." %>

<%@ attribute name="types" type="java.util.List" required="true"
    description="The types to show (as their display formatters as list of CmsJspContentAccessValueWrapper)" %>

<%@ attribute name="listType" type="java.lang.String" required="true"
    description="The list type formatter type to be used, e.g. 'static' or 'dynamic'.
    It will be checked if the provided 'types' are compatible with the selected formatter.
    Note that for all list types except 'static' and 'dynamic', it is required to include the list type separated by a colon ':' in the formatter configuration field 'DisplayType'.
    Example: 'listtype:teasertype'." %>

<%@ attribute name="resourceTypes" type="java.util.List" required="false"
    description="The allowed resource types for the list. Can be used in JSP formatters to restrict the types in the list to the selected resource types." %>

<%@ attribute name="displayTypes" type="java.util.List" required="false"
    description="The allowed display types for the list. Can be used in JSP formatters to restrict the types in the list to the selected display types." %>

<%@ attribute name="listTitle" type="java.lang.String" required="true"
    description="The list title shown in the displayed incompatibility message." %>


<%@ variable name-given="isCompatible" scope="AT_END" declare="true" variable-class="java.lang.Boolean"
    description="Flag, indicating if all compatibility conditions for the list are met." %>

<%@ variable name-given="listDisplayType" scope="AT_END" declare="true" variable-class="java.lang.String"
    description="The configured list group display type, which the stored in the 'display' node of the formatter configuration." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="compatibleWithList" value="${true}" />
<c:set var="compatibleTypes" value="${true}" />

<c:set var="isDefaultList" value="${(listType eq 'dynamic') or (listType eq 'static')}" />

<c:forEach var="type" items="${types}">

    <c:if test="${not empty resourceTypes and not resourceTypes.contains(type.contentValue.displayType)}">
        <c:set var="compatibleWithList" value="${false}" />
    </c:if>

    <c:if test="${compatibleTypes and compatibleWithList}">
        <c:set var="displayTypeKey" value="${type.contentValue.formatterId}_displayType" />
        <c:set var="displayType" value="${settings[displayTypeKey]}" />

        <c:if test="${not empty displayTypes and not displayTypes.contains(displayType)}">
            <c:set var="compatibleWithList" value="${false}" />
        </c:if>

        <c:if test="${compatibleWithList and (not isDefaultList or fn:contains(displayType,':'))}">
            <c:set var="requiredList" value="${fn:substringBefore(displayType, ':')}" />
            <c:set var="displayType" value="${fn:substringAfter(displayType, ':')}" />
            <c:if test="${requiredList ne listType}">
                <c:set var="compatibleWithList" value="${false}" />
            </c:if>
        </c:if>

        <c:if test="${compatibleWithList and not empty displayType}">
            <c:choose>
                <c:when test="${empty requiredType}">
                    <c:set var="requiredType" value="${displayType}" />
                </c:when>
                <c:when test="${not (displayType eq requiredType)}">
                    <c:set var="compatibleTypes" value="${false}" />
                </c:when>
            </c:choose>
        </c:if>
    </c:if>

</c:forEach>

<c:set var="isCompatible" value="${compatibleTypes and compatibleWithList and not empty requiredType}" />
<c:set var="listDisplayType" value="${isCompatible ? requiredType : null}" />

<c:if test="${not isCompatible && cms.isEditMode}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <c:choose>
            <c:when test="${not compatibleWithList}">
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
        <c:otherwise>
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
        </c:otherwise>
        </c:choose>
    </cms:bundle>
</c:if>
