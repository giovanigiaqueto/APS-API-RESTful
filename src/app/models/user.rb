class User < ApplicationRecord
  validates :name, allow_blank: false, uniqueness: true, presence: true
  validate :allow_write_cannot_be_nil, :admin_cannot_be_nil

  def allow_write_cannot_be_nil
    # valida se o atributo 'allow_write' não é 'nil'
    if allow_write.nil?
      errors.add(:allow_write, "can't be nil")
    end
  end

  def admin_cannot_be_nil
    # valida se o atributo 'admin' não é 'nil'
    if admin.nil?
      errors.add(:admin, "can't be nil")
    end
  end

  before_validation do |user|
    user.allow_write = true if user.admin?
  end
end
