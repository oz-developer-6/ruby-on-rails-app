class School < ApplicationRecord
  has_many :students, dependent: :destroy
  has_many :homeworks, dependent: :destroy
  has_many :markings, through: :homeworks

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_code

  def student_count
    students.count
  end

  def homework_count
    homeworks.count
  end

  def completed_markings
    markings.where(status: "marked")
  end

  def average_score
    completed_markings.average(:score)&.round(2) || 0.0
  end

  def completion_rate_percentage
    total = markings.count
    return 0.0 if total.zero?

    ((completed_markings.count.to_f / total) * 100).round(1)
  end

  private

  def normalize_code
    self.code = code&.strip&.upcase
  end
end
