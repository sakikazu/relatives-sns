# RailsAdmin config file. Generated on 2012/09/15 19:31:35
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  I18n.default_locale = :de

  config.current_user_method { current_admin_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, AdminUser

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, AdminUser

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['A-dan4', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [AdminUser, Album, AlbumComment, Blog, BlogComment, BlogImage, Board, BoardComment, Celebration, Geocode, History, HistoryComment, LoginHistory, Movie, MovieComment, Mutter, Nice, Photo, PhotoComment, UpdateHistory, User, UserExt]

  # Add models here if you want to go 'whitelist mode':
  # config.included_models = [AdminUser, Album, AlbumComment, Blog, BlogComment, BlogImage, Board, BoardComment, Celebration, Geocode, History, HistoryComment, LoginHistory, Movie, MovieComment, Mutter, Nice, Photo, PhotoComment, UpdateHistory, User, UserExt]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model AdminUser do
  #   # Found associations:
  #   # Found columns:
  #     configure :id, :integer 
  #     configure :familyname, :string 
  #     configure :givenname, :string 
  #     configure :role, :string 
  #     configure :email, :string 
  #     configure :status, :boolean 
  #     configure :token, :string 
  #     configure :salt, :string 
  #     configure :crypted_password, :string 
  #     configure :preferences, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Album do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :thumb, :belongs_to_association 
  #     configure :album_comments, :has_many_association 
  #     configure :photos, :has_many_association 
  #     configure :update_histories, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :title, :string 
  #     configure :description, :text 
  #     configure :thumb_id, :integer         # Hidden 
  #     configure :deleted_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model AlbumComment do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :album, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :album_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Blog do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :blog_comments, :has_many_association 
  #     configure :blog_images, :has_many_association 
  #     configure :update_histories, :has_many_association 
  #     configure :nices, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :title, :string 
  #     configure :content, :text 
  #     configure :deleted_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model BlogComment do
  #   # Found associations:
  #     configure :blog, :belongs_to_association 
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :blog_id, :integer         # Hidden 
  #     configure :user_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model BlogImage do
  #   # Found associations:
  #     configure :blog, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :blog_id, :integer         # Hidden 
  #     configure :image_file_name, :string         # Hidden 
  #     configure :image_content_type, :string         # Hidden 
  #     configure :image_file_size, :integer         # Hidden 
  #     configure :image_updated_at, :datetime         # Hidden 
  #     configure :image, :paperclip 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Board do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :board_comments, :has_many_association 
  #     configure :update_histories, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :title, :string 
  #     configure :description, :text 
  #     configure :attach_file_name, :string         # Hidden 
  #     configure :attach_content_type, :string         # Hidden 
  #     configure :attach_file_size, :integer         # Hidden 
  #     configure :attach_updated_at, :datetime         # Hidden 
  #     configure :attach, :paperclip 
  #     configure :deleted_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model BoardComment do
  #   # Found associations:
  #     configure :board, :belongs_to_association 
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :board_id, :integer         # Hidden 
  #     configure :user_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :attach_file_name, :string         # Hidden 
  #     configure :attach_content_type, :string         # Hidden 
  #     configure :attach_file_size, :integer         # Hidden 
  #     configure :attach_updated_at, :datetime         # Hidden 
  #     configure :attach, :paperclip 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Celebration do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :mutters, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :anniversary_at, :date 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Geocode do
  #   # Found associations:
  #   # Found columns:
  #     configure :id, :integer 
  #     configure :address, :string 
  #     configure :lat, :float 
  #     configure :lng, :float 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model History do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :history_comments, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :episode_year, :integer 
  #     configure :episode_month, :integer 
  #     configure :episode_day, :integer 
  #     configure :about_flg, :boolean 
  #     configure :content, :text 
  #     configure :user_id, :integer         # Hidden 
  #     configure :src_user_name, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model HistoryComment do
  #   # Found associations:
  #     configure :history, :belongs_to_association 
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :history_id, :integer         # Hidden 
  #     configure :user_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model LoginHistory do
  #   # Found associations:
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Movie do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :movie_comments, :has_many_association 
  #     configure :update_histories, :has_many_association 
  #     configure :nices, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :title, :string 
  #     configure :description, :text 
  #     configure :movie_file_name, :string         # Hidden 
  #     configure :movie_content_type, :string         # Hidden 
  #     configure :movie_file_size, :integer         # Hidden 
  #     configure :movie_updated_at, :datetime         # Hidden 
  #     configure :movie, :paperclip 
  #     configure :thumb_file_name, :string         # Hidden 
  #     configure :thumb_content_type, :string         # Hidden 
  #     configure :thumb_file_size, :integer         # Hidden 
  #     configure :thumb_updated_at, :datetime         # Hidden 
  #     configure :thumb, :paperclip 
  #     configure :deleted_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :movie_type, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model MovieComment do
  #   # Found associations:
  #     configure :movie, :belongs_to_association 
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :movie_id, :integer         # Hidden 
  #     configure :user_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Mutter do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :parent, :belongs_to_association 
  #     configure :celebration, :belongs_to_association 
  #     configure :children, :has_many_association 
  #     configure :nices, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :reply_id, :integer         # Hidden 
  #     configure :celebration_id, :integer         # Hidden 
  #     configure :for_sort_at, :datetime 
  #     configure :ua, :string 
  #     configure :image_file_name, :string         # Hidden 
  #     configure :image_content_type, :string         # Hidden 
  #     configure :image_file_size, :integer         # Hidden 
  #     configure :image_updated_at, :datetime         # Hidden 
  #     configure :image, :paperclip 
  #     configure :deleted_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Nice do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :asset, :polymorphic_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :asset_id, :integer         # Hidden 
  #     configure :asset_type, :string         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :comment, :text 
  #     configure :niced_user_id, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Photo do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :album, :belongs_to_association 
  #     configure :photo_comments, :has_many_association 
  #     configure :nices, :has_many_association 
  #     configure :update_histories, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :title, :string 
  #     configure :description, :text 
  #     configure :album_id, :integer         # Hidden 
  #     configure :exif_at, :datetime 
  #     configure :last_comment_at, :datetime 
  #     configure :deleted_at, :datetime 
  #     configure :image_file_name, :string         # Hidden 
  #     configure :image_content_type, :string         # Hidden 
  #     configure :image_file_size, :integer         # Hidden 
  #     configure :image_updated_at, :datetime         # Hidden 
  #     configure :image, :paperclip 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model PhotoComment do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :photo, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :content, :text 
  #     configure :photo_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model UpdateHistory do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :content, :polymorphic_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :action_type, :integer 
  #     configure :content_id, :integer         # Hidden 
  #     configure :content_type, :string         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model User do
  #   # Found associations:
  #     configure :mutters, :has_many_association 
  #     configure :celebrations, :has_many_association 
  #     configure :user_ext, :has_one_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :username, :string 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :string         # Hidden 
  #     configure :role, :integer 
  #     configure :email, :string 
  #     configure :familyname, :string 
  #     configure :givenname, :string 
  #     configure :root11, :integer 
  #     configure :generation, :integer 
  #     configure :deleted_at, :datetime 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :string 
  #     configure :last_sign_in_ip, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model UserExt do
  #   # Found associations:
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :familyname, :string 
  #     configure :givenname, :string 
  #     configure :nickname, :string 
  #     configure :sex, :integer 
  #     configure :blood, :integer 
  #     configure :email, :string 
  #     configure :addr1, :string 
  #     configure :addr2, :string 
  #     configure :addr3, :string 
  #     configure :addr4, :string 
  #     configure :addr_from, :string 
  #     configure :birth_day, :date 
  #     configure :image_file_name, :string         # Hidden 
  #     configure :image_content_type, :string         # Hidden 
  #     configure :image_file_size, :integer         # Hidden 
  #     configure :image_updated_at, :datetime         # Hidden 
  #     configure :image, :paperclip 
  #     configure :job, :string 
  #     configure :hobby, :string 
  #     configure :skill, :string 
  #     configure :character, :string 
  #     configure :jiman, :string 
  #     configure :dream, :string 
  #     configure :sonkei, :string 
  #     configure :kyujitsu, :string 
  #     configure :myboom, :string 
  #     configure :fav_food, :string 
  #     configure :unfav_food, :string 
  #     configure :fav_movie, :string 
  #     configure :fav_book, :string 
  #     configure :fav_sports, :string 
  #     configure :fav_music, :string 
  #     configure :fav_game, :string 
  #     configure :fav_brand, :string 
  #     configure :hosii, :string 
  #     configure :ikitai, :string 
  #     configure :yaritai, :string 
  #     configure :free_text, :text 
  #     configure :deleted_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end
