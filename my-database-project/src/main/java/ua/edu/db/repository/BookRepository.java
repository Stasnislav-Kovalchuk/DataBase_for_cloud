package ua.edu.db.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ua.edu.db.model.Book;

public interface BookRepository extends JpaRepository<Book, Long> {
}



