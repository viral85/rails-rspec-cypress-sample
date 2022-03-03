class UserSetting < ApplicationRecord
  belongs_to :user
  has_one_attached :logo

  # Validations
  validate :image_type

  def cloudinary_dir
    "organizations/#{user.organization.name}/#{user.id}/"
  end

  private

  def image_type
    if logo.present? && !logo.content_type.in?(
      %('image/jpeg image/png')
    )
      errors.add(:logo, "needs to be a jpg or png")
    end
  end
end
