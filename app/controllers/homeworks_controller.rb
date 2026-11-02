class HomeworksController < ApplicationController
  before_action :set_homework, only: %i[show edit update destroy assign_all]
  before_action :load_schools, only: %i[new edit create update]

  def index
    @homeworks = if params[:school_id].present?
      Homework.where(school_id: params[:school_id]).includes(:school).order(due_date: :desc)
    else
      Homework.includes(:school).order(due_date: :desc)
    end
  end

  def show
    @markings = @homework.markings.includes(:student).order("students.last_name ASC")
  end

  def new
    @homework = Homework.new(school_id: params[:school_id], max_score: 100, due_date: Date.current + 7.days)
  end

  def edit
  end

  def create
    @homework = Homework.new(homework_params)

    if @homework.save
      redirect_to @homework, notice: "Homework assignment successfully published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @homework.update(homework_params)
      redirect_to @homework, notice: "Homework assignment successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @homework.destroy
    redirect_to homeworks_url, notice: "Homework assignment successfully deleted."
  end

  def assign_all
    @homework.assign_to_all_school_students!
    redirect_to @homework, notice: "Homework successfully assigned to all students in #{@homework.school.name}."
  end

  private

  def set_homework
    @homework = Homework.find(params[:id])
  end

  def load_schools
    @schools = School.order(:name)
  end

  def homework_params
    params.require(:homework).permit(:school_id, :title, :subject, :description, :max_score, :due_date)
  end
end
