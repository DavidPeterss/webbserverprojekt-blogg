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
    slim(:loggedin)
end

get('/register') do
    slim(:register)
end

get('/failed') do
    slim(:failed)
end



post('/login') do
    db = SQLite3::Database.new("db/användare.db")
    db.results_as_hash = true
    result = db.execute("SELECT Id, Password FROM users WHERE Username = ?", params["username"])
    user = result.first
    hashed_pass = BCrypt::Password.new(user["Password"])
    
    if hashed_pass == params["password"]
         session[:username] = params["username"]
         session[:userId] = user["Id"]
         
    else
        redirect('/failed')
    end
    redirect('/loggedin')
end

post('/register') do
    db = SQLite3::Database.new("db/användare.db")
    db.results_as_hash = true
    hashed_pass = BCrypt::Password.create(params["password"])

    db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
    redirect('/')  
end


get('/posts') do
    db = SQLite3::Database.new("db/användare.db")
    db.results_as_hash = true
    @bloggPosts = db.execute("SELECT * FROM bloggposts ORDER BY TimeStamp DESC LIMIT 5")
    slim(:posts, locals:{bloggPosts:bloggPosts})
end

post('/text') do
    db = SQLite3::Database.new("db/användare.db")
    db.execute("INSERT INTO bloggposts(Posts, Header, UserId) VALUES(?, ?, ?)", params["bloggpost"], params["rubrik"], session[:userId])
    redirect('/posts')
end

