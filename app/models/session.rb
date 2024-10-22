class Session < ApplicationRecord
  has_many :media, dependent: :destroy
end
