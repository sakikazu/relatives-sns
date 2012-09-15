ADan4::Application.routes.draw do
  mount RailsAdmin::Engine => '/adamin', :as => 'rails_admin'

  devise_for :admin_users

  resources :members do
    collection do
      get 'edit'
      get 'edit_ex'
      get 'map'
      get 'all'
      get 'login_history'
      put 'update_ex'
    end
  end

  match 'blogs/user/:username' => 'blogs#index', as: :blogs_by_user
  resources :blogs do
    collection do
      get :index_mobile
      get :everyone_mobile
      get :show_mobile
      get :new_mobile
      get :edit_mobile
      get :destroy_comment_confirm_mobile
      get :destroy_confirm_mobile
    end

    # member do
      # get 'new_images'
      # post 'create_images'
      # post 'symbol_images'
    # end
    # collection do
      # delete 'destroy_image'
    # end
    resources :blog_comments, only: [:create, :destroy]
  end

  resources :movies do
    collection do
      post :create_comment
      delete :destroy_comment
    end
  end

  resources :albums do
    collection do
      get :title_index
    end
    member do
      get :download
    end
    resources :album_comments, only: [:create, :destroy]
    resources :photos do
      member do
        get 'slideshow'
        put 'update_from_slideshow'
      end
      resources :photo_comments, only: [:create, :destroy]
    end
  end

  # match "/albums/upload_complete/:id" => "albums#upload_complete", :as => :album_up_comp

  match "/boards/destroy_comment/:id" => "boards#destroy_comment", :as => :destroy_comment_board
  resources :boards do
    collection do
      post :create_comment
      post :create_comment_mobile
      get :index_mobile
    end
    member do
      get :show_mobile
    end
  end

  resources :histories do
    collection do
      get :new_comment
      post :create_comment
      delete :destroy_comment
    end
  end

  resources :others do
    collection do
      get :old_site
      get :he
    end
  end

  resources :nices, :only => [:create, :destroy] do
    collection do
      get :recent
      get :ranking
      get :donice
      get :wasnice
    end
  end
  match "nices" => "nices#recent"

  match "/mutters/user/:user_id" => "mutters#all", :as => :mutter_by_user
  resources :mutters do
    collection do
      get :graph
      get :update_allview
      get :update_check
      get :update_disp
      get :update_history_all
      get :all
      get :search
      get :album_info
      get :new_from_mail
      post :create_from_mail
      get :slider_update
      get :celebration
      get :celebration_new
      post :celebration_create
    end
  end

  # devise カスタマイズ版
  # devise_for :users, controllers: {registrations: "users"}
  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'mutters#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
