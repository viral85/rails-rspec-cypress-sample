namespace :refactor_organization_domain do
  desc "Migrate data from organization.domain to ApprovedDomain"

  task migrate_domains: :environment do
    Organization.all.each do |organization|
      domain = ApprovedDomain.new(domain: organization.domain, organization: organization)
      if domain.save
        p "Domain transfered sucessfully for organization #{organization.id}"
      else
        p "Usucessfull domain transfer for organization #{organization.id}"
      end
    end
  end
end
