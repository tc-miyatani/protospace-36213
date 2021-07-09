class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :prototype

  with_options presence: true do
    validates :text
    validates :user
    validates :prototype
  end
end
