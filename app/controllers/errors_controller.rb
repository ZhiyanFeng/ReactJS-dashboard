class ErrorsController < ApplicationController

  def error_404
    render :status => 404, :formats => [:html]
  end

  def error_422
    render :status => 422, :formats => [:html]
  end

  def error_500
    render :status => 500, :formats => [:html]
  end

  def error_505
    render :status => 505, :formats => [:html]
  end

end