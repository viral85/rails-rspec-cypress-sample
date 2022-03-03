namespace :onboarding do
  desc "Set users as onboarded"
  task set_onboarded_users: :environment do |_task, args|
    users_ids = args.extras
    User.where(id: users_ids).each do |user|
      user.create_onboarding_record
      user.update(sign_in_count: 1)
      user.onboarding.update(completed_step1: true, completed_step2: true, completed_step3: true)
    end
  end
end
