<%@ tag
    pageEncoding="UTF-8"
    display-name="container-attachment"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a detail only attachment container." %>

<%@attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the container will be generated." %>

<%@attribute name="name" type="java.lang.String" required="true"
    description="The name for the container that will be generated." %>

<%@attribute name="role" type="java.lang.String" required="false"
    description="The role of the user. Used for displaying in the box." %>

<%@attribute name="type" type="java.lang.String" required="false"
    description="The container type. Defaults to 'element'." %>

<%@attribute name="maxElements" type="java.lang.String" required="false"
    description="The maximal number of elements that fit into the container." %>

<%@attribute name="cssWrapper" type="java.lang.String" required="false"
    description="Additional CSS class that is added to the generated container DIV." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%-- Only render attachment containers for a detail request to the matching detail page. --%>
<%-- Required so we can use a detail formatter, e.g. for the image series, inside an attachment container of another content. --%>
<c:set var="isRequestToMatchingPage"    value="${cms.detailContentId eq content.file.structureId}" />
<%-- Render a placeholder in the editor in case the configured detail page of the content is edited --%>
<c:set var="isDetailPageEditMode"       value="${cms.isEditMode and (fn:replace(cms.requestContext.uri, '/index.html' ,'/') eq cms.typeDetailPage[content.typeName])}" />
<c:if test="${isRequestToMatchingPage or isDetailPageEditMode}">

    <c:set var="type" value="${empty type ? 'element' : type }" />

    <c:choose>
        <c:when test="${not cms.detailRequest and isDetailPageEditMode}">
            <mercury:container-box
                label="${name}"
                boxType="detail-placeholder"
                cssWrapper="attachment"
                type="${type}"
            />
        </c:when>

        <c:when test="${cms.detailRequest and isRequestToMatchingPage}">
            <c:set var="role" value="${empty role ? 'ROLE.EDITOR' : role}" />
            <c:set var="cssWrapper" value="${empty cssWrapper ? 'attachment-container' : cssWrapper}" />
            <cms:container
                name="${name}"
                nameprefix="none"
                type="${type}"
                tagClass="${cssWrapper}"
                detailonly="true"
                editableby="${role}"
                maxElements="${maxElements}" >
                <mercury:container-box
                    label="${name}"
                    boxType="container-box"
                    cssWrapper="attachment"
                    role="${role}"
                    type="${type}"
                    detailView="false"
                />
            </cms:container>
        </c:when>

    </c:choose>
</c:if>