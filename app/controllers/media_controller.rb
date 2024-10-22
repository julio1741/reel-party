# frozen_string_literal: true

# Controller for managing media associated with sessions.
class MediaController < ApplicationController
  def create
    @session = Session.find(params[:session_id])
    @playlist = @session.playlist || @session.create_playlist
    @media = @session.media.build(media_params.merge(session_id: @session.id))

    if @media.save
      redirect_to session_path(@session), notice: 'Media added successfully.'
    else
      redirect_to session_path(@session), alert: 'Failed to add media.'
    end
  end

  private

  def media_params
    params.permit(:title, :url)
  end
end
