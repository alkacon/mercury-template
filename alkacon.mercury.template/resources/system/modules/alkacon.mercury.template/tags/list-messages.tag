<%@ tag pageEncoding="UTF-8"
    display-name="list-messages"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays the 'empty' list message and other messages used for the list." %>


<%@ attribute name="type" type="java.lang.String" required="true"
    description="The resoure type to create using the cms:edit tag." %>
<%@ attribute name="uploadFolder" type="java.lang.String" required="false"
    description="The upload folder to use for binary files." %>
<%@ attribute name="defaultCats" type="java.lang.String" required="false"
    description="The categories that should automatically be assigned to a newly created resource.
        This can be a comma-separated list of category paths (NOT starting with slash), site paths or root paths." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:choose>
<c:when test="${not cms.isOnlineProject}">

    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <cms:edit createType="${type}" create="true" postCreateHandler="org.opencms.file.collectors.CmsAddCategoriesPostCreateHandler|${defaultCats}" uploadFolder="${uploadFolder}">
        <mercury:alert type="warning">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.list.empty" />
            </jsp:attribute>
            <jsp:attribute name="text">
                <c:choose>
                    <c:when test="${fn:startsWith(type, 'm-')}">
                        <c:set var="typeKey">type.${type}.name</c:set>
                    </c:when>
                    <c:otherwise>
                        <c:set var="typeKey">fileicon.${type}</c:set>
                    </c:otherwise>
                </c:choose>
                <fmt:message key="msg.page.list.newentry">
                    <fmt:param>
                        <mercury:label locale="${cms.workplaceLocale}" key="${typeKey}" />
                    </fmt:param>
                    <fmt:param>${type}</fmt:param>
                </fmt:message>
            </jsp:attribute>
        </mercury:alert>
    </cms:edit>
    </cms:bundle>

</c:when>
<c:otherwise>

    <fmt:setLocale value="${cms.locale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <div class="animated fadeIn">
        <div class="message">
            <fmt:message key="msg.page.list.empty" />
        </div>
    </div>
    </cms:bundle>

</c:otherwise>
</c:choose>