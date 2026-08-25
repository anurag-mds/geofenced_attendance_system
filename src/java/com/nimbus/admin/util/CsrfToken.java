package com.nimbus.admin.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public final class CsrfToken {

    public static final String ATTRIBUTE = CsrfToken.class.getName() + ".value";
    public static final String PARAMETER = "csrfToken";

    private static final SecureRandom RANDOM = new SecureRandom();

    private CsrfToken() {
    }

    public static String getToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        Object existing = session.getAttribute(ATTRIBUTE);
        if (existing instanceof String token && !token.isBlank()) {
            return token;
        }
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(ATTRIBUTE, token);
        return token;
    }

    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object expectedValue = session.getAttribute(ATTRIBUTE);
        String submittedValue = request.getParameter(PARAMETER);
        if (!(expectedValue instanceof String expected) || submittedValue == null) {
            return false;
        }
        return MessageDigest.isEqual(expected.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                submittedValue.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }
}