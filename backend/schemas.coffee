mongoose = require('mongoose')
mongoose.connect('mongodb://localhost/agora')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

User = new Schema({
  username: String
  nickname: String
  email: String
  joindate: Number
  posts: Number
  slogan: String
  avatar: String
  sha1: String
})
mongoose.model('User', User)

Post = new Schema({
  thread: ObjectId
  user: ObjectId
  source: String
  date: Number
})
mongoose.model('Post', Post)

Thread = new Schema({
  category: ObjectId
  title: String
  posts: [ObjectId]
})
mongoose.model('Thread', Thread)

Category = new Schema({
  name: String
  description: String
  threads: [ObjectId]
})
mongoose.model('Category', Category)

Token = new Schema({
  value: String
  username: String
  expiration: Number
})
mongoose.model('Token', Token)



