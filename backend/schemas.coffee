mongoose = require('mongoose')
mongoose.connect('mongodb://localhost/agora')

Schema = mongoose.Schema

User = new Schema({
  username: String,  
  nickname: String,
  email: String,
  avatar: String
})
mongoose.model('User', User)

Post = new Schema({
  username: String,
  source: String
})
mongoose.model('Post', Post)

Thread = new Schema({
  title: String,
  posts: [Post]
})
mongoose.model('Thread', Thread)

Category = new Schema({
  name: String,
  description: String,
  threads: [Thread]
})
mongoose.model('Category', Category)

