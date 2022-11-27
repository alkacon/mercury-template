<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper}" />

<mercury:nl/>
<div class="element type-opencms-info pivot ${cssWrapper}"><%----%>

    <div class="float-left mr-10"><%----%>
        <mercury:icon icon="info-circle" tag="span" cssWrapper="fs-36" inline="${true}" />
    </div><%----%>

    <h2><%----%>
        <fmt:message key="msg.page.info.installed" />
        <span style="white-space: nowrap;"><%----%>
            OpenCms ${cms.systemInfo.versionNumber}
        </span><%----%>
    </h2><%----%>

    <div class="subelement"><%----%>
        <c:forEach items="${cms.systemInfo.buildInfo}" var="item" varStatus="loop">
            <div>${item.value.niceName}: ${item.value.value}</div><%----%>
        </c:forEach>
    </div><%----%>

    <div><%----%>
        <fmt:message key="msg.page.info.running" />${' '}
        <cms:info property="java.vm.name" />${' '}
        <cms:info property="java.runtime.version" />${' '}
        <fmt:message key="msg.page.info.with" />${' '}
        <cms:info property="os.name" />${' '}
        <cms:info property="os.version" />
    </div><%----%>

</div><%----%>
<mercury:nl/>

</cms:bundle>
