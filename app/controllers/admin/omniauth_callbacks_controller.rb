class Admin::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def openid_connect
    @admin = Admin.from_omniauth(request.env["omniauth.auth"])
    puts admin
  end
end
