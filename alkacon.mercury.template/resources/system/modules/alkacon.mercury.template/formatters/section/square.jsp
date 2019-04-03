<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:init-messages>
<cms:formatter var="content" val="value">

<mercury:image-vars image="${value.Image}">

<c:set var="imageBg" value="" />
<c:if test="${not empty imageUrl}">
    <c:set var="imageBg"> style="background-image:linear-gradient(rgba(0, 0, 0, 0.01),rgba(0, 0, 0, 0.4),rgba(0, 0, 0, 0.4),rgba(0, 0, 0, 0.01)),url('${imageUrl}');"</c:set>
</c:if>

<div class="square-col ${cms.element.settings.cssWrapper}">
<div class="content ${cms.element.settings.cssWrapperInner}" ${imageBg}>
<div class="table">
<div class="table-cell">

    <c:if test="${value.Title.isSet}">
        <h2 ${content.rdfa.Title}>${value.Title}</h2>
    </c:if>

    <c:if test="${value.Text.isSet}">
        <div <c:if test="${not value.Link.exists}">${content.rdfa.Link}</c:if>>
            <div ${content.rdfa.Text} ${not empty imageUrl ? content.imageDnd[value.Image.value.Image.path] : ''}>
                ${value.Text}
            </div>
            <c:if test="${value.Link.exists}">
                <p ${content.rdfa.Link}>
                    <mercury:link link="${value.Link}" css="btn btn-sm" setTitle="false"/>
                </p>
            </c:if>
        </div>
    </c:if>

</div>
</div>
</div>
</div>

</mercury:image-vars>

</cms:formatter>
</mercury:init-messages>
