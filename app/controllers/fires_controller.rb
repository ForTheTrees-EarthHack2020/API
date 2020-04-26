class FiresController < ApplicationController
  # New Fire Handling
  def new_fire
    location = params['location']
    photo = params['photo']
    phone = params['phone']
    reporter = params['reporter']

    key = request.headers['Authorization']

    user = User.find_by(api: key)
    if user.nil?
      json_response({ "error": 'Auth not valid' }, 401)
      return
    end

    # Send code off to the Fire Analyzer
  end
end
