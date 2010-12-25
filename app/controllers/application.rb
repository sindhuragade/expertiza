# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require '/var/lib/gems/1.8/gems/gdocs4ruby-0.1.2/lib/gdocs4ruby.rb'
class ApplicationController < ActionController::Base
  include GDocs4Ruby

protect_from_forgery :secret => '66c71ad1e57f67bb64bf3ac9ca144f4e'

  def authorize 
    unless session[:user]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'auth', :action => 'login')
    end
  end
  
    def setup
    @account = Service.new()
    @account.debug = true
#    if  session[:gdoc_login] != 1
#      flash[:notice] = "Please login your google account."
#      redirect_to :controller => 'admins', :action => 'gdoc_login', :id => '1'
#    end
 #   @account.authenticate(session[:g_account],[:g_password] )
    @account.authenticate('csc517fall2010@gmail.com', 'csc517lei' )
  end
  
  protected
  def list(object_type)
    # Calls the correct listing method based on the role of the
    # logged-in user and the currently selected constraint.
    #
    # Example: object_type = Rubric, constraint = 'list_all'
    # is transformed into Instructor.list_all(object_type, session[:user].id)
    # if the user is currently logged in as an Instructor
    constraint = @display_option.name
    if constraint == nil or constraint == ''
      constraint = 'list_mine'
    end
    
    ApplicationHelper::get_user_role(session[:user]).send(constraint, object_type, session[:user].id)
  end

  def get(object_type, id)
    # Returns the first record found.  The record may not be found (e.g.,
    # because it is private and belongs to someone else), so catch the exceptions.
    ApplicationHelper::get_user_role(session[:user]).get(object_type, id, session[:user].id)
  end
  
  def set_up_display_options(object_type)
    # Create a set that will be used to populate the dropbox when a user lists a set of objects (assgts., questionnaires, etc.)
    # Get the Instructor::questionnaire constant
    @display_options = eval ApplicationHelper::get_user_role(session[:user]).class.to_s+"::"+object_type 
    @display_option = DisplayOption.new
    @display_option.name = 'list_mine'
    @display_option.name = params[:display_option][:name] if params[:display_option]
  end
  
  def gauthorize
    unless Guser.find_by_name(session[:gname])
      flash[:notice] = "Only for Google Users"
      redirect_to :controller => 'gusers', :action => 'index'
    end
  end
  
end