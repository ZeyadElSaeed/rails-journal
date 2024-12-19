class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password

  has_many :posts, foreign_key: :author_id, dependent: :nullify
  has_many :comments, dependent: :nullify

  validates :name, :email, :password, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX, message: "is invalid" }, uniqueness: { case_sensitive: false }
end
