<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<div class="nav-menu-header"><%----%>
    <div class="nav-menu-toggle"><%----%>
        <span id="nav-toggle-label-close" class="nav-toggle-label"><%----%>
            <button class="nav-toggle" aria-expanded="false" aria-controls="nav-toggle-group"><%----%>
                <span class="nav-burger"><fmt:message key="msg.page.navigation.toggle" /></span><%----%>
            </button><%----%>
        </span><%----%>
    </div><%----%>
    <c:if test="${(reqScopeSetting.cssWrapper ne 'no-image') and (not empty reqScopeLogoContent) and (not empty reqScopeLogoContent.value.Image)}">
        <div class="nav-menu-logo"><%----%>
            <mercury:link
                link="${reqScopeLogoContent.value.Link}"
                test="${reqScopeSetting.showImageLink.toBoolean}"
                testFailTag="div"
                setTitle="${true}"
                css="mobile-logolink" >
                <mercury:image-simple
                    image="${reqScopeLogoContent.value.Image}"
                    sizes="200,350,400,700,800"
                    cssWrapper="img-responsive"
                />
            </mercury:link>
        </div><%----%>
    </c:if>
</div><%----%>
<mercury:nl />

</cms:bundle>