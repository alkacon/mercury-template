<%@ tag pageEncoding="UTF-8"
    display-name="init-messages"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays the standard 'new element' or 'reload required' message boxes." %>


<%@ attribute name="reload" type="java.lang.Boolean" required="false"
    description="Indicates if the page must be reloaded after the element was changed in the form editor." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated alert box" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%@ variable name-given="nl" declare="true"
    description="A variable holding a newline / line break to use in JSP for output formatting." %>


<c:if test="${cms.element.inMemoryOnly or (reload and cms.edited)}">
    <c:set var="type" value="${cms.element.resourceTypeName}" />
    <c:choose>
        <c:when test="${fn:startsWith(type, 'm-')}">
            <c:set var="typeKey">type.${type}.name</c:set>
            <c:set var="descKey">type.${type}.description</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="typeKey">fileicon.${type}</c:set>
            <c:set var="descKey">desc.${type}</c:set>
        </c:otherwise>
    </c:choose>
</c:if>

<c:choose>
    <c:when test="${cms.element.inMemoryOnly and not cms.element.historyContent}">
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <m:alert type="warning" css="new-element ${css}">
                <jsp:attribute name="head">
                    <fmt:message key="msg.page.newElement">
                        <fmt:param>
                            <m:workplace-message locale="${cms.workplaceLocale}" key="${typeKey}" />
                        </fmt:param>
                    </fmt:message>
                </jsp:attribute>
                <jsp:attribute name="text">
                    <m:workplace-message locale="${cms.workplaceLocale}" key="${descKey}" /><br>
                    <div class="small"><fmt:message key="msg.page.newElement.hint" /></div><%----%>
                </jsp:attribute>
            </m:alert>
        </cms:bundle>
    </c:when>
    <c:when test="${reload and cms.edited}">
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
        <cms:formatter var="content" val="value">
            <m:alert type="error" css="oct-reload ${css}">
                <jsp:attribute name="head">
                    ${cms.reloadMarker}
                    <fmt:message key="msg.page.mustReload" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <div><%----%>
                    <fmt:message key="msg.page.mustReload.hint1">
                        <fmt:param>
                            <m:workplace-message locale="${cms.workplaceLocale}" key="${typeKey}" />
                        </fmt:param>
                    </fmt:message>
                    </div><%----%>
                    <div class="small"><fmt:message key="msg.page.mustReload.hint2" /></div><%----%>
                </jsp:attribute>
            </m:alert>
        </cms:formatter>
        </cms:bundle>
    </c:when>
    <c:otherwise>
        <%-- ####### JSP body inserted here ######## --%>
        <jsp:doBody/>
        <%-- ####### /JSP body inserted here ######## --%>
    </c:otherwise>
</c:choose>

<c:set var="nl" value="<%= \"\n\" %>" />
