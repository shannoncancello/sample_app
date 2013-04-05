class Micropost < ActiveRecord::Base
  REPLY_TO_REGEX = /\A@([^\s]*)/
  PRIVATE_REGEX = /\A[dD]\s*@([^\s]*)/

  attr_accessible :content, :in_reply_to, :private
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope order: 'microposts.created_at DESC'
  #scope :including_replies, -> user { where(in_reply_to: user.followed_user_ids) }

  before_save :extract_in_reply_to
  before_save :extract_private

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end

  def self.from_users_followed_by_including_replies(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id OR in_reply_to = :user_id", 
          user_id: user.id)
  end

  def self.from_users_followed_by_private_only(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id = :user_id AND in_reply_to => !nil AND private = 1 OR in_reply_to = :user_id AND private = 1")
  end

  private

  def extract_in_reply_to
    if user_name = content[REPLY_TO_REGEX] 
      user = User.find_by_username user_name[1..-1]
      if user
        self.in_reply_to = user.id
      end
    end
  end

  def extract_private
    if self.in_reply_to = !nil
      if content[PRIVATE_REGEX]
        self.private = true
      end
    end
  end
end
