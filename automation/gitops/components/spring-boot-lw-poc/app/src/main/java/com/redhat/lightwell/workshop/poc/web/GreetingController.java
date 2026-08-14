package com.redhat.lightwell.workshop.poc.web;

import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@Tag(name = "Greetings", description = "Sample API for the Lightwell TSSC workshop PoC")
public class GreetingController {

    @Value("${lightwell.stream:validated}")
    private String lightwellStream;

    @GetMapping("/api/greeting")
    @Operation(summary = "Return a greeting", description = "Demonstrates a layered sample API used with LWN Maven streams")
    public Map<String, String> greeting(
            @RequestParam(name = "name", defaultValue = "Lightwell") String name) {
        String safeName = StringUtils.defaultIfBlank(name, "Lightwell");
        return Map.of(
                "message", "Hello, " + safeName + "!",
                "lightwellStream", lightwellStream,
                "service", "spring-boot-lw-poc");
    }

    @GetMapping("/api/healthz")
    @Operation(summary = "Liveness-style health probe")
    public Map<String, String> healthz() {
        return Map.of("status", "ok");
    }
}
