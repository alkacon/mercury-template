<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    import="org.opencms.main.*, org.opencms.file.*"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<m:setting-defaults>

<c:set var="cssWrapper"             value="${setCssWrapperAll}" />
<c:set var="loginproject"           value="${setting.loginproject.isSet ? setting.loginproject.toString : 'Online'}" />
<c:set var="loginou"                value="${setting.loginou.isSet ? fn:trim(cms.element.setting.loginou.toString) : null}" />
<c:set var="loginpage"              value="${setting.loginpage.isSet ? fn:trim(cms.element.setting.loginpage.toString) : null}" />
<c:set var="formCssWrapper"         value="${setting.formCssWrapper}" />

<%-- Must close setting tag here because the loginBean uses inline code --%>
</m:setting-defaults>

<c:if test="${not empty loginou and 'Online' ne loginproject}">
    <c:set var="loginproject" value="${loginou eq '/' ? '' : loginou}${loginproject}"/>
</c:if>

<cms:secureparams replaceInvalid="bad_param" />
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<jsp:useBean id="loginBean" class="org.opencms.jsp.CmsJspLoginBean" scope="page">

    <% loginBean.init(pageContext, request, response); %>

    <c:choose>
        <c:when test="${(param.action eq 'login') and (not empty param.username) and (not empty param.password)}">
            <c:set var="loginpage"      value="${empty loginpage ? (empty cms.pageResource.property['login-start'] ? cms.requestContext.uri : cms.pageResource.property['login-start']) : loginpage}" />
            <c:set var="loginresource"  value="${empty param.requestedResource ? loginpage : param.requestedResource}" />
            <c:set var="loginuri"       value="${cms.requestContext.siteRoot}${loginresource}" />
            <c:set var="loginuser"      value="${param.username}"/>
            <c:set var="loginpassword"  value="${param.password}"/>
            <c:choose>
                <c:when test="${not empty loginou}">
                    <c:set var="loginprincipal" value="${loginou eq '/' ? '' : loginou}${loginuser}"/>
                    <c:set var="ignore" value="${loginBean.login(loginprincipal, loginpassword, loginproject, loginresource)}" />
                </c:when>
                <c:otherwise>
                    <m:findorgunit uri="${loginuri}">
                        <c:set var="success" value="${false}" />
                        <c:forEach var="ou" items="${parentOUs}">
                            <c:if test="${not success}">
                                <c:set var="loginprincipal" value="${empty ou.name ? '' : '/'}${ou.name}${loginuser}"/>
                                <c:set var="ignore" value="${loginBean.login(loginprincipal, loginpassword, loginproject, loginresource)}" />
                                <c:set var="success" value="${loginBean.loggedIn}" />
                            </c:if>
                        </c:forEach>
                    </m:findorgunit>
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:when test="${param.action eq 'logoff'}">
            <c:set var="ignore" value="${loginBean.logout()}" />
        </c:when>
    </c:choose>
</jsp:useBean>

<c:set var="loginError" value="${not loginBean.loginSuccess}" />

<m:nl/>
<div class="element type-login-form pivot${cssWrapper}"><%----%>

    <form class="styled-form ${formCssWrapper}" target="_self" method="post"><%----%>
        <input type="hidden" name="requestedResource" value="${param.requestedResource}" /><%----%>
        <c:choose>

            <c:when test="${not loginBean.loggedIn}">
                <header><%----%>
                    <fmt:message key="msg.page.login.loggedoff" />
                </header><%----%>
                <fieldset><%----%>
                    <section><%----%>
                        <label class="input ${loginError ? 'state-error' : ''}"><%----%>
                            <m:icon icon="user-o" tag="span" cssWrapper="icon-prepend" />
                            <input type="text" id="username" name="username" placeholder="<fmt:message key="msg.page.login.username" />"/><%----%>
                        </label><%----%>
                    </section><%----%>
                    <section><%----%>
                        <label class="input ${loginError ? 'state-error' : ''}"><%----%>
                            <m:icon icon="lock" tag="span" cssWrapper="icon-prepend" />
                            <input type="password" id="password" name="password" placeholder="<fmt:message key="msg.page.login.password" />"/><%----%>
                        </label><%----%>
                        <c:if test="${loginError}">
                            <em><fmt:message key="msg.page.login.failed" /></em><%----%>
                        </c:if>
                    </section><%----%>
                </fieldset><%----%>
                <footer><%----%>
                    <button class="btn" type="submit" name="action" value="login" ><fmt:message key="msg.page.login.login" /></button><%----%>
                </footer><%----%>
            </c:when>

            <c:otherwise>
                <header><%----%>
                    <fmt:message key="msg.page.login.status.in" />
                </header><%----%>
                <fieldset><%----%>
                    <section><%----%>
                        <label for="username" class="label"><fmt:message key="msg.page.login.loggedin" />:</label><%----%>
                        <div class="input"><%----%>
                            <m:icon icon="user-o" tag="span" cssWrapper="icon-prepend" />
                            <input type="text" id="username" name="username" value="${cms.requestContext.currentUser.fullName}"/><%----%>
                        </div><%----%>
                    </section><%----%>
                </fieldset><%----%>
                <footer><%----%>
                    <button class="btn" type="submit" name="action" value="logoff" ><fmt:message key="msg.page.login.logoff" /></button><%----%>
                </footer><%----%>
            </c:otherwise>

        </c:choose>
    </form><%----%>
</div><%----%>
<m:nl/>

</cms:bundle>

