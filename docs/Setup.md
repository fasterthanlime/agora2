
# Setup

## Install required packages

### OS X

#### Install Git

`brew install git`

#### Install MongoDB

`brew install mongodb`

#### Install NVM

`git clone git://github.com/creationix/nvm.git ~/.nvm`

#### Install Node v0.5

`nvm install v0.5.5`

#### Install NPM

`curl http://npmjs.org/install.sh | sh`

#### Install Node packages

`npm install -g coffee-script`  
`npm install sha1 mongoose bcrypt`

## Clone the repository

`git clone git://github.com/nddrylliog/agora2.git`

## Set up the app

`cd agora2`  
`coffee -c .`  
`mongod --dbpath=data/ &`  
`node backend/populate.js`  
`node backend/server.js`  
`open http://localhost:3000`

Login with bluesky:bluesky