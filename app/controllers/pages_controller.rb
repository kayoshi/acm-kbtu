class PagesController < ApplicationController
  # GET /pages
  # GET /pages.json
  def before_load_header
    @nodes = Node.all.sort {|a, b| a.position <=> b.position}
    @this_node = params[:path]
  end

  def index
    before_load_header
    @this_node = 1
    if Node.all(:order => '0').empty?
      @children_pages = []
    else
      @children_pages = Page.all(:parent => Node.all.sort {|a, b| a.position <=> b.position}[0].name.downcase).sort! {|a, b| a.order <=> b.order}
    end
  end

  def node_controll
    before_load_header

    @node = Node.all(:path => params[:path])[0]
    if Node.all(:path => params[:path]).empty? || Page.all(:parent => @node.name.downcase).empty?
      @children_pages = []
    else
      @children_pages = Page.all(:parent => @node.name.downcase).sort {|a, b| a.order <=> b.order}
    end
    render :action => "index"
  end

  def list
    before_load_header

    @pages = Page.all

    authorize! :read, @pages

    @users = User.all

    respond_to do |format|
    format.html # index.html.erb
      format.json { render json: @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    before_load_header

    @page = Page.all(:path => params[:id])[0]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new

    authorize! :new, @page

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
    authorize! :edit, @page
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])
    authorize! :create, @page

    @page.before_save(@page)

    @page.user_id = current_user.id

    u = User.find(@page.user_id)
    @page.author = u.email

    respond_to do |format|
      if @page.save
        format.html { redirect_to '/pages/'+@page.path, notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])
    authorize! :update, @page

    page_update = params[:page]
    page_update[:parent].downcase!
    page_update[:body] = '.' if page_update[:parent] == 'main_page'
    path = ''
    if page_update[:parent] == 'main_page'
      path = 'node/'
    else
      path = 'pages/'
    end
    path += page_update[:path]

    respond_to do |format|
      if @page.update_attributes(page_update)
        format.html { redirect_to list_path, notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])

    authorize! :destroy, @page

    @page.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
