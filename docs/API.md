
# API

### Log in

POST `/login`

Request:

    {
      username: 'The username',
      password: 'The password's SHA-1 hash'
    }
    
Response:

    {
      result        : 'success',
      session_token : 'The authentication token',
      user          : 'The full record of the authenticated user'
    }
      or
    {
      result: 'failure'
    }
    
See `/user/:username` for the structure of a User object

### Get the categories list

GET `/categories?token=$token`

Response:

    [ {
      _id         : 'The category's id',
      slug        : 'The category's slug'
      title       : 'The category's title'
      description : 'The category's description'
    } ]

### Get a single category

GET `/category/:slug?token=$token`

Response:

    {
      _id         : 'The category's id,
      name        : 'The category's name,
      description : 'The category's description',
      threads     : [ Thread ]
    }
    
See `/thread/:tid?token=$token` for structure of a Thread object.

### Get a single thread by its id

GET `/thread/:tid?token=$token`

Response:

    {
      title : 'The thread's title',
      posts : [ Post ]
    }
    
    Post = {
      username : 'The username of the user this post was wrote by'
      source   : 'The post's Markdown source'
      date     : 'The date/time at which this post was created'
    }

### Get a single user by its username

GET `/user/:username?token=$token`
    
Response:

    {
      error   : 'not found',
    }
      or
    {
      username  : 'The user's username',
      nickname  : 'The user's nickname',
      email     : 'The user's email',
      joindate  : 'The date at which the user joined',
      posts     : 'The number of posts by this user',
      slogan    : 'The user's slogan',
      avatar    : 'The URL to the user's avatar'
    }

### Create a new thread

POST `/new-thread`

Request:
    
    {
      username : 'username',
      title    : 'Thread title',
      source   : 'First post's Markdown source',
      token    : 'Authentication token'
    }
    
Response:

    {
      result  : 'success' || 'error',
      id      : 'The new thread's id',
      error   : 'An error message, only if an error occured'
    }

### Post a reply to a thread

POST `/post-reply`

Request

    {
      tid      : 'The id of the thread to reply into'
      username : 'The name of the user who wrote the reply'
      source   : 'The Markdown source of the reply'
      token    : 'The authentication token'
    }
    
Response

    {
      result: 'success',
      date: 'The date at which the replay was posted'
    }
      or
    {
      result: 'error'
    }

### Log out

POST `/logout`

Request:

    {
      token : 'The authentication token'
    }
    
Response:

    {
      result : 'success'
    }
