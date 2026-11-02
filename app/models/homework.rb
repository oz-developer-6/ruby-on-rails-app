class Homework < ApplicationRecord
  belongs_to :school
  has_many :markings, dependent: :destroy
  has_many :students, through: :markings

  validates :title, presence: true
  validates :subject, presence: true
  validates :max_score, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true

  def overdue?
    due_date.present? && due_date < Date.current
  end

  def marked_markings
    markings.where(status: "marked")
  end

  def pending_markings
    markings.where(status: "pending")
  end

  def average_score
    marked_markings.average(:score)&.round(2) || 0.0
  end

  def average_percentage
    return 0.0 if max_score.to_f.zero? || marked_markings.empty?

    ((average_score / max_score.to_f) * 100).round(1)
  end

  def completion_rate_percentage
    total = markings.count
    return 0.0 if total.zero?

    ((marked_markings.count.to_f / total) * 100).round(1)
  end

  def assign_to_all_school_students!
    school.students.find_each do |student|
      markings.find_or_create_by!(student: student)
    end
  end
end
