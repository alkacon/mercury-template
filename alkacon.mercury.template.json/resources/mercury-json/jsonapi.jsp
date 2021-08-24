<%
String uri = request.getParameter("uri");
response.setStatus(301);
response.sendRedirect(uri);
%>