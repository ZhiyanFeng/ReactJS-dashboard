class StaticPagesController < ApplicationController
  layout 'new_static'
  
  def home
   
  end

  def company
  end

  def help
  end

  def about
  end

  def terms
  end

  def policy
  end

  def contact
    #UserMailer.contact_notification().deliver
    #redirect_to welcome_url, :notice => "Signed up!"
  end
end
