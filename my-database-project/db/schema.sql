-- Schema for authors and books
CREATE TABLE IF NOT EXISTS authors (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  birth_year INT
);

CREATE TABLE IF NOT EXISTS books (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  year_published INT,
  author_id BIGINT NOT NULL,
  CONSTRAINT fk_books_authors FOREIGN KEY (author_id)
    REFERENCES authors(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);



