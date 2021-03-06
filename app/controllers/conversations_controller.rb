class ConversationsController < ApplicationController
  before_filter :signed_in_user

  def index
    @participants = Micropost.direct_message_participants(current_user)
  end

  def show
    @feed_items = Micropost.conversation(current_user.id, params[:id]).paginate(page: params[:page])
    @micropost  = current_user.microposts.build
    @dm_target = User.find(params[:id])
  end

end
