class Micropost < ActiveRecord::Base
  REPLY_TO_REGEX = /\A@([^\s]*)/

  attr_accessible :content, :in_reply_to
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope order: 'microposts.created_at DESC'
  #scope :including_replies, -> user { where(in_reply_to: user.followed_user_ids) }

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
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id OR in_reply_to = :user_id", 
          user_id: user.id)
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

end
