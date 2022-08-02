class User < ApplicationRecord
  attr_writer :login 

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :confirmable

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :followers, class_name: "Follow", foreign_key: "followee_id"
  has_many :followees, class_name: "Follow", foreign_key: "follower_id"
  has_many :rcvd_notifs, class_name: "Notification", foreign_key: :recipient_id
  has_many :notifs, as: :notifiable, class_name: "Notification"
  has_one_attached :avatar

  # only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  # check if the same email as the username already exists in the database
  validate :validate_username

  after_commit :add_default_avatar, on: [:create, :update]

  def login 
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["username = :value OR email = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def name 
    name = username
    if first_name.present? 
      name = first_name
      name += " #{last_name}" if last_name.present? 
    elsif last_name.present? 
      name = last_name
    end
    name
  end

  def bio 
    description.blank? ? "404 bio not found" : description 
  end

  def number_of_posts
    posts.where(state: :public).size
  end

  def comments_8_latest 
    comments.order("created_at DESC").first(8)
  end

  def following?(user)
    !Follow.find_by(follower_id: id, followee_id: user.id).nil?
  end

  def liked?(likeable) 
    likes.find_by(likeable: likeable).present?
  end

  def commented?(commentable)
    comments.find_by(commentable: commentable).present?
  end

  def show_avatar(w, h) 
    avatar.variant(resize_to_fit:[w, h])
  end

  private 
  
  def add_default_avatar
    unless avatar.attached?
      self.avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "user-avatar.jpeg")), filename: 'default.jpg' , content_type: "image/jpg")
    end
  end
end
