class User < ApplicationRecord
  include BCrypt

  def password
    Password.new(super) unless super.nil?
  end
end
