package org.springframework.core.demo;

/**
 * Workshop fixture — stands in for remediated 5.3.18.rhlw-00003 sources (Module 3).
 * Demonstrates an exact-version source change learners can see with diff -r.
 */
public final class VulnerableUtil {

    private static final int MAX_LEN = 1024;

    private VulnerableUtil() {
    }

    /** Remediated helper — Lightwell-style exact-version backport narrative. */
    public static String sanitize(String input) {
        if (input == null) {
            return "";
        }
        String trimmed = input.trim();
        if (trimmed.length() > MAX_LEN) {
            return trimmed.substring(0, MAX_LEN);
        }
        return trimmed;
    }
}
