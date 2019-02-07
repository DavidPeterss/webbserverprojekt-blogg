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

post('/register') do
    db = SQLite3::Database.new("db/användare.db")
    db.results_as_hash = true
    hashed_pass = BCrypt::Password.create(params["password"])

    db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
    redirect('/')  
end