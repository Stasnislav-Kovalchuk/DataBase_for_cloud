package ua.edu.db.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ua.edu.db.model.Author;

public interface AuthorRepository extends JpaRepository<Author, Long> {
}



