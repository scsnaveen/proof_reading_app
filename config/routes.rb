Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins, controllers: { 
  	registrations: 'admins/registrations', 
  	sessions: 'admins/sessions'
  }
	devise_scope :admin do
		get 'admins/sign_out', to: 'admins/sessions#destroy'
	end
	get 'post/show'
	get 'post/new'
	post 'post/create'
	get 'post/index'
	get 'post/reject'
	post 'post/accept'
	get 'payments/index'
	post 'post/rejected_request'
	get 'post/total_amount'
	get 'payments/new'
	post 'payments/create'
	post 'payments/fine'
	get 'payments/fine'
	get 'payments/coupon_verification'
	resources :coupons
	# get 'coupons/index'
	# get 'coupons/new'
	# post 'coupons/create'

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
