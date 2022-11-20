<%@ tag pageEncoding="UTF-8"
    display-name="download-item"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import="org.opencms.main.*, org.opencms.file.*"
    description="Displays a download item." %>


<%@ attribute name="resource" type="java.lang.Object" required="true"
    description="This can be a CmsResource or a String that links to an external resource." %>

<%@ attribute name="resSize" type="java.lang.Integer" required="false"
    description="The size of resource download in bytes.
    Required for external resources that are not folders.
    Not required in case a CmsResource is provided - in this case the information can be read from the resource attributes." %>

<%@ attribute name="resDate" type="java.lang.Object" required="false"
    description="The date to be displayed for the download resource.
    This can be a java.util.Date Object, a Long value representing a date, or a String representing a Long value for a date.
    Not required in case a CmsResource is provided - in this case the information can be read from the resource properties." %>

<%@ attribute name="resTitle" type="java.lang.String" required="false"
    description="The title of the download resource, e.g. 'My important PDF file'.
    Not required in case a CmsResource is provided - in this case the information can be read from the resource properties." %>

<%@ attribute name="resDescription" type="java.lang.String" required="false"
    description="The description of the download resource.
    Not required in case a CmsResource is provided - in this case the information can be read from the resource properties." %>

<%@ attribute name="resCopyright" type="java.lang.String" required="false"
    description="The copyright of the download resource.
    Not required in case a CmsResource is provided - in this case the information can be read from the resource properties." %>

<%@ attribute name="resCategories" type="org.opencms.jsp.util.CmsJspCategoryAccessBean" required="false"
    description="The categories of the download resource.
    Not required in case a CmsResource is provided- in this case the information can be read from the resource relations." %>

<%@ attribute name="displayFormat" type="java.lang.String" required="false"
    description="Display output format to generate. Possible values are:
    'dl-list-elaborate' (elaborate view, default),
    'dl-list-compact' (compact view) or
    'dl-list-compact dl-list-minimal' (minimal compact view)." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="true"
    description="The HTML level of the heading, must be from 1 to 6 to generate h1 to h6.
    If the special value 7 is used, the text will be outputted as 'div' not as HTML heading.
    If no valid level is provided, for example 0, the headline will not be outputted at all." %>

<%@ attribute name="showFileName" type="java.lang.Boolean" required="false"
    description="Controls if the file name is displayed in addition to the title." %>

<%@ attribute name="showDescription" type="java.lang.Boolean" required="false"
    description="Controls if the description is displayed." %>

<%@ attribute name="showCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the copyright is displayed." %>

<%@ attribute name="showCategories" type="java.lang.Boolean" required="false"
    description="Controls if categories for the file are displayed." %>

<%@ attribute name="showCategoryLeafsOnly" type="java.lang.Boolean" required="false"
    description="Controls if categories are displayed only as leafes or with full path." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%
    Object obj = getJspContext().findAttribute("resource");
    boolean isCmsResource = obj instanceof CmsResource;
    getJspContext().setAttribute("isCmsResource", isCmsResource);
%>

<c:choose>
    <c:when test="${isCmsResource}">
        <c:set var="res"                value="${cms.wrap[resource]}" />
        <c:set var="resLink"            value="${res.link}" />
        <c:set var="resName"            value="${res.name}" />
        <c:set var="resSuffix"          value="${res.extension}" />
        <c:set var="mimeType"           value="${res.mimeType}" />
        <c:set var="propertiesLocale"   value="${res.propertyLocale[cms.locale]}" />
        <c:set var="resSize"            value="${empty resSize ? res.length : resSize}" />
        <c:set var="resCategories"      value="${empty resCategories ? res.categories : resCategories}" />
        <c:set var="resTitle"           value="${empty resTitle ? propertiesLocale['Title'] : resTitle}" />
        <c:set var="resDescription"     value="${empty resDescription ? propertiesLocale['Description'] : resDescription}" />
        <c:set var="resCopyright"       value="${empty resCopyright ? propertiesLocale['Copyright'] : resCopyright}" />
        <c:set var="resDate"            value="${empty resDate ? res.dateLastModified : resDate}" />
    </c:when>
    <c:otherwise>
        <%
            String resLink = String.valueOf(obj);
            String resName = CmsResource.getName(resLink);
            String resSuffix = CmsResource.getExtension(resLink);
            String mimeType = OpenCms.getResourceManager().getMimeType(resLink, null, "text/plain");
            getJspContext().setAttribute("resLink", resLink);
            getJspContext().setAttribute("resName", resName);
            getJspContext().setAttribute("resSuffix", resSuffix);
            getJspContext().setAttribute("mimeType", mimeType);
        %>
    </c:otherwise>
</c:choose>

<c:if test="${showCopyright and not empty resCopyright}">
    <%-- Copyright is displayed as part of the description --%>
    <c:if test="${not showDescription}">
        <c:set var="showDescription" value="${true}" />
        <c:set var="resDescription" value="" />
    </c:if>
    <c:set var="resCopyrightMarkup"><div class="dl-copy">&copy ${resCopyright}</div></c:set>
    <c:set var="resDescription"     value="${empty resDescription ? resCopyrightMarkup : resDescription.concat(resCopyrightMarkup)}" />
</c:if>

<c:set var="showCategories"             value="${showCategories and (not empty resCategories) and (not resCategories.isEmpty)}" />
<c:set var="title"                      value="${empty resTitle ? resName : resTitle}" />
<c:set var="resSuffix"                  value="${fn:toUpperCase(resSuffix)}" />
<c:set var="resDateStr"><fmt:formatDate value="${cms:convertDate(resDate)}" type="date" dateStyle="SHORT" /></c:set>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

    <c:choose>
        <c:when test="${resSuffix eq 'TXT'}">
            <c:set var="icon">file-text-o</c:set>
        </c:when>
        <c:when test="${fn:startsWith(mimeType, 'image') or resSuffix eq 'AI' or resSuffix eq 'EPS'}">
            <c:set var="icon">file-image-o</c:set>
        </c:when>
        <c:when test="${fn:startsWith(mimeType, 'video')}">
            <c:set var="icon">file-video-o</c:set>
        </c:when>
        <c:when test="${fn:startsWith(mimeType, 'audio')}">
            <c:set var="icon">file-audio-o</c:set>
        </c:when>
        <c:when test="${resSuffix eq 'PDF'}">
            <c:set var="icon">file-pdf-o</c:set>
        </c:when>
        <c:when test="${resSuffix eq 'HTML' or resSuffix eq 'HTM'}">
            <c:set var="icon">html5</c:set>
        </c:when>
        <c:when test="${resSuffix eq 'DOC' or resSuffix eq 'DOCX'}">
            <c:set var="icon">file-word-o</c:set>
        </c:when>
        <c:when test="${resSuffix eq 'XLS' or resSuffix eq 'XLSX'}">
            <c:set var="icon">file-excel-o</c:set>
        </c:when>
        <c:when test="${resSuffix eq 'PPT' or resSuffix eq 'PPTX'}">
            <c:set var="icon">file-powerpoint-o</c:set>
        </c:when>
        <c:when test="${resSuffix eq 'ZIP' or resSuffix eq 'RAR'}">
            <c:set var="icon">file-archive-o</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="icon">file-o</c:set>
        </c:otherwise>
    </c:choose>

    <c:set var="digits" value="${fn:length(''.concat(resSize))}" />
    <c:choose>
        <c:when test="${digits > 6}">
            <c:set var="resSize" value="${resSize div (1024 * 1024)}" />
            <c:set var="unit">MB</c:set>
        </c:when>
        <c:when test="${digits > 3}">
            <c:set var="resSize" value="${resSize div 1024}" />
            <c:set var="unit">KB</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="unit">Byte</c:set>
        </c:otherwise>
    </c:choose>
    <c:set var="resSize">${cms:mathRound(resSize)}${' '}${unit}</c:set>

    <c:choose>
        <c:when test="${fn:contains(displayFormat, 'dl-list-compact')}">

            <%-- ###### Compact / Minimal display format ###### --%>
            <div class="dl-teaser dl-teaser-compact${showFileName ? ' dl-show-file' : ''}${showDescription ? ' dl-show-desc' : ''}">
                <a href="${resLink}" class="dl-link dl-link-disp" target="_blank" rel="noopener" rel="noopener" title="<fmt:message key="msg.page.display"/>"><%----%>
                    <mercury:icon icon="${icon}" tag="span" cssWrapper="dl-type" use="download-item" />
                    <span class="dl-content"><%----%>
                        <mercury:heading level="${hsize}" text="${title}" css="dl-title" ade="${false}" />
                        <c:if test="${showFileName and not empty resTitle}">
                            <div class="dl-file">${resName}</div><%----%>
                        </c:if>
                        <c:if test="${showCategories}">
                            <c:set var="categories" value="${showCategoryLeafsOnly ? resCategories.leafItems : resCategories.allItems}" />
                            <div class="dl-cat"><%----%>
                                <c:forEach var="category" items="${categories}" varStatus="status">
                                    <span class="dl-cat-label">${category.title}</span><%----%>
                                </c:forEach>
                            </div><%----%>
                        </c:if>
                        <c:if test="${showDescription and not empty resDescription}">
                            <div class="dl-desc">${resDescription}</div><%----%>
                        </c:if>
                    </span><%----%>
                </a><%----%>
                <c:if test="${not fn:contains(displayFormat, 'dl-list-minimal')}">
                    <a href="${resLink}" download class="dl-link dl-link-down" target="_blank" rel="noopener" title="<fmt:message key="msg.page.download"/>"><%----%>
                        <span class="dl-info"><%----%>
                            <span class="dl-size"><span>${resSize}</span></span><%----%>
                            <span class="dl-date"><span>${resDateStr}</span></span><%----%>
                        </span><%----%>
                        <mercury:icon icon="cloud-download" tag="span" cssWrapper="dl-dl" use="download-item" />
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
                            <c:when test="${showCategories}">
                                <div class="dl-date-cat"><%----%>
                                    <div class="dl-date">${resDateStr}</div><%----%>
                                    <c:set var="categories" value="${showCategoryLeafsOnly ? resCategories.leafItems : resCategories.allItems}" />
                                    <div class="dl-cat"><%----%>
                                        <c:forEach var="category" items="${categories}" varStatus="status">
                                            <span class="dl-cat-label">${category.title}</span><%----%>
                                        </c:forEach>
                                    </div><%----%>
                                </div><%----%>
                            </c:when>
                            <c:otherwise>
                                <div class="dl-date">${resDateStr}</div><%----%>
                            </c:otherwise>
                        </c:choose>
                        <mercury:link link="${resLink}" title="${title}" css="dl-link" >
                            <mercury:heading level="${hsize}" text="${title}" css="dl-title" ade="${false}" />
                        </mercury:link>
                        <c:if test="${showFileName and not empty resTitle}">
                            <div class="dl-file"><a href="${resLink}"><c:out value="${resName}" /></a></div><%----%>
                        </c:if>
                        <c:if test="${showDescription and not empty resDescription}">
                            <div class="dl-desc">${resDescription}</div><%----%>
                        </c:if>
                        <a href="${resLink}" download class="btn dl-btn"><%----%>
                            <mercury:icon icon="cloud-download" tag="span" use="download-item" />
                            <fmt:message key="msg.page.download"/><%----%>
                        </a><%----%>
                    </div><%----%>
                    <div class="dl-info fixcol-md-125"><%----%>
                        <a href="${resLink}" class="btn-info" target="_blank" rel="noopener" title="<fmt:message key="msg.page.display"/>"><%----%>
                            <span class="fa ${icon}"></span><span class="dl-info-text"><fmt:message key="msg.page.display"/></span><%----%>
                        </a><%----%>
                        <div class="dl-stats"><%----%>
                            <span class="dl-type">${resSuffix}</span><%----%>
                            <span class="dl-size">${resSize}</span><%----%>
                        </div><%----%>
                    </div><%----%>
                </div><%----%>
            </div><%----%>
            <mercury:nl />

        </c:otherwise>
    </c:choose>

</cms:bundle>



