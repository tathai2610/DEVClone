require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users 

  root "posts#index"

  resources :users, only: [:show, :edit, :update] do
    resources :follows, only: [:create, :destroy]
  end

  # show list of queued posts to admin
  get 'posts/queue', to: 'posts#queue'
  # show list of drafts to admin 
  get 'posts/drafts', to: 'posts#drafts'

  # show all posts of the current user
  get 'my_posts', to: "posts#my_posts"

  resources :posts do 
    resources :comments, except: :new, module: :posts
    resources :likes, only: [:create, :destroy], module: :posts
  end

  resources :comments do
    resources :comments, module: :comments
    resources :likes, only: [:create, :destroy], module: :comments
  end

  get '/tags/:id', to: "tags#show", as: "tag"
  mount Sidekiq::Web => '/sidekiq'
end
