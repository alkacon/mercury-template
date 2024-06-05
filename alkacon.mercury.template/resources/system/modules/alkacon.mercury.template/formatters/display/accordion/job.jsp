<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<m:init-messages>
<cms:formatter var="content" val="value">

<c:set var="paragraphs" value="${[]}" />
<c:if test="${not empty value.Type}">
    <c:set var="ignore" value="${paragraphs.add({'Caption': value.Type})}" />
</c:if>
<c:set var="ignore" value="${paragraphs.addAll(content.valueList.Introduction)}" />
<c:set var="ignore" value="${paragraphs.addAll(content.valueList.Text)}" />

<m:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-job"
    paragraphs="${paragraphs}"
    contentId="${content.id}"
/>

</cms:formatter>
</m:init-messages>