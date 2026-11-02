class Student < ApplicationRecord
  belongs_to :school
  has_many :markings, dependent: :destroy
  has_many :homeworks, through: :markings

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :enrollment_number, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_attributes

  def full_name
    "#{first_name} #{last_name}"
  end

  def marked_submissions
    markings.where(status: "marked")
  end

  def pending_submissions
    markings.where(status: "pending")
  end

  def average_score
    marked_submissions.average(:score)&.round(2) || 0.0
  end

  def completion_rate_percentage
    total = markings.count
    return 0.0 if total.zero?

    ((marked_submissions.count.to_f / total) * 100).round(1)
  end

  def passed_markings_count
    marked_submissions.select(&:passed?).count
  end

  private

  def normalize_attributes
    self.email = email&.strip&.downcase
    self.enrollment_number = enrollment_number&.strip&.upcase
  end
end
