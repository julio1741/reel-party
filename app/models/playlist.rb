class Playlist < ApplicationRecord
  belongs_to :media
  belongs_to :session
end
