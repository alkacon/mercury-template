<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages reload="true">
<cms:formatter var="content" val="value">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />
<c:set var="showImageLink"          value="${setting.showImageLink.toBoolean}" />

<%--
    Note: Adding the link in ADE will prevent the 'bullseye' OpenCms menu from working.
    That's ok since we intend to use this formatter only for group includes.
    We disable the link if we are in the group editor so ADE works here.
--%>
<mercury:link
    link="${value.Link}"
    test="${showImageLink and not (cms.isEditMode and cms.modelGroupPage)}"
    setTitle="${true}"
    css="imglink" >

    <mercury:image-simple image="${value.Image}" cssWrapper="${cssWrapper}" />

</mercury:link>

</cms:formatter>
</mercury:init-messages>