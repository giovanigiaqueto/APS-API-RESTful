class User < ApplicationRecord
  validates :name, allow_blank: false, uniqueness: true, presence: true
  validates :allow_write, presence: true
  validates :admin, presence: true

  before_validation do |user|
    user.allow_write = true if user.admin?
  end
end
