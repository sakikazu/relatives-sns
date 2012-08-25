# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# User.create({"email"=>"k.sakimura@learningedge.jp", password: 1528, password_confirmation: 1528, "role"=> 0, "familyname"=>"崎村", "givenname"=>"和孝", "nickname"=>"さっきー", "sex"=>1, "blood"=>3, "contact"=>"", "prefecture"=>13, "addr1"=>"新宿区北新宿", "addr2"=>"", "addr3"=>"", "hometown_prefecture"=>45, "hometown_addr"=>"日南市南郷町", "birthday"=>"Wed, 05 Jan 1983", "free_text"=>"", "hobby"=>"パソコン、ネット、ジョギング、ピアノ", "skill"=>"パソコン", "character"=>, "jiman"=>"", "dream"=>"", "sonkei"=>"", "kyujitsu"=>"", "myboom"=>"", "fav_food"=>, "unfav_food"=>, "fav_movie"=>, "fav_book"=>, "fav_sports"=>, "fav_music"=>, "fav_game"=>, "fav_brand"=>, "hosii"=>, "ikitai"=>, "yaritai"=>, "department"=>, "member_no"=>, "join_company_at"=> "Sat, 18 Jul 2011", "zipcode"=>""})


members = [
  %w(sakikazu 0745 崎村和孝 sakikazu15@gmail.com 0),
  %w(sakiyasu 0000 崎村泰孝 sakikazu15+1@gmail.com 2),
]

members.each do |m|
  User.find_or_create2(m[0], m[1], m[2], m[3], m[4])
end
