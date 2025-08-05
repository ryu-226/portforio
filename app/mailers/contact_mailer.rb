class ContactMailer < ApplicationMailer
  def inquiry_email
    @name = params[:name]
    @sender_email = params[:email]
    @body = params[:message]

    mail(
      to: "meshigacha.info@gmail.com",
      from: @sender_email,
      subject: "【めしガチャ】お問い合わせを受信しました（#{@name}様）"
    )
  end
end
