<%@ tag pageEncoding="UTF-8"
    display-name="data-cookies"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates privacy policy cookie data for elements." %>


<%@ attribute name="group" type="java.lang.String" required="true"
    description="Controls which cookie group is activated by the generated cookie alert box." %>

<%@ attribute name="message" type="java.lang.String" required="true"
    description="Element depended messsage for the generated cookie alert box." %>

<%@ attribute name="heading" type="java.lang.String" required="false"
    description="Heading for the generated cookie alert box
    Will be read from the global configuration if not provided." %>

<%@ attribute name="footer" type="java.lang.String" required="false"
    description="Footer for the generated cookie alert box
    Will be read from the global configuration if not provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<c:set var="heading" value="${empty heading ? 'Cookies sind nicht aktiviert' : heading }" />
<c:set var="footer" value="${empty footer ? '<div>Ich bin damit einverstanden, dass mir externe Inhalte angezeigt werden. Damit können personenbezogene Daten an Drittplattformen übermittelt werden. <a href=\"/\">Mehr dazu in unserer Datenschutzerklärung</a>.</div>' : footer }" />

<cms:jsonobject var="cookieData">
    <cms:jsonvalue key="group" value="${group}" />
    <cms:jsonvalue key="heading" value="${heading}" />
    <cms:jsonvalue key="message" value="${message}" />
    <cms:jsonvalue key="footer" value="${footer}" />
</cms:jsonobject>

<%----%>data-cookies='${cookieData.compact}'<%----%>