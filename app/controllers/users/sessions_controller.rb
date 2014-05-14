class Users::SessionsController < Devise::SessionsController

  #
  # [memo] LoginHistoryをセットするためにControllerをOverwriteしたけど、ログインのタイミングなんて記録しても特に面白くはないなぁ(2014/05/14)
  #

  # GET /resource/sign_in
  # def new
  # end

  # POST /resource/sign_in
  # def create
    # self.resource = warden.authenticate!(auth_options)
    # set_flash_message(:notice, :signed_in) if is_flashing_format?
    # sign_in(resource_name, resource)
    # yield resource if block_given?

    # # add
    # LoginHistory.create(:user_id => resource.id)
    # respond_with resource, location: after_sign_in_path_for(resource)
  # end
end
