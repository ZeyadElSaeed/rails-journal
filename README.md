This documentation provides an overview of the Blog Application, which consists of a RESTful API built using Ruby on Rails, MySQL, Sidekiq, and Redis. The API allows users to authenticate, create, manage posts, and add comments. The system includes features such as user authentication via JWT, CRUD operations for posts and comments, and automatic deletion of posts after 24 hours. The application is fully containerized using Docker for easy deployment.

---

## Table of Contents

1. [Technologies](#1-technologies)
2. [Project Setup](#2-project-setup)
3. [API Endpoints](#3-api-endpoints)
4. [Authentication](#4-authentication)
5. [Post CRUD Operations](#5-post-crud-operations)
6. [Comments](#6-comments)
7. [Post Deletion](#7-post-deletion)
8. [Background Jobs](#8-background-jobs)

---

## 1. Technologies

The Blog Application is built with the following technologies:

- **Ruby on Rails**: Web framework used to build the RESTful API.
- **MySQL**: Database used for storing user, post, and comment data.
- **Sidekiq**: Background job processing tool used to schedule and execute tasks, such as post deletion.
- **Redis**: In-memory data store used by Sidekiq for job management.
- **Docker**: Containerization platform for packaging and running the application.
- **JWT (JSON Web Token)**: Authentication method for securing API endpoints.

---

## 2. Project Setup

### Prerequisites:

Ensure the following are installed:

- Docker
- Docker Compose

### Steps:

- **Clone the Repository:**

```bash
   git clone https://github.com/ZeyadElSaeed/rails-journal.git
   cd rails-journal
```

- **Build and Start the Docker Containers:**

```bash
docker-compose up --build
```

- **Access the Application:**
  - Once the containers are up, the app base URL will be available at: `http://localhost:3000`

---

## 3. API Endpoints

Validations are added to models and global exceptions handlers are used to send unified failure responses such as

```bash
{ errors: "#{e.record.errors.full_messages}" }, status: :unprocessable_entity

{ error: "Record not found: #{e.model}" }, status: :not_found

{ error: "Missing parameter: #{e.param}" }, status: :bad_request
```

### Base URL:

`http://localhost:3000/api/v1`

### Authentication:

- **POST /users**: Create a new user.
- **POST /auth/login**: Authenticate user and return a JWT token for subsequent requests.

### Post Operations:

- **GET /posts**: Get all posts.
- **GET /posts/:id**: Get a specific post.
- **POST /posts**: Create a new post with tags.
- **PUT /posts/:id**: Update an existing post.
- **DELETE /posts/:id**: Delete a post.

### Comment Operations:

- **POST /posts/:id/comments**: Add a comment to a post.
- **PUT /posts/:post_id/comments/:id**: Edit a comment.
- **DELETE /posts/:post_id/comments/:id**: Delete a comment.

### sidekiq:

- **GET /sidekiq**: Show the dashboard of sidekiq.

---

## 4. Authentication

The application uses JWT for authentication. All users must authenticate using their email and password to receive a token, which will be used to authorize access to protected endpoints.

### Sign Up

- **Endpoint**: `POST /users`
- **Description**: Create a new user.
- **Request Body**:

```bash
{
  "user": {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "password123",
    "image": "http://example.com/profile.jpg"
  }
}
```

- **Response**:

```bash
{
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "image": "http://example.com/profile.jpg"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyfQ.0NAXbbVzeMaKZAl8HdOq3JcgIDf5xpGF2rkg5frw6FE"
}
```

### Login

- **Endpoint**: `POST /auth/login`
- **Description**: login as existing user.
- **Request Body**:

```bash
{
  "email": "john.doe@example.com",
  "password": "password123"
}
```

- **Response**:

```bash
{
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "image": "http://example.com/profile.jpg"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.ETUYUOkmfnWsWIvA8iBOkE2s1ZQ0V_zgnG_c4QRrhbg"

}
```

---

## 5. Post CRUD Operations

### Create a Post

- **Endpoint**: `POST /posts`
- **Description**: Create a new post.
- **Request Body**:

```bash
{
  "title": "Post Title",
  "body": "Post content here",
  "tags": ["tag1", "tag2"]
}
```

- **Response**:

```bash
{
    "id": 1,
    "title": "Post Title",
    "body": "Post content here",
    "author_id": 1,
    "created_at": "2024-12-19T14:55:28.836Z",
    "updated_at": "2024-12-19T14:55:28.836Z",
    "tags": [
        {
            "id": 1,
            "name": "tag1",
            "created_at": "2024-12-19T13:39:36.822Z",
            "updated_at": "2024-12-19T13:39:36.822Z"
        },
        {
            "id": 2,
            "name": "tag2",
            "created_at": "2024-12-19T13:39:36.822Z",
            "updated_at": "2024-12-19T13:39:36.822Z"
        }
    ],
  "comments": []
}
```

### Update a Post

- **Endpoint**: `PUT /posts/:id`
- **Description**: Update an existing post (author-only).
- **Request Body**:

```bash
{
  "title": "Updated Title",
  "body": "Updated content",
  "tags": ["new_tag"]
}

```

- **Response**:

```bash
{
    "id": 1,
    "title": "Updated Title",
    "body": "Updated content",
    "author_id": 1,
    "created_at": "2024-12-19T14:55:28.836Z",
    "updated_at": "2024-12-19T15:55:28.836Z",
    "tags": [
        {
            "id": 3,
            "name": "new_tag",
            "created_at": "2024-12-19T13:39:36.822Z",
            "updated_at": "2024-12-19T13:39:36.822Z"
        }
    ],
  "comments": []
}
```

### Delete a Post

- **Endpoint**: `DELETE /posts/:id`
- **Description**: Delete a post (author-only).
- **Response**:

```bash
{  }
```

---

## 6. Comments

### Add a Comment to a Post

- **Endpoint**: `POST /posts/{:post_id}/comments`
- **Description**: Add a comment to a post.
- **Request Body**:

```bash
{
  "body": "This is a comment."
}
```

- **Response**:

```bash
{
    "id": 1,
    "body": "This is a comment.",
    "user_id": 1,
    "post_id": 1,
    "created_at": "2024-12-19T15:02:29.062Z",
    "updated_at": "2024-12-19T15:02:29.062Z"
}
```

### Edit a Comment

- **Endpoint**: `PUT /posts/{:post_id}/comments/:id`
- **Description**: Add a comment to a post.
- **Request Body**:

```bash
{
  "body": "Updated comment."
}
```

- **Response**:

```bash
{
    "id": 1,
    "body": "Updated comment.",
    "user_id": 1,
    "post_id": 1,
    "created_at": "2024-12-19T15:02:29.062Z",
    "updated_at": "2024-12-19T15:02:29.062Z"
}
```

### Delete a Comment

- **Endpoint**: `DELETE /posts/{:post_id}/comments/:id`
- **Description**: Delete a comment (author-only).
- **Response**:

```bash
{ }
```

---

## 7. Post Deletion

- **Automatic Deletion**: Posts are automatically deleted after 24 hours of creation. This is handled by a background job using Sidekiq and Redis.

---

## 8. Background Jobs

The application uses **Sidekiq** to handle background jobs for tasks like post deletion.

### Post Deletion Job

A job is scheduled to run 24 hours after a post is created. This job will delete the post from the database.
