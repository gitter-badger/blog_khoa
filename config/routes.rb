Rails.application.routes.draw do

  resources :email_subscribes, only: [:index, :create]
  resources :comments, only: [:create]

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :articles, only: [:index, :show]
  devise_for :users

  namespace :admin do
    resources :articles
  end

  get '/search(/category/:category_name)' => 'articles#search', as: :seo_search

  get 'feed', to: 'articles#index', defaults: {format: 'rss'}, as: :feed
  get '/(page/:page)' => 'articles#index', as: :index_seo

  root 'articles#index'

  namespace :v2_admin do
    root 'homes#index'
    resources "homes"
  end

  get '*a', to: 'errors#error_404'
end
