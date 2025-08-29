# frozen_string_literal: true

# Controller for managing media associated with sessions.
class MediaController < ApplicationController
  before_action :set_session
  before_action :set_medium, only: [:destroy, :play_next, :pause, :resume, :restart]

  def create
    @playlist = @session.playlist || @session.create_playlist
    platform = helpers.detect_platform(media_params[:url])
    embed_code = helpers.generate_embed_code(platform, media_params[:url])
    
    thumbnail_url = helpers.get_thumbnail_url(platform, media_params[:url])
    display_title = helpers.extract_title_from_url(platform, media_params[:url])
    
    @medium = @playlist.media.build(
      media_params.merge(
        session_id: @session.id, 
        embed_code: embed_code, 
        title: platform,
        thumbnail_url: thumbnail_url,
        display_title: display_title
      )
    )
    
    if @medium.save
      # If it's the first item and nothing is playing, start playing it
      if @playlist.current_playing.nil? && @playlist.queue.count == 1
        @medium.mark_as_playing!
      end
      
      PlaylistChannel.broadcast_to(
        @playlist,
        {
          action: 'add',
          medium: render_to_string(partial: 'medium', locals: { medium: @medium }),
          embed_code: @medium.embed_code,
          position: @medium.position,
          status: @medium.status,
          title: @medium.title,
          display_title: @medium.display_title,
          added_by: @medium.added_by,
          queue_count: @playlist.total_in_queue,
          current_playing: @playlist.current_playing&.id
        }
      )
    else
      flash[:error] = @medium.errors.full_messages.join(', ')
    end
  end

  def destroy
    @medium.destroy
    broadcast_removal
    respond_to do |format|
      format.html { redirect_to @session, notice: 'Media was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def play_next
    @playlist = @session.playlist
    return redirect_to @session, notice: 'No playlist found.' unless @playlist
    
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
    end
    
    respond_to do |format|
      format.html { redirect_to @session }
      format.json { head :no_content }
    end
  end

  def pause
    @playlist = @session.playlist
    return redirect_to @session unless @playlist

    PlaylistChannel.broadcast_to(
      @playlist,
      {
        action: 'pause',
        media_id: @medium.id
      }
    )

    respond_to do |format|
      format.html { redirect_to @session }
      format.json { render json: { success: true } }
    end
  end

  def resume
    @playlist = @session.playlist
    return redirect_to @session unless @playlist

    PlaylistChannel.broadcast_to(
      @playlist,
      {
        action: 'resume',
        media_id: @medium.id
      }
    )

    respond_to do |format|
      format.html { redirect_to @session }
      format.json { render json: { success: true } }
    end
  end

  def restart
    @playlist = @session.playlist
    return redirect_to @session unless @playlist

    PlaylistChannel.broadcast_to(
      @playlist,
      {
        action: 'restart',
        media_id: @medium.id
      }
    )

    respond_to do |format|
      format.html { redirect_to @session }
      format.json { render json: { success: true } }
    end
  end

  private

    def broadcast_removal
      @playlist = @medium.playlist
      PlaylistChannel.broadcast_to(
        @playlist,
        {
          action: 'remove',
          id: @medium.id
        }
      )
    end

    def set_session
      @session = Session.find(params[:session_id])
    end

    def set_medium
      @medium = @session.playlist.media.find(params[:id])
    end

    def media_params
      params.permit(:url, :added_by)
    end
end
