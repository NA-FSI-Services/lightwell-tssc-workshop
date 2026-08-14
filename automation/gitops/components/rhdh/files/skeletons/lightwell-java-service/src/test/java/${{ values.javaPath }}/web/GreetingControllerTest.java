package ${{ values.javaPackage }}.web;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(GreetingController.class)
class GreetingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void greetingReturnsMessage() throws Exception {
        mockMvc.perform(get("/api/greeting").param("name", "Workshop"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Hello, Workshop!"))
                .andExpect(jsonPath("$.service").value("${{ values.name }}"));
    }
}
