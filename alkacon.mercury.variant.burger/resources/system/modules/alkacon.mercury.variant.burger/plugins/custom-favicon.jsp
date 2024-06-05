<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="iconPath" value="${cms.vfs.existsResource[cms.subSitePath.concat('favicon.ico')] ? cms.subSitePath : '/'}" />

<%-- See: https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs --%>
<link rel="icon" href="<cms:link>${iconPath}favicon.ico</cms:link>" sizes="any">
<link rel="icon" href="<cms:link>${iconPath}favicon.svg</cms:link>" type="image/svg+xml">
<link rel="apple-touch-icon" href="<cms:link>${iconPath}apple-touch-icon.png</cms:link>"><m:nl />