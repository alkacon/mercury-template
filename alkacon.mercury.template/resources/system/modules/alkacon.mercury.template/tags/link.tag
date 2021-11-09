<%@ tag pageEncoding="UTF-8"
    display-name="link"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays a HTML href link.
        Perfroms all checks to make sure the link is correctly set.
        Also honors the 'open in new window' flag." %>


<%@ attribute name="link" type="java.lang.Object" required="true"
    description="An object that contains the link." %>

<%@ attribute name="fragment" type="java.lang.Object" required="false"
    description="An fragment that is appended to the generated link, provided the link does not contain a fragment already." %>

<%@ attribute name="text" type="java.lang.String" required="false"
    description="Text shown in the link ONLY if body of tag is empty.
    Defaults to the 'Text' value of the provided XML content node if not set." %>

<%@ attribute name="forceText" type="java.lang.String" required="false"
    description="Text shown in the link, overwrinting the content of the XML and the body content if avaialble." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="Optional text shown for the link title.
    Useful in case no XML content wrapper is provided.
    Defaults to the 'Title' value of the provided XML content node if not set." %>

<%@ attribute name="setTitle" type="java.lang.Boolean" required="false"
    description="If 'true' then a title attribute from the XML content node is added to the generated link.
    Default is 'false' if not provided or 'true' if a seperate title attribute has been given." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated href tag." %>

<%@ attribute name="style" type="java.lang.String" required="false"
    description="Optional CSS inline styles added to the generated href tag." %>

<%@ attribute name="attr" type="java.lang.String" required="false"
    description="Optional attribute(s) added directly to the generated href tag." %>

<%@ attribute name="newWin" type="java.lang.Boolean" required="false"
    description="If 'true', the generated href will open the link target in a new window." %>

<%@ attribute name="createButton" type="java.lang.Boolean" required="false"
    description="If 'true', a button with onlick action will be gernerated instead of an a href link.
    This is only supported if there is no body content in this tag." %>

<%@ attribute name="noExternalMarker" type="java.lang.Boolean" required="false"
    description="If 'true', no external marker CSS will be added to links pointing to an external server." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually create the markup around the body to the calling element.
    If not set or 'true', the markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and just the body of the tag is returned. " %>

<%@ attribute name="testFailTag" type="java.lang.String" required="false"
    description="In case the test failed, generate an alternative tag stead of 'a href' around the body.
    Provide the tag name to generate, e.g. 'div' or 'span'.
    This can be used in case the markup structure around the body must always have a wrapper with the provided 'css', 'style' or 'attr' values." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:choose>

<c:when test="${empty test or test or not empty testFailTag}">

    <c:choose>
        <c:when test="${not empty forceText}">
            <c:set var="body" value="${forceText}" />
        </c:when>
        <c:otherwise>
            <jsp:doBody var="body" />
        </c:otherwise>
    </c:choose>

    <c:choose>

        <c:when test="${empty test or test}">

            <c:choose>
                <c:when test="${cms:isWrapper(link)}">
                    <c:choose>
                        <c:when test="${link.isSet and link.value.URI.isSet}">
                            <c:set var="targetLink" value="${link.value.URI.toLink}" />
                            <c:if test="${empty newWin}">
                                <c:set var="newWin" value="${link.value.NewWindow.toBoolean}" />
                            </c:if>
                            <c:choose>
                                <c:when test="${not empty title}">
                                    <c:set var="linkTitle" value="${title}" />
                                </c:when>
                                <c:when test="${setTitle and link.value.Text.isSet}">
                                    <c:set var="linkTitle" value="${link.value.Text.toString}" />
                                </c:when>
                            </c:choose>
                            <c:if test="${empty body and link.value.Text.isSet}">
                                <c:set var="linkTextContent" value="${link.value.Text.toString}" />
                            </c:if>
                        </c:when>
                        <c:when test="${link.isSet and
                            ((link.typeName == 'OpenCmsVfsFile') or
                            (link.typeName == 'OpenCmsVarLink') or
                            (link.typeName == 'OpenCmsString'))}">
                                <c:set var="targetLink" value="${link.toLink}" />
                        </c:when>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <c:if test="${not empty title}">
                        <c:set var="linkTitle" value="${title}" />
                    </c:if>
                    <c:set var="targetLink" value="${link.toString()}" />
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${not empty targetLink}">

                    <c:if test="${fn:startsWith(targetLink, '/') or fn:startsWith(targetLink, 'javascript:') or fn:startsWith(targetLink, 'opencms:')}">
                        <c:set var="internal" value="${true}" />
                    </c:if>
                    <c:if test="${(not empty fragment) and (not fn:contains(targetLink, '#'))}">
                        <c:set var="targetLink" value="${targetLink}#${fragment}" />
                    </c:if>
                    <c:set var="targetLink"><mercury:link-opencms targetLink="${targetLink}" /></c:set>

                    <c:set var="createButton" value="${createButton and empty body}" />
                    <c:if test="${empty body and not internal and not noExternalMarker}">
                        <c:set var="css" value="${css} external" />
                    </c:if>

                    <c:choose>
                        <c:when test="${createButton}">
                            <%--
                                Using a button with onclick event instead of a href passes
                                the Google SEO test 'Links Do Not Have Descriptive Text'.
                                However, since there is no link tag generated, this would work only with JavaScript enabled.
                                Therefore the use of this option is discouraged.
                            --%>
                            <c:choose>
                                <c:when test="${newWin}">
                                    <c:set var="btnAction">window.open('${targetLink}', '_blank')</c:set>
                                </c:when>
                                <c:otherwise>
                                    <c:set var="btnAction">location.href='${targetLink}'</c:set>
                                </c:otherwise>
                            </c:choose>
                            ${'<button onclick=\"'}${btnAction}${'\"'}
                                <c:if test="${not empty css}">${' '}class="${css}"</c:if>
                                <c:if test="${not empty style}">${' '}style="${style}"</c:if>
                                <c:if test="${not empty attr}">${' '}${attr}</c:if>
                                <c:if test="${not empty linkTitle}">${' '}title="${linkTitle}"</c:if>
                            ${'>'}
                        </c:when>
                        <c:otherwise>
                            ${'<a href=\"'}${targetLink}${'\"'}
                                <c:if test="${not empty css}">${' '}class="${css}"</c:if>
                                <c:if test="${not empty style}">${' '}style="${style}"</c:if>
                                <c:if test="${not empty attr}">${' '}${attr}</c:if>
                                <c:if test="${not empty linkTitle}">${' '}title="${linkTitle}"</c:if>
                                <c:if test="${newWin}">${' '}target="_blank" rel="noopener"</c:if>
                            ${'>'}
                        </c:otherwise>
                    </c:choose>

                    <c:choose>
                        <c:when test="${not empty linkTextContent}">
                            <c:out value="${linkTextContent}" />
                        </c:when>
                        <c:when test="${empty body}">
                            <c:if test="${empty text}">
                                <fmt:setLocale value="${cms.locale}" />
                                <cms:bundle basename="alkacon.mercury.template.messages">
                                    <c:set var="text"><fmt:message key="msg.page.moreLink" /></c:set>
                                </cms:bundle>
                            </c:if>
                            <c:out value="${text}" />
                        </c:when>
                        <c:otherwise>
                            ${body}
                        </c:otherwise>
                    </c:choose>

                    <c:choose>
                        <c:when test="${createButton}">
                            ${'</button>'}
                        </c:when>
                        <c:otherwise>
                            ${'</a>'}
                        </c:otherwise>
                    </c:choose>
                </c:when>

                <c:otherwise>
                    <%-- targetLink was empty --%>
                    ${body}
                </c:otherwise>

            </c:choose>

        </c:when>

        <c:when test="${not empty test and not test and not empty testFailTag}">
            ${'<'}${testFailTag}
                <c:if test="${not empty css}">${' '}class="${css}"</c:if>
                <c:if test="${not empty style}">${' '}style="${style}"</c:if>
                <c:if test="${not empty attr}">${' '}${attr}</c:if>
            ${'>'}
            ${body}
            ${'</'}${testFailTag}${'>'}
         </c:when>

    </c:choose>

</c:when>
<c:otherwise>
    <%-- Initial test did fail --%>
    <jsp:doBody />
</c:otherwise>
</c:choose>