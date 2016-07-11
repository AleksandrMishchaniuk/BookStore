Rails.application.routes.draw do

  root 'pages#home'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users

  namespace :order do
    resource :cart, only: [:show, :update]
    resource :addresses, only: [:edit, :update]
    resource :delivery, only: [:edit, :update]
    resource :payment, only: [:edit, :update]
    get 'confirm' => 'order#confirm', as: :confirm
    post 'confirm' => 'order#to_progress', as: :in_progress
    get 'order' => 'order#show', as: :order
  end

  namespace :shop do
    resources :categories, only: :show
    resources :books, only: [:index, :show] do
      resources :reviews, only: [:new, :create]
    end
  end

  namespace :user do
    resources :orders, only: [:index, :show]
    resource :settings, only: [:edit] do
      member do
        post 'billing_address'
        post 'shipping_address'
        post 'email'
        post 'password'
        post 'remove_user'
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
