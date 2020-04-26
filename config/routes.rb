Rails.application.routes.draw do
  get 'login', to: 'authorization#login'
  post 'login', to: 'authorization#login'
  get 'register', to: 'authorization#register'
  post 'register', to: 'authorization#register'

  get 'fire/local', to: 'fires#local_fires'
  post 'fire/submit', to: 'fires#submit_fire'

  get 'fire/code', to: 'fires#fire_from_code'
end
