<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams replaceInvalid="bad_param" />
<m:init-messages>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="slotText"       value="${setting.slotText.toString}" />
<c:set var="slotButton"     value="${setting.slotButton.toString}" />

<c:if test="${empty slotText}">
    <c:set var="slotText"><fmt:message key='msg.page.search.enterquery' /></c:set>
</c:if>

<c:choose>
    <c:when test="${empty slotButton}">
        <c:set var="slotButton"><fmt:message key="msg.page.search.submit" /></c:set>
    </c:when>
    <c:when test="${fn:startsWith(slotButton, 'icon:')}">
        <c:set var="icon" value="${fn:substringAfter(slotButton, 'icon:')}" />
        <c:set var="slotButton"><m:icon icon="${icon}" tag="span" cssWrapper="icon-image" inline="${true}" /></c:set>
    </c:when>
</c:choose>

<div class="element type-search-slot pivot${setCssWrapperAll}"><%----%>
    <m:nl/>

    <c:set var="searchPageUri" value="${cms.functionDetailPageExact['Search page']}" />
    <c:if test="${not fn:startsWith(searchPageUri, '/')}">
        <c:set var="searchPageUri" value="${null}" />
    </c:if>

    <c:choose>
    <c:when test="${empty searchPageUri and cms.isEditMode}">
        <m:alert type="warning">
            <jsp:attribute name="head">
                <fmt:message key="msg.page.search.nofunction" />
            </jsp:attribute>
        </m:alert>
    </c:when>
    <c:when test="${empty searchPageUri and not cms.isEditMode}">
        <!-- <fmt:message key="msg.page.search.nofunction" /> --><%----%>
    </c:when>
    <c:otherwise>

        <%-- The search slot form --%>
        <%-- search action: link to the search page that should contain the search function. --%>
        <%-- NOTE: We assume the reload and the query parameter (reloaded/q) are not changed via configuration for the search function. --%>
        <form<%--
            --%> id="search-slot-form"<%--
            --%> class="styled-form no-border"<%--
            --%> action="${searchPageUri}"<%--
            --%>><%----%>

            <%--We add this parameter to ensure that it is really searched and search is not starting in initial mode --%>
            <input type="hidden" name="reloaded" /><%----%>

                <%-- Search query --%>
                <div class="search-query"><%----%>
                    <section class="input-group"><%----%>
                        <div class="input button"><%----%>
                            <label for="searchFormQuery" class="sr-only"><fmt:message key="msg.page.search" /></label><%----%>
                            <input id="searchFormQuery" name="q" <%--
                                --%>value="" class="form-control" type="text" autocomplete="off" <%--
                                --%>placeholder="<c:out value="${slotText}" />" /><%----%>
                            <button class="btn btn-submit-search" type="submit"  title="<fmt:message key="msg.page.search" />">${slotButton}</button><%----%>
                        </div><%----%>
                    </section><%----%>
                </div><%----%>

        </form><%----%>
        <m:nl />

    </c:otherwise>
    </c:choose>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</m:init-messages>
