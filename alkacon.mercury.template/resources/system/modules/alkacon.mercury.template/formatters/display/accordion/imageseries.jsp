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

<jsp:useBean id="paragraph" class="java.util.HashMap" />
<c:set target="${paragraph}" property="Caption"     value="${value.Preface}"/>
<c:set target="${paragraph}" property="Text"        value="${value.Text}"/>
<c:set target="${paragraph}" property="Image"       value="${value.Image}"/>

<c:set var="paragraphs" value="${cms:createList()}" />
${cms:addToList(paragraphs, paragraph)}

<mercury:teaser-accordion
    title="${value.Title}"
    cssWrapper="type-imageseries"
    paragraphs="${paragraphs}"
/>

</cms:formatter>
</mercury:init-messages>