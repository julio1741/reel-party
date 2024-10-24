# frozen_string_literal: true

# Controller for managing playlists associated with sessions.
class PlaylistsController < ApplicationController
  def create
    @session = Session.find(params[:session_id])
    @playlist = @session.playlists.build(playlist_params)

    if @playlist.save
      redirect_to session_path(@session), notice: 'Media added to playlist successfully.'
    else
      redirect_to session_path(@session), alert: 'Failed to add media to playlist.'
    end
  end

  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy
    redirect_to session_path(@playlist.session), notice: 'Media removed from playlist.'
  end

  private

  def playlist_params
    params.require(:playlist).permit(:media_id)
  end
end
