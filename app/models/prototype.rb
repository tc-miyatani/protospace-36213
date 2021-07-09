class Prototype < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  with_options presence: true do
    validates :title
    validates :catch_copy
    validates :concept
    validates :image
  end
end
