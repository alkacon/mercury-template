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

<c:set var="setting"                value="${cms.element.setting}" />

<mercury:download-item
    resource="${cms.wrap[cms.element.resource]}"
    hsize="${setting.hsize.toInteger}"
    displayFormat="${setting.listCssWrapper.toString}"
    showFileName="${setting.showFile.toBoolean}"
    showDescription="${setting.showDescription.toBoolean}"
    showCategories="${(setting.categoryOption.toString eq 'allnopath') or (setting.categoryOption.toString eq 'onlyleafs')}"
    showCategoryLeafsOnly="${showCategories and (setting.categoryOption.toString eq 'onlyleafs')}"
/>