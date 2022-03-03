class Onboarding < ApplicationRecord
  belongs_to :user

  def completed?
    completed_step1 && completed_step2 && completed_step3
  end

  def count_steps_left
    [completed_step1, completed_step2, completed_step3].count(false)
  end
end
