class DashboardController < ApplicationController
  def index
    @total_schools = School.count
    @total_students = Student.count
    @total_homeworks = Homework.count
    @total_markings = Marking.count
    @marked_count = Marking.where(status: "marked").count
    @pending_count = Marking.where(status: "pending").count
    @recent_markings = Marking.includes(:student, :homework).order(updated_at: :desc).limit(5)
    @recent_homeworks = Homework.includes(:school).order(created_at: :desc).limit(5)
    @schools = School.all.order(:name)
  end
end
