<%@ tag pageEncoding="UTF-8"
    display-name="accordion"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays content in an accordion." %>


<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="Additional CSS class that is added  the div surrounding the generated accordion." %>

<%@ attribute name="tabLabel" type="java.lang.String" required="true"
    description="The accordion tab label." %>

<%@ attribute name="tabHsize" type="java.lang.Integer" required="true"
    description="The heading size the accordion tab label is generated in." %>

<%@ attribute name="parentId" type="java.lang.String" required="true"
    description="The ID for the accordion parent." %>

<%@ attribute name="tabId" type="java.lang.String" required="true"
    description="The ID for the generated accordion tab." %>

<%@ attribute name="open" type="java.lang.Boolean" required="false"
    description="If 'true', then this accordion tab is assumed open on page load." %>

<%@ attribute name="multipleOpen" type="java.lang.Boolean" required="false"
    description="If 'true', then this accordion can have multiple tabs open at the same time." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


    <mercury:nl />
    <article class="accordion${not empty cssWrapper ? ' '.concat(cssWrapper) : ''}"><%----%>
        ${'<h'}${tabHsize} class="acco-header pivot"${'>'}

            <button class="acco-toggle ${open ? '':'collapsed'}" <%--
            --%>data-bs-toggle="collapse" type="button" <%--
            --%>aria-expanded="${open}" <%--
            --%>aria-controls="${tabId}" <%--
            --%>data-bs-target="#${tabId}"><%----%>
                <mercury:out value="${tabLabel}" lenientEscaping="${true}" />
            </button><%----%>

            <c:if test="${cms.isEditMode}">
                <a href="#${tabId}" class="hash-link"><%----%>
                    <span class="badge oct-meta-info"><%----%>
                        <mercury:icon icon="hashtag" tag="span" />
                    </span><%----%>
                </a><%----%>
            </c:if>

        ${'</h'}${tabHsize}${'>'}


        <div id="${tabId}" class="acco-body collapse ${open ? 'show' : ''}"${multipleOpen ? '' : ' data-bs-parent=\"#'.concat(parentId).concat('\"')}><%----%>

            <jsp:doBody />

        </div><%----%>
    </article><%----%>
    <mercury:nl />

