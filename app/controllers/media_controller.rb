# frozen_string_literal: true

# Controller for managing media associated with sessions.
class MediaController < ApplicationController
  def create
    @session = Session.find(params[:session_id])
    @media = @session.media.build(media_params)

    if @media.save
      redirect_to session_path(@session), notice: 'Media added successfully.'
    else
      redirect_to session_path(@session), alert: 'Failed to add media.'
    end
  end

  private

  def media_params
    params.require(:media).permit(:title, :url)
  end
end
