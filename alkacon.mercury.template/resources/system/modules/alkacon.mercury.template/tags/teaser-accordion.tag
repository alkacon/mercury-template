<%@ tag pageEncoding="UTF-8"
    display-name="teaser-compact"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays an accordion teaser." %>


<%@ attribute name="title" type="java.lang.String" required="true"
    description="The title of the teaser element." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="true"
    description="CSS wrapper added to the outmost DIV." %>

<%@ attribute name="accordionId" type="java.lang.String" required="false"
    description="Id of the parent accordion." %>

<%@ attribute name="preface" type="java.lang.String" required="false"
    description="The optional preface text for the accordion." %>

<%@ attribute name="paragraphs" type="java.util.List" required="false"
    description="List of paragraphs to show in the accordion." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="setting"        value="${cms.element.setting}" />
<c:set var="hsize"          value="${setting.hsize.isSet ? setting.hsize.toInteger : 3}" />
<c:set var="showImageZoom"  value="${setting.showImageZoom.toBoolean}" />
<c:set var="open"           value="${setting.firstOpen.toBoolean and (setting.index.toInteger == 0)}" />
<c:set var="accordionId"    value="${empty accordionId ? setting.listid.toString : accordionId}" />
<c:set var="itemId"><mercury:idgen prefix="acco" uuid="${cms.element.instanceId}" />_${setting.index.toInteger}</c:set>

<mercury:nl />
<article class="accordion ${cssWrapper}"><%----%>
<mercury:nl />

    ${'<h'}${hsize} class="acco-header"${'>'}
        <a class="acco-toggle ${open ? '':'collapsed'}"<%--
        --%>data-toggle="collapse" <%--
        --%>data-target="#${itemId}" <%--
        --%>href="#${itemId}"><%----%>
            <c:out value="${title}"></c:out>
        </a><%----%>
    ${'</h'}${hsize}${'>'}

    <div id="${itemId}" class="acco-body collapse ${open ? 'show' : ''}" data-parent="#${accordionId}"><%----%>
        <c:if test="${not empty preface}">
             <mercury:heading text="${preface}" level="${7}" css="sub-header" ade="${false}" />
        </c:if>
        <mercury:paragraphs
            pieceLayout="${9}"
            paragraphs="${paragraphs}"
            splitDownloads="${false}"
            hsize="${hsize + 1}"
            showImageZoom="${showImageZoom}"
            ade="${false}"
        />
        <jsp:doBody />
    </div><%----%>

<mercury:nl />
</article><%----%>
<mercury:nl />

