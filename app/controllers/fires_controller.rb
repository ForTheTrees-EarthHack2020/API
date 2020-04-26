class FiresController < ApplicationController
  # New Fire Handling
  def submit_fire
    location = params['location'].split(' ')[1].split(',')
    x = location[0]
    y = location[1]
    photo = params['picture']
    phone = params['phone']
    reporter = params['reporter']

    key = request.headers['Authorization']

    user = User.find_by(api: key)
    if user.nil?
      json_response({ "status": 'error', "error": 'Auth not valid' }, 401)
      return
    end

    file1 = Tempfile.new(['image', '.png'])
    File.open(file1.path.to_s, 'wb') do |f|
      f.write(Base64.decode64(params['picture']))
    end

    # Send code off to the Fire Analyzer
    response = `python3 predict_fire.py --file=#{file1.path}`

    if true #response.include? "yes"
      otc = rand(100_000..999_999)

      Aws.config.update(
        region: 'us-east-2',
        credentials: Aws::Credentials.new(Rails.application.credentials.dig(:aws, :access_key_id), Rails.application.credentials.dig(:aws, :secret_access_key))
      )

      s3 = Aws::S3::Client.new
      extension = '.png'
      o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
      string = (0...10).map { o[rand(o.length)] }.join
      name = "#{string}.png"
      obj = s3.put_object(
        bucket: 'for-the-trees',
        body: file1,
        acl: 'public-read',
        key: name
      )
      url = "https://for-the-trees.s3.us-east-2.amazonaws.com/#{name}"

      Fire.create(x: x, y: y, firecode: otc, image: url, userid: user.id, reporter: reporter, phone: phone)
      json_response({ "status": 'success', 'code': otc }, 201)
    else
      json_response({ "status": 'error', 'reason': 'no fire found' }, 400)
    end
  end

  # Local Fire Handling
  def local_fires
    location = params['location'].split(' ')[1].split(',')
    x = location[0]
    y = location[1]

    key = request.headers['Authorization']

    user = User.find_by(api: key)
    if user.nil?
      json_response({ "status": 'error', "error": 'Auth not valid' }, 401)
      return
    end

    fires = Fire.where(ended: nil).to_a
    good = []
    current_location = Geokit::LatLng.new(x.to_i, y.to_i)
    fires.each do |fire|
      destination = "#{fire.x},#{fire.y}"
      if current_location.distance_to(destination) < 5
        good.push ({
          "location" => destionation,
          "since" => fire.reported
        })
      end
    end

    json_response({ "status": 'success', "fires": fires }, 200)
  end

  # Fire from Code for other page
  def fire_from_code
    if params['code'].nil?
      json_response({ "status": 'error', "error": 'invalid code' }, 400)
      return
    end
    fire = Fire.find_by(firecode: params['code'])
    if fire.nil?
      json_response({ "status": 'error', "error": 'invalid code' }, 400)
      return
    end
    user = User.find_by(userid: fire.userid)

    json_response({
      "image": fire.image,
      "who": fire.reporter,
      "phone": fire.phone,
      "x": fire.x,
      "y": fire.y,
      "reported": fire.reported
      }, 200)
  end
end
