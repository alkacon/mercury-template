<%@page import="java.util.Map"%>
<%
String uri = request.getParameter("uri");
boolean first = true;
for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
    String name = entry.getKey();
    String value = entry.getValue()[0];
    if (name.equals("uri")) {
    	continue;
    } else if (first) {
    	uri += "?" + name;
    	first = false;
    } else {
        uri += "&" + name;
    }
    if (value != "") {
    	uri += "=" + value;
    }
}
response.setStatus(301);
response.sendRedirect(uri);
%>