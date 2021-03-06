Rails.application.routes.draw do

  get 'class/PagesController'

  root :to => "profiles#home"

  # links from main page: not based on game data but piggybacks off of
  get 'archives' => 'profiles#archives', as: :archives
  get 'howtoplay' => 'profiles#howtoplay', as: :howtoplay

  # mapping games resources, in standard RESTful format
  resources :games, only: [:show, :new, :create, :update, :destroy]

  # game playing link: /games/1/play
  get 'games/:id/play' => 'games#play', as: :play

  # method for submitting sets: /games/1/play_cards
  put 'games/:id/play_cards' => 'games#play_cards', as: :play_cards

  # game archive link for finished games: /games/1/archive
  get 'games/:id/archive' => 'games#archive', as: :archive

  # Ajax updater link: /games/1/refresh
  get 'games/:id/field.:format' => 'games#get_field', as: :get_field

  # OAuth based routes
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]


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
