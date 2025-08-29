# frozen_string_literal: true

# Controller for managing playlists associated with sessions.
class PlaylistsController < ApplicationController
  before_action :set_session
  before_action :set_playlist, only: [:destroy, :play_next]

  def create
    @playlist = @session.build_playlist
    if @playlist.save
      redirect_to @session, notice: 'Playlist created successfully.'
    else
      redirect_to @session, alert: 'Failed to create playlist.'
    end
  end

  def destroy
    @playlist.destroy
    redirect_to @session, notice: 'Playlist was deleted.'
  end

  def play_next
    # Mark current as completed and play next
    current_playing = @playlist.current_playing
    current_playing&.mark_as_completed!
    
    next_media = @playlist.play_next!
    
    if next_media
      PlaylistChannel.broadcast_to(
        @playlist,
        {
          action: 'play_next',
          current_playing: next_media.id,
          embed_code: next_media.embed_code,
          queue_count: @playlist.total_in_queue
        }
      )
      
      respond_to do |format|
        format.html { redirect_to @session }
        format.json { render json: { success: true, next_media: next_media.id } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @session, notice: 'No more songs in queue.' }
        format.json { render json: { success: false, message: 'No more songs in queue' } }
      end
    end
  end

  private

  def set_session
    @session = Session.find(params[:session_id])
  end

  def set_playlist
    @playlist = @session.playlist
    redirect_to @session, alert: 'No playlist found.' unless @playlist
  end
end
