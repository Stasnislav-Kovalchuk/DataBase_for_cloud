package ua.edu.db.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ua.edu.db.model.Author;
import ua.edu.db.repository.AuthorRepository;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/authors")
public class AuthorController {
    private final AuthorRepository authorRepository;

    public AuthorController(AuthorRepository authorRepository) {
        this.authorRepository = authorRepository;
    }

    @GetMapping
    public List<Author> getAll() {
        return authorRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Author> getById(@PathVariable("id") Long id) {
        return authorRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Author> create(@RequestBody Author author) {
        Author saved = authorRepository.save(author);
        return ResponseEntity.created(URI.create("/api/authors/" + saved.getId())).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Author> update(@PathVariable("id") Long id, @RequestBody Author author) {
        return authorRepository.findById(id)
                .map(existing -> {
                    existing.setName(author.getName());
                    existing.setBirthYear(author.getBirthYear());
                    return ResponseEntity.ok(authorRepository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        if (!authorRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        authorRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}



