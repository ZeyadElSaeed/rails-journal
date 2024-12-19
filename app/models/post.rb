class Post < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :author_id
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :tags

  validates :title, :body, presence: true
  validate :must_have_at_least_one_tag

  private
  def must_have_at_least_one_tag
    errors.add(:tags, "have to be included in the request with at least one tag") if tags.empty?
  end
end
