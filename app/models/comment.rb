class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :post

  validates :body, presence: true
end
