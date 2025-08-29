# Playlist represents a collection of media items associated with a session.
class Playlist < ApplicationRecord
  belongs_to :session
  has_many :media, class_name: 'Medium', dependent: :destroy

  # Get media ordered by queue position
  def queue
    media.queued.ordered
  end

  def current_playing
    media.playing.first
  end

  def next_to_play
    queue.first
  end

  def play_next!
    return unless current_playing.nil? && next_to_play.present?
    
    next_to_play.mark_as_playing!
    next_to_play
  end

  def total_in_queue
    queue.count
  end
end
