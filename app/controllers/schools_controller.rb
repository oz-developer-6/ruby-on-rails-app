class SchoolsController < ApplicationController
  before_action :set_school, only: %i[show edit update destroy]

  def index
    @schools = School.order(:name)
  end

  def show
    @students = @school.students.order(:last_name)
    @homeworks = @school.homeworks.order(due_date: :desc)
  end

  def new
    @school = School.new
  end

  def edit
  end

  def create
    @school = School.new(school_params)

    if @school.save
      redirect_to @school, notice: "School successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @school.update(school_params)
      redirect_to @school, notice: "School successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_url, notice: "School successfully removed."
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name, :code, :address)
  end
end
