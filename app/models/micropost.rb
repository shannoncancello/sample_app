class Micropost < ActiveRecord::Base
  REPLY_TO_REGEX = /\A@([^\s]*)/
  DM_REGEX = /\A[dD]\s*@([^\s]*)/

  attr_accessible :content, :in_reply_to, :direct_message
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope order: 'microposts.created_at DESC'

  before_save :extract_in_reply_to

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end

  def self.from_users_followed_by_including_replies(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id OR
      in_reply_to = :user_id", user_id: user.id)
  end

  def self.direct_messages(user)
    where("(user_id = :user_id AND in_reply_to is not NULL AND direct_message =
      :dm_value) OR (in_reply_to = :user_id AND direct_message = :dm_value)",
      user_id: user.id, dm_value: true)
  end

  private

  def extract_in_reply_to
    if user_name = (content[REPLY_TO_REGEX] || (content[DM_REGEX] && content[DM_REGEX].split.last))
      user = User.find_by_username user_name[1..-1]
      if user
        self.in_reply_to = user.id
        if content[DM_REGEX]
          self.direct_message = true
        end
      end
    end
  end
end
