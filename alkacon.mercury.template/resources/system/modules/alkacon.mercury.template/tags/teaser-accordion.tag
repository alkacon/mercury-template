<%@ tag pageEncoding="UTF-8"
    display-name="teaser-accordion"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays an accordion teaser." %>


<%@ attribute name="title" type="java.lang.String" required="true"
    description="The title of the teaser element." %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="true"
    description="CSS wrapper added to the outmost DIV." %>

<%@ attribute name="accordionId" type="java.lang.String" required="false"
    description="Id of the parent accordion." %>

<%@ attribute name="contentId" type="java.lang.String" required="false"
    description="Id of the content element." %>

<%@ attribute name="instancedate" type="java.lang.String" required="false"
    description="The instance date of the content element, for event series." %>

<%@ attribute name="preface" type="java.lang.String" required="false"
    description="The optional preface text for the accordion." %>

<%@ attribute name="paragraphs" type="java.util.List" required="false"
    description="List of paragraphs to show in the accordion." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="setting"            value="${cms.element.setting}" />
<c:set var="hsize"              value="${setting.hsize.isSet ? setting.hsize.toInteger : 3}" />
<c:set var="imageRatio"         value="${setting.imageRatio.isSet ? setting.imageRatio.toString : null}"/>
<c:set var="imageRatioLg"       value="${setting.imageRatioLg.isSet ? setting.imageRatioLg.toString : null}"/>
<c:set var="showImageZoom"      value="${setting.showImageZoom.toBoolean}" />
<c:set var="showImageCopyright" value="${setting.showImageCopyright.toBoolean}" />
<c:set var="showImageSubtitle"  value="${setting.showImageSubtitle.toBoolean}" />
<c:set var="open"               value="${setting.firstOpen.toBoolean and (setting.index.toInteger == 0)}" />
<c:set var="multipleOpen"       value="${setting.multipleOpen.toBoolean}" />
<c:set var="parentId"           value="${not empty accordionId ? accordionId : setting.listid.toString}" />
<c:set var="contentId"><m:idgen prefix="" uuid="${not empty contentId ? contentId : cms.element.instanceId}" />${empty instancedate ? '' : '_'.concat(fn:replace(instancedate.hashCode(), '-', ''))}</c:set>
<c:set var="itemId"             value="a${parentId}${contentId}" />

<m:nl />
<article class="accordion ${cssWrapper}"><%----%>
<m:nl />

    ${'<h'}${hsize} class="acco-header pivot"${'>'}
        <button type="button" <%--
        --%>class="acco-toggle ${open ? '':'collapsed'}" <%--
        --%>data-bs-toggle="collapse" <%--
        --%>data-bs-target="#${itemId}" <%--
        --%>aria-controls="${itemId}" <%--
        --%>aria-expanded="${open}"><%--
        --%><c:out value="${title}"></c:out>
        </button><%----%>

        <c:if test="${cms.isEditMode}">
            <a href="#${itemId}" class="hash-link"><%----%>
                <span class="badge oct-meta-info"><%----%>
                    <m:icon icon="hashtag" tag="span" />
                </span><%----%>
            </a><%----%>
        </c:if>
    ${'</h'}${hsize}${'>'}

    <div id="${itemId}" class="acco-body collapse ${open ? 'show' : ''}"${multipleOpen ? '' : ' data-bs-parent=\"#'.concat(parentId).concat('\"')}><%----%>
        <c:if test="${not empty preface}">
             <m:heading text="${preface}" level="${7}" css="sub-header pivot" ade="${false}" />
        </c:if>
        <m:paragraphs
            pieceLayout="${9}"
            paragraphs="${paragraphs}"
            cssWrapper="paragraph"
            splitDownloads="${false}"
            hsize="${hsize + 1}"
            imageRatio="${imageRatio}"
            imageRatioLg="${imageRatioLg}"
            showImageZoom="${showImageZoom}"
            showImageCopyright="${showImageCopyright}"
            showImageSubtitle="${showImageSubtitle}"
            ade="${false}"
        />
        <jsp:doBody />
    </div><%----%>

<m:nl />
</article><%----%>
<m:nl />

