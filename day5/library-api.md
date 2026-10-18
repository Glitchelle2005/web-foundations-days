# Library Books API

Base path: `/books`

## Endpoints

- **List books**
  - Method and path: `GET /books`
  - Description: Returns the collection of books.
  - Success status: `200 OK`

- **Get one book**
  - Method and path: `GET /books/{id}`
  - Description: Returns the book with the specified ID.
  - Success status: `200 OK`

- **Create a book**
  - Method and path: `POST /books`
  - Description: Creates a book and returns the created resource.
  - Example request body:
    ```json
    {
      "title": "Kindred",
      "author": "Octavia E. Butler",
      "publishedYear": 1979
    }
    ```
  - Success status: `201 Created`

- **Update a book**
  - Method and path: `PUT /books/{id}`
  - Description: Replaces the details of the book with the specified ID.
  - Example request body:
    ```json
    {
      "title": "Kindred",
      "author": "Octavia E. Butler",
      "publishedYear": 1979
    }
    ```
  - Success status: `200 OK`

- **Delete a book**
  - Method and path: `DELETE /books/{id}`
  - Description: Deletes the book with the specified ID.
  - Success status: `204 No Content`

- **List books by author**
  - Method and path: `GET /books?author={author}`
  - Description: Returns books whose author matches the `author` query parameter.
  - Example request: `GET /books?author=Octavia%20E.%20Butler`
  - Success status: `200 OK`

## Error codes

- `400 Bad Request` — The request body is invalid or is missing a required field when creating or updating a book.
- `404 Not Found` — The requested book ID does not exist, for example with `GET /books/9999`.
