package com.nimbus.admin.util;

public final class HtmlEscaper {

    private HtmlEscaper() {
    }

    public static String text(Object value) {
        return escape(value == null ? "" : String.valueOf(value));
    }

    public static String jsString(Object value) {
        String text = value == null ? "" : String.valueOf(value);
        return text.replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("</", "<\\/");
    }

    private static String escape(String value) {
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}