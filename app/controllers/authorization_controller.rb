# API Requests handling Authentication and Authorization
class AuthorizationController < ApplicationController
  # Register method
  def register
    # Define variables from the request
    username = params['username']
    password = params['password']

    # Check to see if username exists
    user_check = User.find_by(username: username)
    unless user_check.nil?
      json_response({ "status": "error", "reason": "username already exists" }.as_json, 400)
      return
    end

    # Hash the password, we're not insecure.
    hashed_password = Password.create(password)

    # Now we add stuff to database and return a nice API key for the app to use
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    key = (0...50).map { o[rand(o.length)] }.join

    User.create(username: username, password: hashed_password, api: key)

    json_response({ "status": "success", "key": key }.as_json, 201)
  end

  # Login user method, returns key for the app
  def login
    # Parameters we store for later
    username = params['username']
    password = params['password']

    # Check if username exists, if it doesn't, tell the user they're doing it wrong, not how.
    user = User.find_by(username: username)
    if user.nil? # If there are no matches.
      json_response({ "error": "Invalid credentials" }.as_json, 401)
      return
    end

    # If the password matches
    if user.password == params['password']
      key = user.api
      output = {
        "success": true,
        "key": key,
        "user": {
          "id": user.id
        }
      }
      json_response(output.as_json, 200)
    else
      json_response({"error": "Invalid credentials"}.as_json, 401)
      return
    end
  end
end
