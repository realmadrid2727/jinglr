class JingleCommentsController < ApplicationController
  before_filter :authenticate_user!, except: [:comments, :tracks]
  
  helper_method :jingle
  respond_to :html, :js, :json
  
  def comments
    render partial: "jingle_comments/comments"
  end
  
  def tracks
    render partial: "jingle_comments/tracks"
  end
  
  def create
    # TO DO
    # Limit comment posting to only people the current_user is allowed to comment to (since POST jingle_id can be tampered with)
    @comment = JingleComment.new(
      jingle_id: jingle.id,
      user_id: current_user.id,
      desc: jingle_comment_params[:desc]
    )
      
    respond_with(@comment, location: jingle_path(jingle)) do |format|
      unless @comment.too_much_spam? || @comment.dupe?
        if @comment.save
          format.js { render status: :created }
        else
          format.js { render status: :unprocessable_entity, text: "#{t('models.jingle_comment')} #{@comment.errors.first[1]}"}
        end
      else
        if @comment.too_much_spam?
          message = t('jingle_comments.errors.too_many_comments')
        elsif @comment.dupe?
          message = t('jingle_comments.errors.duplicate')
        end
        format.js { render status: :unprocessable_entity, text: message}
      end
    end
  end
  
  def destroy
    
  end

protected
  def jingle
    @jingle ||= Jingle.find(params[:jingle_id])
  end
  
private
  def jingle_comment_params
    params.require(:jingle_comment).permit(:user_id, :jingle_id, :desc)
  end
end
