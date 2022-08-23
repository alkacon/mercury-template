<%@ tag pageEncoding="UTF-8"
    display-name="out"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Parses hex colors to RGB." %>

<%@ attribute name="value" type="java.lang.String" required="true"
    description="The color value to parse." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
   String value = (String)getJspContext().getAttribute("value");
   String result = "";
   if (value.startsWith("#") && (value.length()==4) || (value.length()==7)) {
       try {
           String rs, gs, bs;
           if (value.length()==4) {
               rs = value.substring(1, 2);
               rs = rs + rs;
               gs = value.substring(2, 3);
               gs = gs + gs;
               bs = value.substring(3, 4);
               bs = bs + bs;
           } else {
               rs = value.substring(1, 3);
               gs = value.substring(3, 5);
               bs = value.substring(5, 7);
           }
           int r = Integer.valueOf(rs, 16);
           int g = Integer.valueOf(gs, 16);
           int b = Integer.valueOf(bs, 16);
           result = "" + r + "," + g + "," + b;
       } catch (Exception e) {
           // ignore
       }
   }
   getJspContext().setAttribute("result", result);
%>
<c:out value="${result}" />


