Rails.application.routes.draw do
  get 'login', to: 'authorization#login'
  post 'login', to: 'authorization#login'
  get 'register', to: 'authorization#register'
  post 'register', to: 'authorization#register'
end
