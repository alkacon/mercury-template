<%@ tag pageEncoding="UTF-8"
    display-name="container-attachment"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a detail only attachment container." %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the container will be generated." %>

<%@ attribute name="name" type="java.lang.String" required="true"
    description="The name for the container that will be generated." %>

<%@ attribute name="role" type="java.lang.String" required="false"
    description="The role of the user. Used for displaying in the box." %>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="The container type. Defaults to 'element'." %>

<%@ attribute name="maxElements" type="java.lang.String" required="false"
    description="The maximal number of elements that fit into the container." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="Additional CSS class that is added to the generated container DIV." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="isDetailRequest" value="${cms.detailRequest}" />
<c:choose>
    <c:when test="${isDetailRequest}">
        <%-- This is a standard request to a detail page --%>
        <c:set var="isRequestToMatchingPage"         value="${cms.detailContentId eq content.file.structureId and (empty cms.container or not cms.container.detailOnly)}" />
        <c:set var="isDetailOnly"                    value="${true}" />
    </c:when>
    <c:otherwise>
         <%-- This is not a detail request  --%>
        <c:set var="propDetailLink"                  value="${content.resource.property['mercury.detail.link']}" />
         <c:choose>
            <c:when test="${not empty propDetailLink and cms.vfs.exists[propDetailLink]}">
                <%-- The detail content hat the property 'mercury.detail.link' set - check if the current uri is identical to one set in the property --%>
                <c:set var="propDetailLinkRes"       value="${cms.vfs.readResource[propDetailLink]}" />
                <c:if test="${propDetailLinkRes.isFolder()}">
                    <c:set var="propDetailLinkRes"   value="${cms.wrap[cms.vfs.cmsObject.readDefaultFile(propDetailLink)]}" />
                </c:if>
                <c:set var="isRequestToMatchingPage" value="${cms.vfs.readResource[cms.requestContext.uri].structureId eq propDetailLinkRes.structureId}" />
                <c:set var="isDetailRequest"         value="${isRequestToMatchingPage}" />
                <c:set var="isDetailOnly"            value="${false}" />
            </c:when>
            <c:otherwise>
                <%-- Check if this is a request on the matching detail page to display a placeholder for the container  --%>
                <c:set var="isDetailPageEditMode"    value="${cms.isEditMode and (fn:replace(cms.requestContext.uri, '/index.html' ,'/') eq cms.typeDetailPage[content.typeName])}" />
            </c:otherwise>
         </c:choose>
    </c:otherwise>
</c:choose>

<c:if test="${isRequestToMatchingPage or isDetailPageEditMode}">

    <c:set var="type" value="${empty type ? 'element' : type }" />
    <c:set var="cssWrapper" value="${empty cssWrapper ? 'attachment-container' : cssWrapper}" />

    <c:choose>
        <c:when test="${not isDetailRequest and isDetailPageEditMode}">
            <%-- Render a placeholder in the editor in case the configured detail page of the content is edited --%>
            <div class="${cssWrapper}"><%----%>
                <m:container-box
                    label="${name}"
                    boxType="detail-placeholder"
                    cssWrapper="attachment"
                    type="${type}"
                    hideParentType="${true}"
                />
            </div><%----%>
            <m:nl />
        </c:when>

        <c:when test="${isDetailRequest and isRequestToMatchingPage}">
            <%-- Render the container in case this is a detail request to the matching page --%>
            <cms:container
                name="${name}"
                nameprefix="none"
                type="${type}"
                tagClass="${cssWrapper}"
                detailonly="${isDetailOnly}"
                editableby="${role}"
                maxElements="${maxElements}" >
                <m:container-box
                    label="${name}"
                    boxType="container-box"
                    cssWrapper="attachment"
                    role="${role}"
                    type="${type}"
                    detailView="false"
                    hideParentType="${true}"
                />
            </cms:container>
        </c:when>

    </c:choose>
</c:if>