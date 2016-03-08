class FileUploadsController < ApplicationController
  before_action :set_file_upload, only: [:show, :edit, :update, :destroy]

  # GET /file_uploads
  # GET /file_uploads.json
  def index
    @file_uploads = FileUpload.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @file_uploads }
    end
  end

  # GET /file_uploads/1
  # GET /file_uploads/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @file_upload }
    end
  end

  # GET /file_uploads/new
  def new
    @file_upload = FileUpload.new
  end

  # GET /file_uploads/1/edit
  def edit
  end

  # POST /file_uploads
  # POST /file_uploads.json
  def create
    @file_upload = FileUpload.new(file_upload_params)

    respond_to do |format|
      if @file_upload.save
        format.html { redirect_to @file_upload, notice: 'File upload was successfully created.' }
        format.json { render json: @file_upload, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @file_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /file_uploads/1
  # PATCH/PUT /file_uploads/1.json
  def update
    respond_to do |format|
      if @file_upload.update(file_upload_params)
        format.html { redirect_to @file_upload, notice: 'File upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @file_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /file_uploads/1
  # DELETE /file_uploads/1.json
  def destroy
    @file_upload.destroy
    respond_to do |format|
      format.html { redirect_to file_uploads_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_file_upload
    @file_upload = FileUpload.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def file_upload_params
    params[:file_upload]
  end

  def drop_pdf
    @file = new FileUpload(params[:file])
    
  end
end
