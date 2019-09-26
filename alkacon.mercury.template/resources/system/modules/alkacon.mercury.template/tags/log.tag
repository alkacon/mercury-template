<%@ tag pageEncoding="UTF-8"
    display-name="log"
    trimDirectiveWhitespaces="true"
    body-content="empty"
    description="Writes a message to the OpenCms Log." %>


<%@ tag import="org.opencms.main.*, org.apache.commons.logging.Log" %>


<%@ attribute name="message" type="java.lang.String" required="true"
    description="The message to write to the Log." %>

<%@ attribute name="channel" type="java.lang.String" required="false"
    description="The channel to write the log message to. Can be 'debug', 'info', 'warn' or 'error'. Default is 'info'. " %>

<%@ attribute name="exception" type="java.lang.Throwable" required="false"
    description="The exception to Log." %>


<%
    String message = (String)getJspContext().getAttribute("message");
    String channel = (String)getJspContext().getAttribute("channel");
    Throwable exception = (Throwable)getJspContext().getAttribute("exception");

    Log LOG = CmsLog.getLog("alkacon.mercury.template");

    if ((channel == null) || "info".equals(channel)) {
        LOG.info(message, exception);
    } else if ("error".equals(channel)) {
        LOG.error(message, exception);
    } else if ("warn".equals(channel)) {
        LOG.warn(message, exception);
    } else if ("debug".equals(channel)) {
        LOG.debug(message, exception);
    } else {
        LOG.info(message, exception);
    }
%>
