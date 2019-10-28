<%@ tag pageEncoding="UTF-8"
    display-name="container-box"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a placehoder box for containers and model groups." %>


<%@ attribute name="label" type="java.lang.String" required="true"
        description="Usually the name of the element or the group."%>

<%@ attribute name="boxType" type="java.lang.String" required="true"
        description="Determines to type of box to render.
        Possible values are [
        container-box: Render a standard container placeholder.
        detail-placeholder: Render a detailpage specific placeholder.
        model-start: Renders the opening part of a model placeholder box.
        model-end: Renders the closing part of a model placeholder box.
        ]"%>

<%@ attribute name="role" type="java.lang.String" required="false"
        description="The role of the user. Used for displaying in the box." %>

<%@ attribute name="type" type="java.lang.String" required="false"
        description="The type of elements the container takes." %>

<%@ attribute name="detailView" type="java.lang.Boolean" required="false"
        description="A boolean that indicates if this is a detail container." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="Optional CSS classes to attach to the generated container div." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>


<fmt:setLocale value="${cms.workplaceLocale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:choose>

<c:when test="${cms.isOnlineProject or not cms.isEditMode}">
    <%-- Never generate any output in the online project --%>
</c:when>

<c:when test="${(boxType == 'container-box') || (boxType == 'detail-placeholder')}">
    <%-- Use case 1: Create container or detail container placeholder box --%>

    <c:choose>
      <c:when test="${fn:containsIgnoreCase(type, 'area')}">
        <c:set var="variant" value="area" />
      </c:when>
      <c:when test="${fn:containsIgnoreCase(type, 'segment')}">
        <c:set var="variant" value="segment" />
      </c:when>
      <c:when test="${fn:containsIgnoreCase(type, 'grid')}">
        <c:set var="variant" value="grid" />
      </c:when>
      <c:when test="${fn:containsIgnoreCase(type, 'row')}">
        <c:set var="variant" value="row" />
      </c:when>
      <c:when test="${fn:containsIgnoreCase(type, 'element')}">
        <c:set var="variant" value="element" />
      </c:when>
      <c:otherwise>
        <c:set var="variant" value="special" />
      </c:otherwise>
    </c:choose>

    <c:if test="${not empty role}">
      <c:set var="role" value="${fn:substringAfter(role, '.')}" />
      <c:if test="${fn:startsWith(role, 'ELEMENT_')}">
          <c:set var="role" value="${fn:substringAfter(role, '_')}" />
      </c:if>
      <c:set var="role" value="${fn:toLowerCase(role)}" />
    </c:if>

    <c:set var="parentType" value="Template Container" />
    <c:if test="${not empty cms.container.parentInstanceId}">
        <c:set var="parentType" value="${cms.parentContainers[cms.container.parentInstanceId].type}" />
    </c:if>

    <div class="container-box box-${variant}${' '}${cssWrapper}"><%----%>
        <div class="head"><%----%>
            <c:choose>
                <c:when test="${boxType eq 'detail-placeholder'}">
                    <span><fmt:message key="msg.page.layout.detailcontainer"/></span><%----%>
                    <span class="label-special"><fmt:message key="msg.page.layout.blocked"/></span><%----%>
                    <span class="label-detailonly"><fmt:message key="msg.page.layout.detailonly"/></span><%----%>
                </c:when>
                <c:otherwise>
                    <span><fmt:message key="msg.page.layout.headline.emptycontainer"/></span><%----%>
                    <c:if test="${role ne 'author'}">
                        <span class="label-${fn:toLowerCase(role)}"><fmt:message key="msg.option.role.${role}"/></span><%----%>
                    </c:if>
                    <c:choose>
                        <c:when test="${detailView}">
                            <span class="label-detail"><fmt:message key="msg.page.layout.detailview"/></span><%----%>
                        </c:when>
                        <c:when test="${cms.detailRequest && (cms.element.setting.detail eq 'only')}">
                            <span class="label-detail"><fmt:message key="msg.page.layout.detailonly"/></span><%----%>
                        </c:when>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </div><%----%>
        <div class="text capital"><%----%>
            <div class="main">${label}</div><%----%>
            <c:if test="${not empty cms.container.type}">
                <div class="small"><%----%>
                    <fmt:message key="msg.page.layout.infor">
                        <fmt:param>${parentType}</fmt:param>
                        <fmt:param>${type}</fmt:param>
                    </fmt:message>
                </div><%----%>
            </c:if>
            <c:if test="${empty cms.container.type}">
                <div class="small"><%----%>
                    <fmt:message key="msg.page.layout.for">
                        <fmt:param>${type}</fmt:param>
                    </fmt:message>
                </div><%----%>
            </c:if>
        </div><%----%>
    </div><%----%>

    <%-- End of use case 1: Create container box --%>
</c:when>

<c:when test="${(boxType == 'model-start') and cms.modelGroupElement}">
    <%-- Use case 2: Model box start --%>

    <c:out value='<div id="modelinfo-border">' escapeXml='false' />
    <div id="modelinfo"><%----%>
        <div class="head"><%----%>
            <span><cms:property name="Title" /></span>
            <c:choose>
                <c:when test="${cms.element.setting.use_as_copy_model == 'true'}">
                    <span class="label-copygroup"><fmt:message key="msg.page.layout.modelinfo.copygroup"/></span><%----%>
                </c:when>
                <c:otherwise>
                    <span class="label-reusegroup"><fmt:message key="msg.page.layout.modelinfo.reusegroup"/></span><%----%>
                </c:otherwise>
            </c:choose>
        </div><%----%>
        <div class="text"><cms:property name="Description" /></div><%----%>
    </div>
    <%-- Last div is deliberately not closed, it has to be closed by using "model-end" (see below) --%>

    <%-- End of use case 2: Model box start --%>
</c:when>

<c:when test="${(boxType == 'model-end') and cms.modelGroupElement}">
    <%-- Use case 3: Model box end --%>
    <c:out value='</div>' escapeXml='false' />
    <%-- End of use case 3: Model box end --%>
</c:when>

</c:choose>

</cms:bundle>
