ADanRails3::Application.routes.draw do

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

  match "/album_photos/create" => "album_photos#create", :as => :album_photos_create 
  match "/album_photos/destroy_comment/:id" => "album_photos#destroy_comment", :as => :destroy_comment_album_photo 
  match "/album_photos/create_comment" => "album_photos#create_comment", :as => :album_photo_comments
  resources :album_photos do
    member do
      get :slideshow
      put :update_from_slideshow
    end
  end

  match "/albums/upload_complete/:id" => "albums#upload_complete", :as => :album_up_comp 
  match  "/albums/title_index" => "albums#title_index", :as => :album_title_index
  resources :albums do
    member do
      get :download
    end
  end

  match "/m" => "mobile#index", :as => :mobile
  match "/m/create" => "mobile#create", :as => :mobile_c
  match "/m/destory" => "mobile#destroy", :as => :mobile_d
  match "/m/update_history" => "mobile#update_history", :as => :mobile_uh
  match "/m/celebration" => "mobile#celebration", :as => :mobile_uh
  match "/m/celebration_new" => "mobile#celebration_new", :as => :mobile_uh
  match "/m/celebration_create" => "mobile#celebration_create", :as => :mobile_uh

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

  match "/blogs/destroy_comment/:id" => "blogs#destroy_comment", :as => :destroy_comment
  match "/blogs/destroy_image/:id" => "blogs#destroy_image", :as => :destroy_image
#sakikazu memo ↓これを下でmemberでやろうとしてもできなかった。全然わからん
  match "/blogs/destroy_mobile/:id" => "blogs#destroy_mobile", :as => :destroy_mobile
## できない・・・
  #resources :blogs, :collection => {:create_comment => :post}, :membar => {:destroy_comment => :delete}
  resources :blogs do
    collection do
      post :create_comment
      get :index_mobile
      get :everyone_mobile
      get :show_mobile
      get :new_mobile
      get :edit_mobile
      get :destroy_comment_confirm_mobile
      get :destroy_confirm_mobile
    end
  end


  match "/movies/destroy_comment/:id" => "movies#destroy_comment", :as => :destroy_comment_movie
  #match "/movies/create_comment(/:movie_id)" => "movies#create_comment"
  #resources :movies
  resources :movies do
    collection do
      post :create_comment
    end
  end

  resource :account, :controller => "users"
  resources :users do
    collection do
      get :login_history
      get :edit_ex
      put :update_ex
      get :all
    end
  end

  match "/mutters/user/:user_id" => "mutters#user", :as => :mutter_by_user
  match "/mutters/slider_update" => "mutters#slider_update"
  match "/mutters/celebration" => "mutters#celebration"
  match "/mutters/celebration_new" => "mutters#celebration_new"
  match "/mutters/celebration_create" => "mutters#celebration_create"
  resources :mutters do
    collection do
      get :update_history_all
      get :all
      get :search
      get :album_info
    end
  end

#for mobile
  match "user_sessions/destroy" => "user_sessions#destroy", :as => :user_session_destroy
  resource :user_session
  #root :controller => "user_sessions", :action => "new"
  root :to => "mutters#index"
  match '/rss2' => "mutters#rss", :format => "rss", :as => :rss2





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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
