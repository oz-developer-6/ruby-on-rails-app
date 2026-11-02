class MarkingsController < ApplicationController
  before_action :set_marking, only: %i[show edit update destroy quick_mark]
  before_action :load_form_collections, only: %i[new edit create update]

  def index
    @markings = Marking.includes(:student, homework: :school).order(updated_at: :desc)
    @markings = @markings.where(status: params[:status]) if params[:status].present?
    @markings = @markings.where(homework_id: params[:homework_id]) if params[:homework_id].present?
  end

  def show
  end

  def new
    @marking = Marking.new(homework_id: params[:homework_id], student_id: params[:student_id], status: "pending")
  end

  def edit
  end

  def create
    @marking = Marking.new(marking_params)

    if @marking.save
      redirect_to @marking, notice: "Homework marking record established."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @marking.update(marking_params)
      redirect_to @marking, notice: "Marking successfully recorded."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def quick_mark
    if params[:status] == "resubmission_required"
      @marking.require_resubmission!(params[:feedback])
      redirect_back fallback_location: @marking, notice: "Resubmission required for #{@marking.student.full_name}."
    else
      score_value = params[:score].to_f
      @marking.mark!(score_value, params[:feedback])
      redirect_back fallback_location: @marking, notice: "Marking saved for #{@marking.student.full_name}."
    end
  end

  def destroy
    homework = @marking.homework
    @marking.destroy
    redirect_to homework_path(homework), notice: "Marking record removed."
  end

  private

  def set_marking
    @marking = Marking.find(params[:id])
  end

  def load_form_collections
    @homeworks = Homework.includes(:school).order(:title)
    @students = Student.includes(:school).order(:last_name)
  end

  def marking_params
    params.require(:marking).permit(:homework_id, :student_id, :score, :status, :feedback, :marked_at)
  end
end
