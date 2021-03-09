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

<c:set var="paragraph" value="${{
    'Text': value.Preface,
    'Image': value.Image,
    'Link': value.Link
}}" />

<mercury:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-decoy"
    paragraphs="${[paragraph]}"
/>

</cms:formatter>
</mercury:init-messages>