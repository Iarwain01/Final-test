-- Create a table for authors
CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Create a table for books
CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author_id INTEGER REFERENCES authors(id)
);

-- Create a table for clients
CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  access_token VARCHAR(255) UNIQUE NOT NULL -- this is the token used for authentication
);

-- Create a table for book-client relationship
CREATE TABLE book_client (
  book_id INTEGER REFERENCES books(id),
  client_id INTEGER REFERENCES clients(id),
  borrowed_at DATE NOT NULL,
  returned_at DATE,
  PRIMARY KEY (book_id, client_id)
);

-- Add a book
INSERT INTO books (title, author_id) VALUES ('The Catcher in the Rye', 1);

-- Edit the book's title and author
UPDATE books SET title = 'The Catcher in the Rye: Revised Edition', author_id = 2 WHERE id = 1;

-- Retrieve a list of books with filtering option for the first letter of the book's title and author
SELECT b.title, a.name FROM books b
JOIN authors a ON b.author_id = a.id
WHERE b.title LIKE 'T%' AND a.name LIKE 'J%';

-- Add multiple books by the same author
INSERT INTO books (title, author_id) VALUES 
('The Fault in Our Stars', 2),
('Looking for Alaska', 2),
('Paper Towns', 2);

-- Add an author
INSERT INTO authors (name) VALUES ('George Orwell');

-- Create a client
INSERT INTO clients (name, email, access_token) VALUES ('Al-Mamun', 'md.4lmamun@gmail.com', 'abcdef12345');

-- Retrieve a list of books borrowed by the client
-- This query assumes that the access token is passed as a parameter
SELECT b.title, b.author_id, bc.borrowed_at, bc.returned_at FROM books b
JOIN book_client bc ON b.id = bc.book_id
JOIN clients c ON bc.client_id = c.id
WHERE c.access_token = $1;

-- Link a client to a book (client borrowed the book)
-- This query assumes that the book id and the access token are passed as parameters
INSERT INTO book_client (book_id, client_id, borrowed_at) 
SELECT $1, c.id, '2023-11-12' FROM clients c
WHERE c.access_token = $2;

-- Unlink a client from a book
-- This query assumes that the book id and the access token are passed as parameters
UPDATE book_client SET returned_at = '2023-11-30' 
WHERE book_id = $1 AND client_id = (SELECT id FROM clients WHERE access_token = $2);