class Marking < ApplicationRecord
  STATUSES = %w[pending marked resubmission_required].freeze

  belongs_to :homework
  belongs_to :student

  validates :status, inclusion: { in: STATUSES }
  validates :score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :student_id, uniqueness: { scope: :homework_id }

  validate :score_within_maximum_limit
  validate :student_and_homework_belong_to_same_school
  validate :score_present_when_marked

  def pending?
    status == "pending"
  end

  def marked?
    status == "marked"
  end

  def resubmission_required?
    status == "resubmission_required"
  end

  def percentage
    return nil unless score.present? && homework&.max_score&.positive?

    ((score.to_f / homework.max_score) * 100).round(1)
  end

  def passed?
    return false unless score.present? && homework&.max_score&.positive?

    percentage >= 50.0
  end

  def grade_letter
    pct = percentage
    return "N/A" if pct.nil?

    case pct
    when 90..Float::INFINITY then "A"
    when 80...90 then "B"
    when 70...80 then "C"
    when 50...70 then "D"
    else "F"
    end
  end

  def mark!(given_score, given_feedback = nil)
    update!(
      score: given_score,
      feedback: given_feedback,
      status: "marked",
      marked_at: Time.current
    )
  end

  def require_resubmission!(given_feedback = nil)
    update!(
      score: nil,
      feedback: given_feedback,
      status: "resubmission_required",
      marked_at: nil
    )
  end

  private

  def score_within_maximum_limit
    return unless score.present? && homework.present? && homework.max_score.present?

    if score > homework.max_score
      errors.add(:score, "cannot exceed maximum score of #{homework.max_score}")
    end
  end

  def student_and_homework_belong_to_same_school
    return unless student.present? && homework.present?

    if student.school_id != homework.school_id
      errors.add(:student, "must belong to the same school as the homework")
    end
  end

  def score_present_when_marked
    if marked? && score.blank?
      errors.add(:score, "must be provided when marking status is marked")
    end
  end
end
