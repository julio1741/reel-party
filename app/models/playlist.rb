# Playlist represents a collection of media items associated with a session.
class Playlist < ApplicationRecord
  belongs_to :session
  has_many :media, class_name: 'Medium'
end
