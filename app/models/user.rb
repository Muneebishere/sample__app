class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, :foreign_key => "follower_id",class_name: "Relationship",  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, :foreign_key => "followed_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :passive_relationships

  has_secure_password
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true


  def feed
    # This is preliminary. See "Following users" for the full implementation.
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end


  def following?(other_user)
    following.include?(other_user)
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  private
  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
