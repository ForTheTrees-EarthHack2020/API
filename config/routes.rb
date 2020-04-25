Rails.application.routes.draw do
  post 'login', to: 'authorization#login'
  post 'register', to: 'authorization#register'
end
