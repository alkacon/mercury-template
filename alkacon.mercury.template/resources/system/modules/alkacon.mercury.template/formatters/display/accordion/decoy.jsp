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

<c:set var="paragraphs" value="${[{
    'Text': value.Preface,
    'Image': value.Image,
    'Link': value.Link
}]}" />

<m:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-decoy"
    paragraphs="${paragraphs}"
    contentId="${content.id}"
/>

</cms:formatter>
</m:init-messages>