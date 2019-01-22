# == Route Map
#
#                            Prefix Verb   URI Pattern                                                                              Controller#Action
#                              root GET    /                                                                                        mutters#index
#                  new_user_session GET    /users/sign_in(.:format)                                                                 users/sessions#new
#                      user_session POST   /users/sign_in(.:format)                                                                 users/sessions#create
#              destroy_user_session DELETE /users/sign_out(.:format)                                                                users/sessions#destroy
#                 new_user_password GET    /users/password/new(.:format)                                                            devise/passwords#new
#                edit_user_password GET    /users/password/edit(.:format)                                                           devise/passwords#edit
#                     user_password PATCH  /users/password(.:format)                                                                devise/passwords#update
#                                   PUT    /users/password(.:format)                                                                devise/passwords#update
#                                   POST   /users/password(.:format)                                                                devise/passwords#create
#          cancel_user_registration GET    /users/cancel(.:format)                                                                  devise/registrations#cancel
#             new_user_registration GET    /users/sign_up(.:format)                                                                 devise/registrations#new
#            edit_user_registration GET    /users/edit(.:format)                                                                    devise/registrations#edit
#                 user_registration PATCH  /users(.:format)                                                                         devise/registrations#update
#                                   PUT    /users(.:format)                                                                         devise/registrations#update
#                                   DELETE /users(.:format)                                                                         devise/registrations#destroy
#                                   POST   /users(.:format)                                                                         devise/registrations#create
#            new_admin_user_session GET    /admin_users/sign_in(.:format)                                                           devise/sessions#new
#                admin_user_session POST   /admin_users/sign_in(.:format)                                                           devise/sessions#create
#        destroy_admin_user_session DELETE /admin_users/sign_out(.:format)                                                          devise/sessions#destroy
#                       rails_admin        /adamin                                                                                  RailsAdmin::Engine
#                               api        /                                                                                        API
#               edit_account_member GET    /members/:id/edit_account(.:format)                                                      members#edit_account
#             update_account_member PATCH  /members/:id/update_account(.:format)                                                    members#update_account
#              finish_create_member GET    /members/:id/finish_create(.:format)                                                     members#finish_create
#                  relation_members GET    /members/relation(.:format)                                                              members#relation
#                   edit_ex_members GET    /members/edit_ex(.:format)                                                               members#edit_ex
#                       map_members GET    /members/map(.:format)                                                                   members#map
#                       all_members GET    /members/all(.:format)                                                                   members#all
#             login_history_members GET    /members/login_history(.:format)                                                         members#login_history
#                 update_ex_members PUT    /members/update_ex(.:format)                                                             members#update_ex
#                           members GET    /members(.:format)                                                                       members#index
#                                   POST   /members(.:format)                                                                       members#create
#                        new_member GET    /members/new(.:format)                                                                   members#new
#                       edit_member GET    /members/:id/edit(.:format)                                                              members#edit
#                            member GET    /members/:id(.:format)                                                                   members#show
#                                   PATCH  /members/:id(.:format)                                                                   members#update
#                                   PUT    /members/:id(.:format)                                                                   members#update
#                                   DELETE /members/:id(.:format)                                                                   members#destroy
#                     blogs_by_user GET    /blogs/user/:username(.:format)                                                          blogs#index
#               destroy_image_blogs DELETE /blogs/destroy_image(.:format)                                                           blogs#destroy_image
#               create_comment_blog POST   /blogs/:id/create_comment(.:format)                                                      blogs#create_comment
#              destroy_comment_blog DELETE /blogs/:id/destroy_comment(.:format)                                                     blogs#destroy_comment
#                             blogs GET    /blogs(.:format)                                                                         blogs#index
#                                   POST   /blogs(.:format)                                                                         blogs#create
#                          new_blog GET    /blogs/new(.:format)                                                                     blogs#new
#                         edit_blog GET    /blogs/:id/edit(.:format)                                                                blogs#edit
#                              blog GET    /blogs/:id(.:format)                                                                     blogs#show
#                                   PATCH  /blogs/:id(.:format)                                                                     blogs#update
#                                   PUT    /blogs/:id(.:format)                                                                     blogs#update
#                                   DELETE /blogs/:id(.:format)                                                                     blogs#destroy
#              create_comment_movie POST   /movies/:id/create_comment(.:format)                                                     movies#create_comment
#             destroy_comment_movie DELETE /movies/:id/destroy_comment(.:format)                                                    movies#destroy_comment
#                            movies GET    /movies(.:format)                                                                        movies#index
#                                   POST   /movies(.:format)                                                                        movies#create
#                         new_movie GET    /movies/new(.:format)                                                                    movies#new
#                        edit_movie GET    /movies/:id/edit(.:format)                                                               movies#edit
#                             movie GET    /movies/:id(.:format)                                                                    movies#show
#                                   PATCH  /movies/:id(.:format)                                                                    movies#update
#                                   PUT    /movies/:id(.:format)                                                                    movies#update
#                                   DELETE /movies/:id(.:format)                                                                    movies#destroy
#                        top_albums GET    /albums/top(.:format)                                                                    albums#top
#                title_index_albums GET    /albums/title_index(.:format)                                                            albums#title_index
#                     movies_albums GET    /albums/movies(.:format)                                                                 albums#movies
#                      users_albums GET    /albums/users(.:format)                                                                  albums#users
#                    download_album GET    /albums/:id/download(.:format)                                                           albums#download
#              create_comment_album POST   /albums/:id/create_comment(.:format)                                                     albums#create_comment
#             destroy_comment_album DELETE /albums/:id/destroy_comment(.:format)                                                    albums#destroy_comment
#             slideshow_album_photo GET    /albums/:album_id/photos/:id/slideshow(.:format)                                         photos#slideshow
# update_from_slideshow_album_photo PATCH  /albums/:album_id/photos/:id/update_from_slideshow(.:format)                             photos#update_from_slideshow
#        create_comment_album_photo POST   /albums/:album_id/photos/:id/create_comment(.:format)                                    photos#create_comment
#       destroy_comment_album_photo DELETE /albums/:album_id/photos/:id/destroy_comment(.:format)                                   photos#destroy_comment
#                      album_photos GET    /albums/:album_id/photos(.:format)                                                       photos#index
#                                   POST   /albums/:album_id/photos(.:format)                                                       photos#create
#                   new_album_photo GET    /albums/:album_id/photos/new(.:format)                                                   photos#new
#                  edit_album_photo GET    /albums/:album_id/photos/:id/edit(.:format)                                              photos#edit
#                       album_photo GET    /albums/:album_id/photos/:id(.:format)                                                   photos#show
#                                   PATCH  /albums/:album_id/photos/:id(.:format)                                                   photos#update
#                                   PUT    /albums/:album_id/photos/:id(.:format)                                                   photos#update
#                                   DELETE /albums/:album_id/photos/:id(.:format)                                                   photos#destroy
#                            albums GET    /albums(.:format)                                                                        albums#index
#                                   POST   /albums(.:format)                                                                        albums#create
#                         new_album GET    /albums/new(.:format)                                                                    albums#new
#                        edit_album GET    /albums/:id/edit(.:format)                                                               albums#edit
#                             album GET    /albums/:id(.:format)                                                                    albums#show
#                                   PATCH  /albums/:id(.:format)                                                                    albums#update
#                                   PUT    /albums/:id(.:format)                                                                    albums#update
#                                   DELETE /albums/:id(.:format)                                                                    albums#destroy
#             destroy_comment_board DELETE /boards/destroy_comment/:id(.:format)                                                    boards#destroy_comment
#             create_comment_boards POST   /boards/create_comment(.:format)                                                         boards#create_comment
#                            boards GET    /boards(.:format)                                                                        boards#index
#                                   POST   /boards(.:format)                                                                        boards#create
#                         new_board GET    /boards/new(.:format)                                                                    boards#new
#                        edit_board GET    /boards/:id/edit(.:format)                                                               boards#edit
#                             board GET    /boards/:id(.:format)                                                                    boards#show
#                                   PATCH  /boards/:id(.:format)                                                                    boards#update
#                                   PUT    /boards/:id(.:format)                                                                    boards#update
#                                   DELETE /boards/:id(.:format)                                                                    boards#destroy
#             new_comment_histories GET    /histories/new_comment(.:format)                                                         histories#new_comment
#          create_comment_histories POST   /histories/create_comment(.:format)                                                      histories#create_comment
#         destroy_comment_histories DELETE /histories/destroy_comment(.:format)                                                     histories#destroy_comment
#                         histories GET    /histories(.:format)                                                                     histories#index
#                                   POST   /histories(.:format)                                                                     histories#create
#                       new_history GET    /histories/new(.:format)                                                                 histories#new
#                      edit_history GET    /histories/:id/edit(.:format)                                                            histories#edit
#                           history GET    /histories/:id(.:format)                                                                 histories#show
#                                   PATCH  /histories/:id(.:format)                                                                 histories#update
#                                   PUT    /histories/:id(.:format)                                                                 histories#update
#                                   DELETE /histories/:id(.:format)                                                                 histories#destroy
#                      about_others GET    /others/about(.:format)                                                                  others#about
#                            others GET    /others(.:format)                                                                        others#index
#                                   POST   /others(.:format)                                                                        others#create
#                         new_other GET    /others/new(.:format)                                                                    others#new
#                        edit_other GET    /others/:id/edit(.:format)                                                               others#edit
#                             other GET    /others/:id(.:format)                                                                    others#show
#                                   PATCH  /others/:id(.:format)                                                                    others#update
#                                   PUT    /others/:id(.:format)                                                                    others#update
#                                   DELETE /others/:id(.:format)                                                                    others#destroy
#                      recent_nices GET    /nices/recent(.:format)                                                                  nices#recent
#                     ranking_nices GET    /nices/ranking(.:format)                                                                 nices#ranking
#                      donice_nices GET    /nices/donice(.:format)                                                                  nices#donice
#                     wasnice_nices GET    /nices/wasnice(.:format)                                                                 nices#wasnice
#                             nices POST   /nices(.:format)                                                                         nices#create
#                              nice DELETE /nices/:id(.:format)                                                                     nices#destroy
#                                   GET    /nices(.:format)                                                                         nices#recent
#                    mutter_by_user GET    /mutters/user/:user_id(.:format)                                                         mutters#all
#                     graph_mutters GET    /mutters/graph(.:format)                                                                 mutters#graph
#            update_allview_mutters GET    /mutters/update_allview(.:format)                                                        mutters#update_allview
#              update_check_mutters GET    /mutters/update_check(.:format)                                                          mutters#update_check
#               update_disp_mutters GET    /mutters/update_disp(.:format)                                                           mutters#update_disp
#        update_history_all_mutters GET    /mutters/update_history_all(.:format)                                                    mutters#update_history_all
#                       all_mutters GET    /mutters/all(.:format)                                                                   mutters#all
#                    search_mutters GET    /mutters/search(.:format)                                                                mutters#search
#                album_info_mutters GET    /mutters/album_info(.:format)                                                            mutters#album_info
#             new_from_mail_mutters GET    /mutters/new_from_mail(.:format)                                                         mutters#new_from_mail
#          create_from_mail_mutters POST   /mutters/create_from_mail(.:format)                                                      mutters#create_from_mail
#             slider_update_mutters GET    /mutters/slider_update(.:format)                                                         mutters#slider_update
#               celebration_mutters GET    /mutters/celebration(.:format)                                                           mutters#celebration
#           celebration_new_mutters GET    /mutters/celebration_new(.:format)                                                       mutters#celebration_new
#        celebration_create_mutters POST   /mutters/celebration_create(.:format)                                                    mutters#celebration_create
#                           mutters GET    /mutters(.:format)                                                                       mutters#index
#                                   POST   /mutters(.:format)                                                                       mutters#create
#                        new_mutter GET    /mutters/new(.:format)                                                                   mutters#new
#                       edit_mutter GET    /mutters/:id/edit(.:format)                                                              mutters#edit
#                            mutter GET    /mutters/:id(.:format)                                                                   mutters#show
#                                   PATCH  /mutters/:id(.:format)                                                                   mutters#update
#                                   PUT    /mutters/:id(.:format)                                                                   mutters#update
#                                   DELETE /mutters/:id(.:format)                                                                   mutters#destroy
#                rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#         rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#         update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#              rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
# 
# Routes for RailsAdmin::Engine:
#   dashboard GET         /                                      rails_admin/main#dashboard
#       index GET|POST    /:model_name(.:format)                 rails_admin/main#index
#         new GET|POST    /:model_name/new(.:format)             rails_admin/main#new
#      export GET|POST    /:model_name/export(.:format)          rails_admin/main#export
# bulk_delete POST|DELETE /:model_name/bulk_delete(.:format)     rails_admin/main#bulk_delete
# bulk_action POST        /:model_name/bulk_action(.:format)     rails_admin/main#bulk_action
#        show GET         /:model_name/:id(.:format)             rails_admin/main#show
#        edit GET|PUT     /:model_name/:id/edit(.:format)        rails_admin/main#edit
#      delete GET|DELETE  /:model_name/:id/delete(.:format)      rails_admin/main#delete
# show_in_app GET         /:model_name/:id/show_in_app(.:format) rails_admin/main#show_in_app

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root :to => 'mutters#index'

  devise_for :users, controllers: {sessions: 'users/sessions'}
  devise_for :admin_users
  mount RailsAdmin::Engine => '/adamin', as: 'rails_admin'
  mount API => "/"

  resources :members do
    member do
      get :edit_account
      patch :update_account
    end
    collection do
      get 'relation'
      get 'edit_me'
      get 'map'
      get 'all'
      get 'login_history'
    end
  end

  get 'blogs/user/:username' => 'blogs#index', as: :blogs_by_user
  resources :blogs do
    collection do
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
end
