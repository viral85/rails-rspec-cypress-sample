namespace :refactor_organization_type do
  desc "Migrate data from organization_type to user settings"

  task defaults_transfer: :environment do
    Organization.all.each do |organization|
      org_type = organization.organization_type
      organization.update(
        default_logo_url: org_type.logo_url
      )
    end
  end

  task create_user_settings: :environment do
    User.all.each do |user|
      UserSetting.create(
        logo_url: user.organization.default_logo_url,
        user_id: user.id
      )
    end
  end
end
