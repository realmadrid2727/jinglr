class UserDetailsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html, :js, :json
  def update  
    respond_with(current_user, location: edit_user_path(current_user)) do |format|
      if current_user.detail.update_attributes(user_detail_params)
        format.json { render json: {message: t('flash.notice.update', item: t('models.thing').downcase)}, status: :ok }
      else
        format.json { render json: {message: t('flash.alert.update', item: t('models.thing').downcase)}, status: :unprocessable_entity}
      end
    end
  end
  
private
  def user_detail_params
    params.require(:user_detail).permit(:name, :location, :website, :bio, :user_id)
  end
end
