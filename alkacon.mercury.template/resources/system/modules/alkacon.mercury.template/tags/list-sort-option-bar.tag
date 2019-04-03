<%@ tag
    pageEncoding="UTF-8"
    display-name="list-sort-option-bar"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a series of facet and sort buttons for the list."%>


<%@ attribute name="elementId" type="java.lang.String" required="false"
    description="The id of the list content element (UID of the list resource)." %>

<%@ attribute name="settings" type="java.util.Map" required="false"
    description="A map that can hold a variety of settings that are used to configure the appearance of the list. Is usally read from the list elements content." %>

<%@ attribute name="searchresult" type="org.opencms.jsp.search.result.I_CmsSearchResultWrapper" required="true"
        description="The result of a previous usage of the cms:search tag." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="search" value="${searchresult}" />
<c:set var="showfacets">${settings.showfacetcategory}${settings.showsortdate}${settings.showsortorder}${settings.showsorttitle}</c:set>
<c:if test='${fn:contains(showfacets,"true")}'>
    <mercury:nl />
    <div class="list-options"><%----%>
    <mercury:nl />
        <div class="btn-group"><%----%>

            <%-- ####### Sort by title ######## --%>
            <c:if test="${settings.showsorttitle}">
                <c:set var="buttonLabel"><fmt:message key="msg.page.list.sort.title.label" /></c:set>
                <mercury:list-sort-button
                    elementId="${elementId}"
                    searchresult="${search}"
                    label="${buttonLabel}"
                    params="title_asc+title_desc"
                />
            </c:if>

            <%-- ####### Sort by date ######## --%>
            <c:if test="${settings.showsortdate}">
                <c:set var="buttonLabel"><fmt:message key="msg.page.list.sort.date.label" /></c:set>
                <mercury:list-sort-button
                    elementId="${elementId}"
                    searchresult="${search}"
                    label="${buttonLabel}"
                    params="date_asc+date_desc"
                />
            </c:if>

            <%-- ####### Sort by order ######## --%>
            <c:if test="${settings.showsortorder}">
                <c:set var="buttonLabel"><fmt:message key="msg.page.list.sort.order.label" /></c:set>
                <mercury:list-sort-button
                    elementId="${elementId}"
                    searchresult="${search}"
                    label="${buttonLabel}"
                    params="order_asc+order_desc"
                />
            </c:if>

            <%-- ####### Category filter ######## --%>
            <c:if test="${settings.showfacetcategory}">
                <c:set var="buttonLabel"><fmt:message key="msg.page.list.facet.category.label" /></c:set>
                <c:set var="noSelection"><fmt:message key="msg.page.list.facet.category.all" /></c:set>
                <mercury:list-sort-category
                    elementId="${elementId}"
                    field="category_exact"
                    label="${buttonLabel}"
                    deselect="${noSelection}"
                    searchresult="${search}"
                    settings="${settings}"
               />
            </c:if>

        </div><%----%>
    </div><%----%>
    <mercury:nl />
</c:if>