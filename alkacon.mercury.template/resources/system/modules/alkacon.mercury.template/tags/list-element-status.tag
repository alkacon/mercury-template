<%@ tag pageEncoding="UTF-8"
    display-name="list-element-status"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Provides status information for a list element." %>

<%@ variable name-given="caseNotInList" declare="true" %>
<%@ variable name-given="caseStaticList" declare="true" %>
<%@ variable name-given="caseStandardElement" declare="true" %>
<%@ variable name-given="caseDynamicListAjax" declare="true" %>
<%@ variable name-given="caseDynamicListNoscript" declare="true" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%--

Possible use cases:

1a. "Standard element" case
    In this case the element is rendered as a 'standard' element, i.e. it has been placed directly on a page.
1b. "Static list" case
    In this case the element is rendered from a 'static list'.
    Technically this is the same case as (1a), hence we can refer to both these cases as (1).
2.  "Dynamic list - Ajax" case
    In this case the element is rendered from a 'dynamic list' element in an Ajax call.
3.  "Dynamic list - NoScript" case
    In this case the element is also rendered from a 'dynamic' list', but inside a noscript element.
    This is done for a dynmaic list so that for SEO and Non-JavaScript users, the list element are still displayed.

--%>

<c:set var="caseNotInList" value="${empty param.listid}" />
<c:set var="caseStaticList" value="${not caseNotInList and ('false' eq param.noscriptList)}" />
<c:set var="caseStandardElement" value="${caseNotInList or caseStaticList}" />
<c:set var="caseDynamicListAjax" value="${not ('true' eq param.noscriptList) and ('true' eq param.ajaxList)}" />
<c:set var="caseDynamicListNoscript" value="${'true' eq param.noscriptList}" />

<%--
<!--
caseNotInList: ${caseNotInList}
caseStaticList: ${caseStaticList}
caseStandardElement: ${caseStandardElement}
caseDynamicListAjax: ${caseDynamicListAjax}
caseDynamicListNoscript: ${caseDynamicListNoscript}
-->
--%>

<%-- ####### JSP body inserted here ######## --%>
<jsp:doBody/>
<%-- ####### /JSP body inserted here ######## --%>