class UploadUserLogoService
  def initialize(user:, params_logo:)
    @user = user
    @user_settings = user.user_settings
    @params_logo = params_logo
    @new_logo = nil
  end

  def call
    return [false, { alert: "Logo is missing!" }] unless check_logo_is_valid?

    response = upload_on_cloudinary
    if moderation_approved?(response)
      upload_logo
    else
      add_logo_last_error(response)
    end
  end

  def remove_logo
    cloudinary_public_id = "#{@user_settings.cloudinary_dir}#{@user_settings&.logo&.filename}"
    remove_logo_from_cloudinary(cloudinary_public_id) if @user_settings.logo.present?
    @user_settings.logo.purge
  end

  private

  def remove_logo_from_cloudinary(public_id)
    Cloudinary::Uploader.destroy(public_id)
  end

  def upload_on_cloudinary
    @new_logo = "#{@user_settings.cloudinary_dir}#{@params_logo.original_filename}"
    options = { public_id: @new_logo }
    options[:moderation] = "aws_rek" unless Rails.env.development?
    Cloudinary::Uploader.upload(@params_logo.tempfile, options)
  end

  def moderation_approved?(response)
    return true if Rails.env.development?

    status = false
    if response["moderation"].present? && response["moderation"].is_a?(Array)
      moderation = response["moderation"][0]
      if moderation.present? && moderation.is_a?(Hash) && moderation["status"] == "approved"
        status = true
      end
    end
    status
  end

  def upload_logo
    old_logo = @user_settings.logo.filename if @user_settings.logo
    if @user_settings.update(logo: @params_logo)
      remove_logo_from_cloudinary("#{@user_settings.cloudinary_dir}#{old_logo}") if old_logo
      [true, { notice: "Logo updated successfully" }]
    else
      remove_logo_from_cloudinary(@new_logo) if @new_logo
      [false, { alert: @user_settings.errors.full_messages.join(", ") }]
    end
  end

  def add_logo_last_error(response)
    @user_settings.update(logo_last_error: response)
    alert = "Your logo could not be updated because the image uploaded was not safe or appropriate"
    [false, { alert: alert }]
  end

  def check_logo_is_valid?
    @params_logo.present? && @params_logo.is_a?(ActionDispatch::Http::UploadedFile)
  end
end
