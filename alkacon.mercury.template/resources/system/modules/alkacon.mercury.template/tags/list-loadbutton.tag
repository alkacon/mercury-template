<%@ tag pageEncoding="UTF-8"
    display-name="list-loadbutton"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a 'load more' button for dynamic list search results."%>


<%@ attribute name="search" type="org.opencms.jsp.search.result.I_CmsSearchResultWrapper" required="true"
    description="The result of a previous search using the cms:search tag." %>

<%@ attribute name="onclickAction" type="java.lang.String" required="true"
    description="The on click action string that reloads the list. It has to contain a $(LINK) macro that
    is replaced with the actual link calculated for the individual pages.
    This is to make the load button tag work like the pagination tag. "%>

<%@ attribute name="label" type="java.lang.String" required="false"
    description="The text shown on the load button." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:if test="${search.numFound > 0}">

    <%-- ####### Show load button if further entries exist ######## --%>

    <c:set var="pagination" value="${search.controller.pagination}" />
    <c:if test="${not empty pagination && search.numPages > 1}">
        <c:if test="${pagination.state.currentPage < search.numPages}">
            <c:set var="next">${pagination.state.currentPage < search.numPages ? pagination.state.currentPage + 1 : pagination.state.currentPage}</c:set>
            <div class="list-append-position" data-dynamic="true">
                <button
                    class="btn btn-append"
                    data-load="${search.stateParameters.setPage[next]}"
                    onclick='${fn:replace(onclickAction, "$(LINK)", search.stateParameters.setPage[next])}'>
                    <span>${label}</span>
                </button>
            </div>
        </c:if>
    </c:if>

</c:if>
