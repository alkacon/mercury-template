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

<mercury:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-event"
    preface="${value.Preface}"
    paragraphs="${content.valueList.Paragraph}"
    contentId="${content.id}"
    instancedate="${value.Dates.toDateSeries.isSeries ? cms.element.settings.instancedate : null}"
/>

</cms:formatter>
</mercury:init-messages>