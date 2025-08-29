# app/models/medium.rb
class Medium < ApplicationRecord
  belongs_to :playlist

  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :status, inclusion: { in: %w[queued playing completed] }

  # Set position automatically before creation
  before_create :set_position

  scope :ordered, -> { order(:position) }
  scope :queued, -> { where(status: 'queued') }
  scope :playing, -> { where(status: 'playing') }
  scope :completed, -> { where(status: 'completed') }

  def next_in_queue
    playlist.media.queued.where('position > ?', position).ordered.first
  end

  def mark_as_playing!
    # Mark current playing as completed
    playlist.media.playing.update_all(status: 'completed')
    # Mark this as playing
    update!(status: 'playing')
  end

  def mark_as_completed!
    update!(status: 'completed')
  end

  private

  def set_position
    max_position = playlist.media.maximum(:position) || 0
    self.position = max_position + 1
  end
end
