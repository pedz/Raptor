class FeedbackNotesController < ApplicationController
  # We always need the parent feedback object
  before_filter(:get_feedback)

  # GET /feedback_notes
  # GET /feedback_notes.xml
  def index
    @feedback_notes = @feedback.feedback_notes.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedback_notes }
    end
  end

  # GET /feedback_notes/1
  # GET /feedback_notes/1.xml
  def show
    @feedback_note = @feedback.feedback_notes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback_note }
    end
  end

  # GET /feedback/:feedback_id/feedback_notes/new
  # GET /feedback/:feedback_id/feedback_notes/new.xml
  def new
    @feedback_note = @feedback.feedback_notes.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback_note }
    end
  end

  # GET /feedback/:feedback_id/feedback_notes/1/edit
  def edit
    @feedback_note = @feedback.feedback_notes.find(params[:id])
  end

  # POST /feedback_notes
  # POST /feedback_notes.xml
  def create
    @feedback_note = @feedback.feedback_notes.new(params[:feedback_note])
    
    respond_to do |format|
      if @feedback_note.save
        flash[:notice] = 'FeedbackNote was successfully created.'
        format.html { redirect_to(@feedback) }
        format.xml  { render :xml => @feedback_note, :status => :created, :location => @feedback_note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedback_notes/1
  # PUT /feedback_notes/1.xml
  def update
    @feedback_note = @feedback.feedback_notes.find(params[:id])

    respond_to do |format|
      if @feedback_note.update_attributes(params[:feedback_note])
        flash[:notice] = 'FeedbackNote was successfully updated.'
        format.html { redirect_to(@feedback_note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedback_notes/1
  # DELETE /feedback_notes/1.xml
  def destroy
    @feedback_note = @feedback.feedback_notes.find(params[:id])
    @feedback_note.destroy

    respond_to do |format|
      format.html { redirect_to(feedback_feedback_notes_url(@feedback)) }
      format.xml  { head :ok }
    end
  end

  # Get the parent feedback object
  def get_feedback
    @feedback = Feedback.find(params[:feedback_id])
  end
end
