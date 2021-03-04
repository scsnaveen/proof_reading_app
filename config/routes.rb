Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins, controllers: { 
  	registrations: 'admins/registrations', 
  	sessions: 'admins/sessions'
  }
	devise_scope :admin do
		get 'admins/sign_out', to: 'admins/sessions#destroy'
	end
  get 'post/new'
  post 'post/create'
  get 'post/index'
  devise_for :users, controllers: { 
  	registrations: 'users/registrations', 
  	sessions: 'users/sessions'
  }
	root 'welcome#index'
	devise_scope :user do
		get 'users/sign_out', to: 'users/sessions#destroy'
	end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
