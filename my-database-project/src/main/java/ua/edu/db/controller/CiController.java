package ua.edu.db.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/ci")
@Tag(name = "CI", description = "Тестові ендпоїнти для перевірки GitHub Actions")
public class CiController {

    @GetMapping("/ping")
    @Operation(summary = "Ping для CI", description = "Повертає просте повідомлення для перевірки деплою")
    public ResponseEntity<String> ping() {
        return ResponseEntity.ok("pong");
    }
}


