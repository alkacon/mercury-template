<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>
<%@page import="org.opencms.main.OpenCms"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

    <c:set var="setting"                value="${cms.element.setting}" />
    <c:set var="showFile"               value="${setting.showFile.toBoolean}" />
    <c:set var="showDescription"        value="${setting.showDescription.toBoolean}" />
    <c:set var="showCategories"         value="${(setting.categoryOption.toString eq 'allnopath') or (setting.categoryOption.toString eq 'onlyleafs')}" />
    <c:set var="showCategoryLeafsOnly"  value="${showCategories and (setting.categoryOption.toString eq 'onlyleafs')}" />
    <c:set var="displayFormat"          value="${setting.listCssWrapper.toString}" />
    <c:set var="hsize"                  value="${setting.hsize.toInteger}" />

    <c:set var="res"                    value="${cms.wrap[cms.element.resource]}" />
    <c:set var="rootPath"               value="${res.rootPath}" />
    <c:set var="link"                   value="${res.link}" />
    <c:set var="mimeType"               value="${res.mimeType}" />
    <c:set var="propertiesLocale"       value="${res.propertyLocale[cms.locale]}" />
    <c:set var="suffix"                 value="${fn:toUpperCase(res.extension)}" />
    <c:set var="title"                  value="${empty propertiesLocale['Title'] ? res.name : propertiesLocale['Title']}" />
    <c:set var="description"            value="${propertiesLocale['Description']}"/>

    <c:set var="date"><fmt:formatDate value="${cms:convertDate(res.dateLastModified)}" type="date" dateStyle="SHORT" /></c:set>

    <c:choose>
        <c:when test="${suffix eq 'TXT'}">
            <c:set var="icon">fa-file-text-o</c:set>
        </c:when>
        <c:when test="${fn:startsWith(mimeType, 'image')}">
            <c:set var="icon">fa-file-image-o</c:set>
        </c:when>
        <c:when test="${fn:startsWith(mimeType, 'video')}">
            <c:set var="icon">fa-file-video-o</c:set>
        </c:when>
        <c:when test="${fn:startsWith(mimeType, 'audio')}">
            <c:set var="icon">fa-file-audio-o</c:set>
        </c:when>
        <c:when test="${suffix eq 'PDF'}">
            <c:set var="icon">fa-file-pdf-o</c:set>
        </c:when>
        <c:when test="${suffix eq 'HTML' or suffix eq 'HTM'}">
            <c:set var="icon">fa-html5</c:set>
        </c:when>
        <c:when test="${suffix eq 'DOC' or suffix eq 'DOCX'}">
            <c:set var="icon">fa-file-word-o</c:set>
        </c:when>
        <c:when test="${suffix eq 'XLS' or suffix eq 'XLSX'}">
            <c:set var="icon">fa-file-excel-o</c:set>
        </c:when>
        <c:when test="${suffix eq 'PPT' or suffix eq 'PPTX'}">
            <c:set var="icon">fa-file-powerpoint-o</c:set>
        </c:when>
        <c:when test="${suffix eq 'ZIP' or suffix eq 'RAR'}">
            <c:set var="icon">fa-file-archive-o</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="icon">fa-file-o</c:set>
        </c:otherwise>
    </c:choose>

    <c:set var="size">${res.length}</c:set>
    <c:set var="digits" value="${fn:length(size)}" />
    <c:choose>
        <c:when test="${digits > 6}">
            <c:set var="size" value="${res.length div (1024 * 1024)}" />
            <c:set var="unit">MB</c:set>
        </c:when>
        <c:when test="${digits > 3}">
            <c:set var="size" value="${res.length div 1024}" />
            <c:set var="unit">KB</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="unit">Byte</c:set>
        </c:otherwise>
    </c:choose>
    <c:set var="size">${cms:mathRound(size)}${' '}${unit}</c:set>

    <c:choose>
        <c:when test="${fn:contains(displayFormat, 'dl-list-compact')}">

            <%-- ###### Compact / Minimal display format ###### --%>
            <div class="dl-teaser dl-teaser-compact${showFile ? ' dl-show-file' : ''}${showDescription ? ' dl-show-desc' : ''}">
                <a href="${link}" class="dl-link dl-link-disp" target="_blank" rel="noopener" rel="noopener" title="<fmt:message key="msg.page.display"/>"><%----%>
                    <span class="dl-type fa ${icon}"></span><%----%>
                    <span class="dl-content"><%----%>
                        <mercury:heading level="${hsize}" text="${title}" css="dl-title" ade="${false}" />
                        <c:if test="${showFile and not empty propertiesLocale['Title']}">
                            <div class="dl-file">${res.name}</div><%----%>
                        </c:if>
                        <c:if test="${showCategories and not res.categories.isEmpty}">
                            <c:set var="categories" value="${showCategoryLeafsOnly ? res.categories.leafItems : res.categories.allItems}" />
                            <div class="dl-cat"><%----%>
                                <c:forEach var="category" items="${categories}" varStatus="status">
                                    <span class="dl-cat-label">${category.title}</span><%----%>
                                </c:forEach>
                            </div><%----%>
                        </c:if>
                        <c:if test="${showDescription and not empty description}">
                            <div class="dl-desc">${description}</div><%----%>
                        </c:if>
                    </span><%----%>
                </a><%----%>
                <c:if test="${not fn:contains(displayFormat, 'dl-list-minimal')}">
                    <a href="${link}" download class="dl-link dl-link-down" target="_blank" rel="noopener" title="<fmt:message key="msg.page.download"/>"><%----%>
                        <span class="dl-info"><%----%>
                            <span class="dl-size"><span>${size}</span></span><%----%>
                            <span class="dl-date"><span>${date}</span></span><%----%>
                        </span><%----%>
                        <span class="dl-dl fa fa-cloud-download"></span><%----%>
                    </a><%----%>
                </c:if>
            </div><%----%>
            <mercury:nl />

        </c:when>
        <c:otherwise>

            <%-- ###### Elaborate display format ###### --%>
            <div class="dl-teaser dl-teaser-elaborate"><%----%>
                <div class="row"><%----%>
                    <div class="dl-content fixcol-md-125-rest"><%----%>
                        <c:choose>
                            <c:when test="${showCategories and not res.categories.isEmpty}">
                                <div class="dl-date-cat"><%----%>
                                    <div class="dl-date">${date}</div><%----%>
                                    <c:set var="categories" value="${showCategoryLeafsOnly ? res.categories.leafItems : res.categories.allItems}" />
                                    <div class="dl-cat"><%----%>
                                        <c:forEach var="category" items="${categories}" varStatus="status">
                                            <span class="dl-cat-label">${category.title}</span><%----%>
                                        </c:forEach>
                                    </div><%----%>
                                </div><%----%>
                            </c:when>
                            <c:otherwise>
                                <div class="dl-date">${date}</div><%----%>
                            </c:otherwise>
                        </c:choose>
                        <mercury:link link="${link}" title="${title}" css="dl-link" >
                            <mercury:heading level="${hsize}" text="${title}" css="dl-title" ade="${false}" />
                        </mercury:link>
                        <c:if test="${showFile and not empty propertiesLocale['Title']}">
                            <div class="dl-file"><a href="${link}"><c:out value="${res.name}" /></a></div><%----%>
                        </c:if>
                        <c:if test="${showDescription and not empty description}">
                            <div class="dl-desc">${description}</div><%----%>
                        </c:if>
                        <a href="${link}" download class="btn dl-btn"><%----%>
                            <span class="fa fa-cloud-download"></span><%----%>
                            <fmt:message key="msg.page.download"/><%----%>
                        </a><%----%>
                    </div><%----%>
                    <div class="dl-info fixcol-md-125"><%----%>
                        <a href="${link}" class="btn-info" target="_blank" rel="noopener" title="<fmt:message key="msg.page.display"/>"><%----%>
                            <span class="fa ${icon}"></span><span class="dl-info-text"><fmt:message key="msg.page.display"/></span><%----%>
                        </a><%----%>
                        <div class="dl-stats"><%----%>
                            <span class="dl-type">${suffix}</span><%----%>
                            <span class="dl-size">${size}</span><%----%>
                        </div><%----%>
                    </div><%----%>
                </div><%----%>
            </div><%----%>
            <mercury:nl />

        </c:otherwise>
    </c:choose>

</cms:bundle>
