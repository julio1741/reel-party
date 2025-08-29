class Session < ApplicationRecord
  has_one :playlist
  has_many :media, through: :playlist
  
  validates :user_role, inclusion: { in: %w[host guest] }
  
  def host?
    user_role == 'host'
  end
  
  def guest?
    user_role == 'guest'  
  end
end
