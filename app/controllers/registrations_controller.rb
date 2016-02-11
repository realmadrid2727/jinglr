class RegistrationsController < Devise::RegistrationsController
  layout "credentials"

  def username_check
    unless params[:username].blank? || params[:username].match(/\A[a-zA-Z0-9_]*\z/i).blank?
      user = User.where("username = ?", params[:username])[0]
      respond_to do |format|
        if user
          format.json { render json: {username_exists: true}, status: :unprocessable_entity }
        else
          format.json { render json: {username_exists: false}, status: :ok }
        end
      end
    else
      render json: {username_exists: true}, status: :unprocessable_entity
    end
  end
end
