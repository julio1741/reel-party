# frozen_string_literal: true

# Controller for managing media associated with sessions.
class MediaController < ApplicationController
  before_action :set_session
  before_action :set_medium, only: [:destroy]

  def create
    @playlist = @session.playlist || @session.create_playlist
    @medium = @session.media.build(media_params.merge(session_id: @session.id))

    if @medium.save
      PlaylistChannel.broadcast_to(
        @playlist,
        medium: render_to_string(partial: 'medium', locals: { medium: @medium })
      )
      redirect_to session_path(@session), notice: 'Media added successfully.'
    else
      redirect_to session_path(@session), alert: 'Failed to add media.'
    end
  end

  def destroy
    @medium.destroy
    respond_to do |format|
      format.html { redirect_to @session, notice: 'Media was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_session
    @session = Session.find(params[:session_id])
  end

  def set_medium
    @medium = @session.playlist.media.find(params[:id])
  end

  def media_params
    params.permit(:title, :url)
  end
end
