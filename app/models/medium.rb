# app/models/medium.rb
class Medium < ApplicationRecord
  belongs_to :playlist

  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
end
