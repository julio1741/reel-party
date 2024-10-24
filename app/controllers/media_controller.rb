# frozen_string_literal: true

# Controller for managing media associated with sessions.
class MediaController < ApplicationController
  before_action :set_session
  before_action :set_medium, only: [:destroy]

  def create
    @playlist = @session.playlist || @session.create_playlist
    platform = helpers.detect_platform(media_params[:url])
    embed_code = helpers.generate_embed_code(platform, media_params[:url])
    @medium = @session.media.build(media_params.merge(session_id: @session.id, embed_code: embed_code, title: platform))
    if @medium.save
      PlaylistChannel.broadcast_to(
        @playlist,
        {
          action: 'add',
          medium: render_to_string(partial: 'medium', locals: { medium: @medium }),
          embed_code: @medium.embed_code
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
      params.permit(:url)
    end
end
