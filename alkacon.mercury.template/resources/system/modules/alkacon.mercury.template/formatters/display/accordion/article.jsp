<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages>
<cms:formatter var="content" val="value">

<c:set var="paragraphs" value="${[{
    'Caption': value.Preface,
    'Image': value.Image
}]}" />
<c:set var="ignore" value="${paragraphs.addAll(content.valueList.Paragraph)}" />

<mercury:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-article"
    paragraphs="${paragraphs}"
    contentId="${content.id}"
/>

</cms:formatter>
</mercury:init-messages>