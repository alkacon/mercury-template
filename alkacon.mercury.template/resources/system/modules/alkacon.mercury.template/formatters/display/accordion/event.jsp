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
    'Caption': value.Preface,
    'Image': value.Image
}]}" />
<c:set var="ignore" value="${paragraphs.addAll(content.valueList.Paragraph)}" />

<m:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-event"
    paragraphs="${paragraphs}"
    contentId="${content.id}"
    instancedate="${value.Dates.toDateSeries.isSeries ? cms.element.settings.instancedate : null}"
/>

</cms:formatter>
</m:init-messages>