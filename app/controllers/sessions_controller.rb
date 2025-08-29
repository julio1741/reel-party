# frozen_string_literal: true

# Controller for managing user sessions
class SessionsController < ApplicationController
  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)
    if @session.save
      redirect_to session_path(@session), notice: 'Session created successfully.'
    else
      render :new
    end
  end

  def show
    @session = Session.find(params[:id])
    @new_media = Medium.new
    @playlist = @session.playlist
    @current_playing = @playlist&.current_playing
    @queue = @playlist&.queue || []
    @completed = @playlist&.media&.completed&.ordered || []
  end

  def play_next
    @session = Session.find(params[:id])
    @playlist = @session.playlist
    
    if @playlist.nil?
      respond_to do |format|
        format.html { redirect_to @session, notice: 'No playlist found.' }
        format.json { render json: { success: false, message: 'No playlist found' } }
      end
      return
    end
    
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

  def session_params
    params.require(:session).permit(:host_name)
  end
end
