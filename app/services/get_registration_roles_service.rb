class GetRegistrationRolesService
  def initialize(user:, locale:)
    @user = user
    @locale = locale
    @roles = @user.user_roles
    @org_roles = @user.organization.organization_roles
  end

  def call
    @user.user_roles.count > 2 ? user_roles : organization_roles
  end

  private

  def role_text(role)
    role.spanish_text.presence || role.text
  end

  def user_roles
    @role_options = []
    if @locale == :es
      @roles.order(position: :asc).each do |role|
        role_values = ["#{role.text} (Spanish)", role_text(role)]
        @role_options.push(role_values)
      end
    else
      @role_options = @roles.where.not(text: "").order(position: :asc).pluck(:text, :text)
    end
    @role_options
  end

  def organization_roles
    @role_options = []
    if @locale == :es
      @org_roles.each do |role|
        role_values = ["#{role.text} (Spanish)", role_text(role)]
        @role_options.push(role_values)
      end
    else
      @role_options = @org_roles.order(position: :asc).pluck(:text, :text)
    end
    @role_options
  end
end
