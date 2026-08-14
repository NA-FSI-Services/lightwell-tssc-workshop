package org.springframework.core.demo;

/**
 * Workshop fixture — stands in for upstream 5.3.18 sources (Module 3 offline demo).
 * Not production Spring Framework code.
 */
public final class VulnerableUtil {

    private VulnerableUtil() {
    }

    /** Intentionally simplistic "vulnerable" helper for source-diff labs. */
    public static String sanitize(String input) {
        // Missing length / charset checks in this demo stub
        return input == null ? "" : input.trim();
    }
}
