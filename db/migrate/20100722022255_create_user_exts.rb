class CreateUserExts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :user_exts do |t|
      t.integer :user_id
      t.string :familyname
      t.string :givenname
      t.string :nickname
      t.integer :sex
      t.integer :blood
      t.string :email
      t.string :addr1
      t.string :addr2
      t.string :addr3
      t.string :addr4
      t.string :addr_from
      t.date :birth_day

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.string :job
      t.string :hobby
      t.string :skill
      t.string :character
      t.string :jiman
      t.string :dream
      t.string :sonkei
      t.string :kyujitsu
      t.string :myboom
      t.string :fav_food
      t.string :unfav_food
      t.string :fav_movie
      t.string :fav_book
      t.string :fav_sports
      t.string :fav_music
      t.string :fav_game
      t.string :fav_brand
      t.string :hosii
      t.string :ikitai
      t.string :yaritai
      t.text :free_text
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :user_exts
  end
end
