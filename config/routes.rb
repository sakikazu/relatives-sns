Rails.application.routes.draw do
  # mount RailsAdmin::Engine => '/adamin', :as => 'rails_admin'

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

  get 'blogs/user/:username' => 'blogs#index', as: :blogs_by_user
  resources :blogs do
    collection do
      get :index_mobile
      get :everyone_mobile
      get :show_mobile
      get :new_mobile
      get :edit_mobile
      get :destroy_comment_confirm_mobile
      get :destroy_confirm_mobile
      delete :destroy_image
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
  # for mobile ※携帯だとmethod: :deleteが効いてくれないぽい？？指定してもGETメソッドになっちゃったので
  delete "/blogs/destroy_comment/:id" => "blogs#destroy_comment", :as => :destroy_comment

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
        patch 'update_from_slideshow'
      end
      resources :photo_comments, only: [:create, :destroy]
    end
  end

  # match "/albums/upload_complete/:id" => "albums#upload_complete", :as => :album_up_comp

  delete "/boards/destroy_comment/:id" => "boards#destroy_comment", :as => :destroy_comment_board
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
      get :about
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
  get "nices" => "nices#recent"

  get "/mutters/user/:user_id" => "mutters#all", :as => :mutter_by_user
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
      put :celebration_create
    end
  end

  devise_for :users, controllers: {sessions: 'users/sessions'}


  # for mobile
  # 2014/05/12, routingが間違ってるのでエラーになるけど、もう使わないと思うので削除しようかな
  # get "/m" => "mobile#index", :as => :mobile
  # post "/m/create" => "mobile#create", :as => :mobile_c
  # delete "/m/destory" => "mobile#destroy", :as => :mobile_d
  # get "/m/update_history" => "mobile#update_history", :as => :mobile_uh
  # get "/m/celebration" => "mobile#celebration", :as => :mobile_uh
  # get "/m/celebration_new" => "mobile#celebration_new", :as => :mobile_uh
  # post "/m/celebration_create" => "mobile#celebration_create", :as => :mobile_uh

  # method: :delete が効かないので
  devise_scope :user do
    delete "/m/sign_out" => "devise/sessions#destroy", as: :mobile_sign_out
  end

  root :to => 'mutters#index'

  #
  # This is routes explaination for rails4
  #

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
