Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root :to => 'mutters#index'

  devise_for :users, controllers: {sessions: 'users/sessions'}
  # method: :delete が効かないので
  devise_scope :user do
    delete "/m/sign_out" => "devise/sessions#destroy", as: :mobile_sign_out
  end

  devise_for :admin_users
  mount RailsAdmin::Engine => '/adamin', as: 'rails_admin'
  mount API => "/"

  resources :members do
    member do
      get :edit_account
      patch :update_account
      get :finish_create
    end
    collection do
      get 'relation'
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

    member do
      post :create_comment
      delete :destroy_comment
      # get 'new_images'
      # post 'create_images'
      # post 'symbol_images'
    end
    # collection do
    # delete 'destroy_image'
    # end
  end

  # for mobile ※携帯だとmethod: :deleteが効いてくれないぽい？？指定してもGETメソッドになっちゃったので
  delete "/blogs/destroy_comment/:id" => "blogs#destroy_comment", :as => :destroy_comment

  resources :movies do
    member do
      post :create_comment
      delete :destroy_comment
    end
  end

  resources :albums do
    collection do
      get :top
      get :title_index
      get :movies
      get :users
    end
    member do
      get :download
      post :create_comment
      delete :destroy_comment
    end
    resources :photos do
      member do
        get 'slideshow'
        patch 'update_from_slideshow'
        post :create_comment
        delete :destroy_comment
      end
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
    end
  end

  # for mobile
  # 2014/05/12, routingが間違ってるのでエラーになるけど、もう使わないと思うので削除しようかな
  # get "/m" => "mobile#index", :as => :mobile
  # post "/m/create" => "mobile#create", :as => :mobile_c
  # delete "/m/destory" => "mobile#destroy", :as => :mobile_d
  # get "/m/update_history" => "mobile#update_history", :as => :mobile_uh
  # get "/m/celebration" => "mobile#celebration", :as => :mobile_uh
  # get "/m/celebration_new" => "mobile#celebration_new", :as => :mobile_uh
  # post "/m/celebration_create" => "mobile#celebration_create", :as => :mobile_uh
end
