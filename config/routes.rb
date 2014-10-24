OpenFarm::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: {
      registrations: "registrations"
    }
  devise_scope :users do
    get 'users/finish' => 'users#finish'
    put 'users' => 'users#update'
  end
  # Accept searches via POST and GET so that users can search with forms -or-
  # shareable link.

  scope '(:locale)', locale: /en|nl/ do
    root to: 'high_voltage/pages#show', id: 'home'
    post '(:locale)/crop_search' => 'crop_searches#search',
         as: :crop_search_via_post
    get '(:locale)/crop_search' => 'crop_searches#search',
        as: :crop_search_via_get
    resources :users
    resources :crops
    resources :guides
    resources :stages
    resources :requirements
    resources :gardens
  end

  get 'announcements/hide', to: 'announcements#hide'

  namespace :api, defaults: {format: 'json'} do
    get '/aws/s3_access_token' => 'aws#s3_access_token'
    resources :crops, only: [:index, :show]
    resources :users, only: [:show]
    resources :guides, only: [:create, :show, :update]
    resources :requirement_options, only: [:index]
    resources :stage_options, only: [:index]
    resources :stages, only: [:create, :show, :update]
    resources :requirements, only: [:create, :show, :update, :destroy]
    # TODO Figure out why I can't use a singular resource route here.
    post 'token', to: 'tokens#create'
    delete 'token', to: 'tokens#destroy'
  end

  get '/:locale' => 'high_voltage/pages#show', id: 'home'
end
