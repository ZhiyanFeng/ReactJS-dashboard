class SafetyCoursesController < ApplicationController
  http_basic_authenticate_with :name => "theboat", :password => "whosyourdaddy", :except => [:fetch_url_meta]
  layout "scaffold"
  before_action :set_safety_course, only: [:show, :edit, :update, :destroy]

  # GET /safety_courses
  # GET /safety_courses.json
  def index
    @safety_courses = SafetyCourse.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @safety_courses }
    end
  end

  # GET /safety_courses/1
  # GET /safety_courses/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @safety_course }
    end
  end

  # GET /safety_courses/new
  def new
    @safety_course = SafetyCourse.new
  end

  # GET /safety_courses/1/edit
  def edit
  end

  # POST /safety_courses
  # POST /safety_courses.json
  def create
    @safety_course = SafetyCourse.new(safety_course_params)

    respond_to do |format|
      if @safety_course.save
        format.html { redirect_to @safety_course, notice: 'Safety course was successfully created.' }
        format.json { render json: @safety_course, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @safety_course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /safety_courses/1
  # PATCH/PUT /safety_courses/1.json
  def update
    respond_to do |format|
      if @safety_course.update(safety_course_params)
        format.html { redirect_to @safety_course, notice: 'Safety course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @safety_course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /safety_courses/1
  # DELETE /safety_courses/1.json
  def destroy
    @safety_course.destroy
    respond_to do |format|
      format.html { redirect_to safety_courses_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_safety_course
    @safety_course = SafetyCourse.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def safety_course_params
    params[:safety_course]
  end
end
