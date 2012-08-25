# -*- coding: utf-8 -*-
class AlbumPhotoComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :album_photo
end
