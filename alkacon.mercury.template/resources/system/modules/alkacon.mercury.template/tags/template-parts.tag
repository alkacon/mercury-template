<%@ tag pageEncoding="UTF-8"
    display-name="template-part"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Controls if the template or the mega menu is generated." %>


<%@ attribute name="containerName" type="java.lang.String" required="true"
    description="Name of the main body container." %>

<%@ attribute name="top" required="true" fragment="true"
    description="Template markup inserted at the top." %>

<%@ attribute name="middle" required="true" fragment="true"
    description="Template markup inserted in the middle - this may be replaced by the menga menu." %>

<%@ attribute name="bottom" required="true" fragment="true"
    description="Template markup insereted at the bottom." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<%--
There are 3 use cases:

Case 1: Regular template request
        --> Just render all 3 fragments
Case 2: Mega menu editor request
        --> Render only the 'header' and 'footer' fragments
        --> Instead of the 'body' fragment render the special mega menu container
Case 3: Mega menu display request
        --> Do NOT render any of the 3 fragments
        --> Just render the special mega menu container
--%>

<c:set var="megaMenuAjaxRequest"    value="${param.megamenu eq 'true'}" />
<c:set var="megaMenuFile"           value="${cms.sitemapConfig.attribute['template.mega.menu.filename'].isSetNotNone ? cms.sitemapConfig.attribute['template.mega.menu.filename'] : 'mega.menu'}" />
<c:set var="megaMenuUri"            value="${fn:endsWith(cms.requestContext.uri, megaMenuFile)}" />
<c:set var="megaMenuDisplayRequest" value="${megaMenuUri and megaMenuAjaxRequest}" />
<c:set var="megaMenuEditorRequest"  value="${megaMenuUri and not megaMenuAjaxRequest and not cms.isOnlineProject}" />

<c:if test="${not megaMenuAjaxRequest}">
    <jsp:invoke fragment="top" />
</c:if>

<c:choose>
    <c:when test="${megaMenuDisplayRequest or megaMenuEditorRequest}">
        <fmt:setLocale value="${cms.workplaceLocale}" />
        <cms:bundle basename="alkacon.mercury.template.messages">
            <c:set var="container">
                <cms:container
                    name="${containerName}-megamenu"
                    type="row"
                    maxElements="2"
                    editableby="ROLE.DEVELOPER">
                    <cms:param name="cssgrid" value="#" />
                    <c:set var="message"><fmt:message key="msg.page.layout.megaMenu.container" /></c:set>
                    <m:container-box
                        label="${message}"
                        boxType="container-box"
                        type="row"
                        role="ROLE.DEVELOPER"
                    />
                </cms:container>
            </c:set>

            <c:choose>

                <c:when test="${megaMenuEditorRequest}">
                    <div id="mega-menu-editor">
                        <div class="container">
                            <c:if test="${cms.isEditMode}">
                                <m:alert type="editor">
                                    <jsp:attribute name="head">
                                        <fmt:message key="msg.page.layout.megaMenu.editor" />
                                    </jsp:attribute>
                                    <jsp:attribute name="text">
                                        ${cms.requestContext.folderUri}
                                    </jsp:attribute>
                                </m:alert>
                            </c:if>
                            <div class="nav-main-container">
                                <div class="nav-main-group">
                                    <ul class="nav-main-items">
                                        <li class="mega">
                                            <div class="nav-menu nav-mega-menu">
                                                ${container}
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>

                <c:otherwise>
                    ${container}
                </c:otherwise>

            </c:choose>

        </cms:bundle>
    </c:when>
    <c:otherwise>
        <jsp:invoke fragment="middle" />
    </c:otherwise>
</c:choose>

<c:if test="${not megaMenuAjaxRequest}">
    <jsp:invoke fragment="bottom" />
</c:if>