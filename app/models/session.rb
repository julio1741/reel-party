class Session < ApplicationRecord
  has_one :playlist
  has_many :media, through: :playlist
end
