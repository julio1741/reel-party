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
    @media = @session.media  # Obtén los medios asociados a la sesión
  end

  private

  def session_params
    params.require(:session).permit(:host_name)
  end
end
