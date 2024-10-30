<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="metaLinksOnTop"     value="${reqScopeSetting.metaLinks.useDefault('top').toString ne 'bottom'}" />
<c:set var="metaLinksIconsOut"  value="${reqScopeSetting.metaLinksIconsOut.toBoolean}" />
<c:set var="metaLinksTextOut"   value="${reqScopeSetting.metaLinksTextOut.toBoolean}" />


<jsp:useBean id="metaMap" class="java.util.HashMap" />
<c:forEach var="link" items="${reqScopeMetaLinksContent.valueList.LinkEntry}" varStatus="status">
    <m:link-icon link="${link}" resultMap="${metaMap}" />
    <c:set var="liWrapper" value="${empty metaMap.css ? '' : ' li-'.concat(metaMap.css)}" />
    <c:choose>
        <c:when test="${metaLinksIconsOut and not empty metaMap.icon and empty metaMap.message}">
            <c:set var="metaLinksIconOnly">
                ${metaLinksIconOnly}
                <li class="nav-meta-icon${liWrapper}"><%----%>
                    <m:link
                        link="${metaMap.link}"
                        title="${metaMap.title}"
                        css="${metaMap.css}"
                        attr="${metaMap.attr}"
                        forceText="${metaMap.icon}" />
                </li><%----%>
            </c:set>
        </c:when>
        <c:otherwise>
            <c:set var="metaLinksWithText">
                ${metaLinksWithText}
                <li class="nav-meta-link${liWrapper}"><%----%>
                    <m:link
                        link="${metaMap.link}"
                        title="${metaMap.title}"
                        css="${metaMap.css}"
                        attr="${metaMap.attr}"
                        forceText="${metaMap.icon}<span>${metaMap.message}</span>" />
                </li><%----%>
            </c:set>
        </c:otherwise>
    </c:choose>
</c:forEach>

<c:if test="${not metaLinksTextOut and not empty metaLinksWithText}">
    <c:set var="metaLinksWithText">
        <li id="nav-main-addition" class="expand"><%----%>
            <a href="#" aria-controls="nav_nav-main-addition" id="label_nav-main-addition">${reqScopeMetaLinksContent.value.Title}</a><%----%>
            <ul class="nav-menu" id="nav_nav-main-addition" aria-labelledby="label_nav-main-addition"><%----%>
                <m:nl />
                ${metaLinksWithText}
            </ul><%----%>
        </li><%----%>
    </c:set>
</c:if>

<c:if test="${not metaLinksOnTop}">
    <%-- If meta links are NOT on top, show icons first, i.e. do not show the text links here --%>
    ${metaLinksWithText}
    <m:nl />
</c:if>

<c:if test="${not empty metaLinksIconOnly}">
    <li class="nav-meta-icons"><ul><%----%>
    ${metaLinksIconOnly}
    </ul></li><%----%>
    <m:nl />
</c:if>

<c:if test="${metaLinksOnTop}">
    <%-- If meta links are on top, show the text links here, after the icons --%>
    ${metaLinksWithText}
    <m:nl />
</c:if>
<m:nl />

</cms:bundle>