class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :load_schools, only: %i[new edit create update]

  def index
    @students = if params[:school_id].present?
      Student.where(school_id: params[:school_id]).includes(:school).order(:last_name)
    else
      Student.includes(:school).order(:last_name)
    end
  end

  def show
    @markings = @student.markings.includes(:homework).order("homeworks.due_date DESC")
  end

  def new
    @student = Student.new(school_id: params[:school_id])
  end

  def edit
  end

  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student, notice: "Student successfully enrolled."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: "Student profile successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_url, notice: "Student record successfully removed."
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def load_schools
    @schools = School.order(:name)
  end

  def student_params
    params.require(:student).permit(:school_id, :first_name, :last_name, :email, :enrollment_number)
  end
end
