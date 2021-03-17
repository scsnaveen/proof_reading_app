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
	get 'post/invoice'
	post 'post/accept'
	get 'payments/index'
	post 'post/rejected_request'
	get 'post/total_amount'
	get 'payments/new'
	post 'payments/create'
	post 'payments/fine'
	get 'payments/show'
	get 'payments/fine'
	get 'payments/coupon_verification'
	post 'payment/admin_payment'
	post 'transaction_histories/create'
	get 'transaction_histories/new'
	get 'transaction_histories/index'
	get 'deposits/new'
	post 'deposits/create'
	get 'deposits/update'
	get 'deposits/index'
	get 'payments/tot_amount'
	delete 'deposits/destroy'
	get 'payments/admin_payments'
	resources :coupons

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
