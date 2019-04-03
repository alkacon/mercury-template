<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.Map, java.util.HashMap, org.opencms.util.CmsRequestUtil" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%-- Convert settings to parameters --%>
<c:set var="settings" value="${cms.element.settings}" />
<%-- The ajax link to use with the parameters containing the settings. --%>
<c:set var="settingparams">&sid=${cms.element.instanceId}</c:set>

<mercury:init-messages reload="true">
<cms:formatter var="content" val="value" locale="en">

    <%-- ####### Build facet settings ######## --%>
    <c:set var="settings" value="${cms.element.settings}" />
    <c:set var="facetsettings">
        ${'none'}
        ${settings.showfacetcategory ? 'category' : ''}
        ${settings.showsorttitle ? 'sort_title' : ''}
        ${settings.showsortorder ? 'sort_order' : ''}
        ${settings.showsortdate ? 'sort_date' : ''}
    </c:set>
    <c:set var="elementId"><mercury:idgen prefix="le" uuid="${cms.element.id}" /></c:set>

    <%-- ##################################### --%>

    <mercury:nl />
    <div class="type-list-sortoptions ${settings.cssWrapper}" <%--
    --%>id="facets_${elementId}" <%--
    --%>data-facets="${facetsettings}" <%--
    --%>data-settings="${settingparams}"><%----%>
    <mercury:nl />

        <%-- The list options are filled by JavaScript --%>
        <c:if test="${cms.isEditMode}">
            <fmt:setLocale value="${cms.workplaceLocale}" />
            <cms:bundle basename="alkacon.mercury.template.messages">
                <div class="hide-noscript list-options"><%----%>
                    <button class="list-option dropdown-toggle btn placeholder">&nbsp;</button><%----%>
                    <mercury:alert type="warning" css="oct-reveal">
                        <jsp:attribute name="head">
                            <fmt:message key="msg.page.list.optionusage.title">
                                <fmt:param>${value.Title}</fmt:param>
                            </fmt:message>
                        </jsp:attribute>
                        <jsp:attribute name="text">
                            <fmt:message key="msg.page.list.optionusage.text" />
                        </jsp:attribute>
                    </mercury:alert>
                </div><%----%>
            </cms:bundle>
        </c:if>

    </div><%----%>
    <mercury:nl />

</cms:formatter>
</mercury:init-messages>
