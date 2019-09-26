<%@ tag pageEncoding="UTF-8"
    display-name="obfuscate"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    import="java.nio.charset.Charset,java.util.Base64"
    description="
        Obfuscates an Email address or any other String.
        If the default type 'email' was used,
        the Sting that can be revelad using the JavaScript function 'unobfuscateString()'." %>

<%@ attribute name="text" type="java.lang.String" required="true"
    description="The String to obfuscate." %>

<%@ attribute name="type" type="java.lang.String" required="false"
    description="The Type of obfuscation.
    Possible value are 'email' (default) or 'base64'." %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%!
// select the type of obfuscation / encoding
public String obfuscate(String text, String type) {
    if ("base64".equals(type)) {
        return encodeBase64(text);
    } else if ("base64dec".equals(type)) {
        return decodeBase64(text);
    } else {
        return obfuscateEmail(text);
    }
}

// Java method to obfuscate the Email.
// The obfucated email can be revealed using the JavaScript function 'unobfuscateString()'.
public String obfuscateEmail(String email) {
    StringBuilder encoded = new StringBuilder(email.length() * 6);
    // sort the input in reverse order
    email = new StringBuffer(email).reverse().toString();
    byte[] bytes = email.getBytes(Charset.forName("UTF-8"));
    for (int j = 0; j < bytes.length; j++) {
        String hex = String.format("%02X", bytes[j]);
        if (hex.equals("40")) hex = "7b;53;43;52;41;4d;42;4c;45;7d"; // the @ symbol
        if (hex.equals("2e")) hex = "5b;53;43;52;41;4d;42;4c;45;5d"; // the . symbol
        encoded.append(hex + ";");
    }
    return encoded.toString();
}

// Base64 encoding
public String encodeBase64(String text) {
    // this requires Java8 to work
    String result = "";
    try {
        result = Base64.getEncoder().encodeToString(text.getBytes("utf-8"));
    } catch (Exception e) {
        // NOOP
    }
    return result;
}


//Base64 encoding (file save)
public String decodeBase64(String text) {
    String result = "";
    try {
        result = new String(Base64.getDecoder().decode(text.getBytes("utf-8")));
    } catch (Exception e) {
        // NOOP
    }
    return result;
}
%>

<%= obfuscate((String)getJspContext().getAttribute("text"), (String)getJspContext().getAttribute("type")) %>
