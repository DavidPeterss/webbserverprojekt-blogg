require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:index)
end

get('/loggedin') do
    bloggPosts = db.execute("SELECT * FROM bloggposts")
    bloggPosts = bloggPosts.reverse
    slim(:loggedin)
end

get('/register') do
    slim(:register)
end

get('/failed') do
    slim(:failed)
end

get('/posts') do
    slim(:posts,locals:{bloggPosts:bloggPosts})
end

post('/login') do
    db = SQLite3::Database.new("db/användare.db")
    db.results_as_hash = true
    user_password = db.execute("SELECT Id, Password FROM users WHERE Username = ?", params["username"])
    hashed_pass = BCrypt::Password.new(user_password[0]["Password"])
    
    if hashed_pass == params["password"]
         session[:user] = hashed_pass
         
    else
        redirect('/failed')
    end
    session[:userId] = db.execute("SELECT Id FROM users WHERE Username = ?", params["username"])
    redirect('/loggedin')
end

post('/register') do
    db = SQLite3::Database.new("db/användare.db")
    db.results_as_hash = true
    hashed_pass = BCrypt::Password.create(params["password"])

    db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
    redirect('/')  
end

post('/text') do
    db = SQLite3::Database.new("db/användare.db")
    db.execute("INSERT INTO bloggposts(Posts, Header, Id) VALUES(?, ?, ?)", params["bloggpost"], params["rubrik"], session[:userId])
    redirect('/posts')
end

