<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />

<c:set var="currentSite"            value="${cms.vfs.readSubsiteFor(cms.requestContext.uri)}" />
<c:set var="currentSiteProps"       value="${cms.vfs.readProperties[currentSite]}" />
<c:set var="sitename"               value="${not empty currentSiteProps['mercury.sitename'] ? currentSiteProps['mercury.sitename'] : currentSiteProps['Title'] }" />

<mercury:nl />
<div class="type-sitename ${cssWrapper}"><%----%>

    <mercury:heading level="${hsize}" text="${sitename}" css="head" ade="${false}" />

</div><%----%>
<mercury:nl />
