<%@ tag pageEncoding="UTF-8"
    display-name="teaser-settings"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Collects default element settings." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%@ variable name-given="setting"                   declare="true" variable-class="java.util.Map" %>
<%@ variable name-given="setCssWrapper"             declare="true" %>
<%@ variable name-given="setCssWrapper2"            declare="true" %>
<%@ variable name-given="setCssWrapper3"            declare="true" %>
<%@ variable name-given="setCssWrapperKeyPiece"     declare="true" %>
<%@ variable name-given="setCssWrapperParagraphs"   declare="true" %>
<%@ variable name-given="setCssWrapperExtra"        declare="true" %>
<%@ variable name-given="setEffect"                 declare="true" %>
<%@ variable name-given="setCssVisibility"          declare="true" %>

<%@ variable name-given="setCssWrapper12"           declare="true" %>
<%@ variable name-given="setCssWrapper123"          declare="true" %>
<%@ variable name-given="setCssWrapperAll"          declare="true" %>

<%@ variable name-given="setElementPreMarkup"       declare="true" %>
<%@ variable name-given="settingDefaultsDebug"      declare="true" %>

<m:load-plugins group="setting-defaults"            type="jsp-nocache" />

<c:set var="setting"                                value="${cms.element.setting}" />
<c:set var="setCssWrapper"                          value="${setting.cssWrapper.isSetNotNone ? ' '.concat(setting.cssWrapper.toString) : null}" />
<c:set var="setCssWrapper2"                         value="${setting.cssWrapper2.isSetNotNone ? ' '.concat(setting.cssWrapper2.toString) : null}" />
<c:set var="setCssWrapper3"                         value="${setting.cssWrapper3.isSetNotNone ? ' '.concat(setting.cssWrapper3.toString) : null}" />
<c:set var="setCssWrapperExtra"                     value="${setting.cssWrapperExtra.isSetNotNone  ? ' '.concat(setting.cssWrapperExtra.toString) : null}" />
<c:set var="setCssWrapperKeyPiece"                  value="${setting.cssWrapperKeyPiece.isSetNotNone ? ' '.concat(setting.cssWrapperKeyPiece.toString) : null}" />
<c:set var="setCssWrapperParagraphs"                value="${setting.cssWrapperParagraphs.isSetNotNone ? ' paragraph '.concat(setting.cssWrapperParagraphs.toString) : ' paragraph'}" />
<c:set var="setEffect"                              value="${setting.effect.isSetNotNone ? ' '.concat(setting.effect.toString) : null}" />
<c:set var="setCssVisibility"                       value="${(setting.cssVisibility.isSetNotNone and (setting.cssVisibility.toString ne 'always')) ? ' '.concat(setting.cssVisibility.toString) : null}" />
<c:set var="setElementPreMarkup"                    value="${setting.elementPreMarkup.toString}" />

<c:set var="wrappers" value="${[setCssWrapper, setCssWrapper2, setCssWrapper3]}" />
<c:forEach var="wrapper" items="${wrappers}" varStatus="status">
    <c:if test="${not empty wrapper and fn:contains(wrapper, '@')}">
        <c:set var="entries" value="${fn:split(wrapper, '@')}" />
        <c:forEach var="entry" items="${entries}">
            <c:choose>
                <c:when test="${fn:startsWith(entry, 'kp=')}">
                    <c:set var="entry"                      value="${fn:trim(fn:substringAfter(entry, 'kp='))}" />
                    <c:set var="setCssWrapperKeyPiece"      value="${setCssWrapperKeyPiece}${' '}${entry}" />
                </c:when>
                <c:when test="${fn:startsWith(entry, 'pa=')}">
                    <c:set var="entry"                      value="${fn:trim(fn:substringAfter(entry, 'pa='))}" />
                    <c:set var="setCssWrapperParagraphs"    value="${setCssWrapperParagraphs}${' '}${entry}" />
                </c:when>
                <c:when test="${fn:startsWith(entry, 'ex=')}">
                    <c:set var="entry"                      value="${fn:trim(fn:substringAfter(entry, 'ex='))}" />
                    <c:set var="setCssWrapperExtra"         value="${setCssWrapperExtra}${' '}${entry}" />
                </c:when>
                <c:otherwise>
                    <c:set var="entry"                      value="${' '}${fn:trim(entry)}" />
                    <c:choose>
                        <c:when test="${status.count eq 1}">
                            <c:set var="setCssWrapper"      value="${entry}" />
                        </c:when>
                        <c:when test="${status.count eq 2}">
                            <c:set var="setCssWrapper2"     value="${entry}" />
                        </c:when>
                        <c:when test="${status.count eq 3}">
                            <c:set var="setCssWrapper2"     value="${entry}" />
                        </c:when>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </c:forEach>
    </c:if>

</c:forEach>

<c:set var="setCssWrapper12"                        value="${setCssWrapper}${setCssWrapper2}" />
<c:set var="setCssWrapper123"                       value="${setCssWrapper12}${setCssWrapper3}" />
<c:set var="setCssWrapperAll"                       value="${setCssWrapper123}${setEffect}${setCssVisibility}" />

<jsp:doBody/>
