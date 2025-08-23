class ContactsController < ApplicationController
  def new
  end

  def create
    name = params[:name].to_s.strip
    email = params[:email].to_s.strip
    message = params[:message].to_s.strip

    if name.blank? || email.blank? || message.blank?
      flash.now[:alert] = t('contact.missing_item_input')
      render :new, status: :unprocessable_entity
      return
    end

    ContactMailer
      .with(name: name, email: email, message: message)
      .inquiry_email
      .deliver_now

    redirect_to new_contact_path, notice: t('contact.send_success')
  end
end
