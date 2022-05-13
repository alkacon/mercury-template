<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:setting-defaults>

<c:set var="link">${cms.functionDetail['Search']}</c:set>
<c:choose>
<c:when test="${empty link && cms.isEditMode}">
   <%-- TODO: Print hint --%>
</c:when>
<c:otherwise>
<div class="element type-search-slot ${setCssWrapperAll}"><%----%>
   <mercury:nl/>

   <%-- The search slot form --%>
   <%-- search action: link to the search page that should contain the search function. --%>
   <%-- NOTE: We assume the reload and the query parameter (reloaded/q) are not changed via configuration for the search function. --%>
   <form<%--
       --%> id="search-slot-form"<%--
       --%> role="form"<%--
       --%> class="styled-form no-border"<%--
       --%> action="${link}"<%--
       --%>><%----%>

       <%--We add this parameter to ensure that it is really searched and search is not starting in initial mode --%>
       <input type="hidden" name="reloaded" /><%----%>

           <%-- Search query --%>
           <div class="search-query"><%----%>
               <section class="input-group"><%----%>
                   <div class="input button"><%----%>
                       <label for="searchFormQuery" class="sr-only"><fmt:message key="msg.page.search" /></label><%----%>
                       <input id="searchFormQuery" name="q" <%--
                           --%>value="" class="form-control blur-focus" type="text" autocomplete="off" <%--
                           --%>placeholder="<fmt:message key='msg.page.search.enterquery' />" /><%----%>
                       <button class="btn btn-submit-search" type="submit"><fmt:message key="msg.page.search.submit" /></button><%----%>
                   </div><%----%>
               </section><%----%>
           </div><%----%>

   </form><%----%>
   <mercury:nl />

</div><%----%>
</c:otherwise>
</c:choose>

</mercury:setting-defaults>

</cms:bundle>
</mercury:init-messages>
