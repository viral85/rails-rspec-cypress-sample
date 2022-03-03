namespace :roles do
  desc "Migrate data from organization_type to user settings"

  task transfer_organization_roles: :environment do
    Organization.all.each do |organization|
      next unless organization.organization_roles.count.zero?

      organization.default_roles.each do |role|
        OrganizationRole.create(text: role, organization: organization)
      end
    end
  end

  task transfer_user_roles: :environment do
    User.all.each do |user|
      next unless user.user_roles&.count&.zero?

      user.user_settings&.roles&.each do |role|
        UserRole.create(text: role, user: user)
      end
    end
  end
end
