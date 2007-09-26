# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def app_doctype
    render :partial => 'layouts/shared/doctype'
  end
  
  def app_header(styles = [], scripts = [])
    render(:partial => 'layouts/shared/header',
           :locals => {
             :javascript_files =>  scripts,
             :stylesheets => styles
           })
  end

  def app_body(*divs)
    render(:partial => 'layouts/shared/body',
           :locals => {
             :divs => divs
           })
  end

  def std_scripts(*extras)
    [ "prototype",
      "effects",
      "prototype",
      "effects",
      "dragdrop",
      "controls",
      "lowpro",
      "firebug/firebug",
      "application" ] + extras
  end
  
  def std_styles(*extras)
    [ "scaffold" ] + extras
  end
  
  def admin?
    session[:user].admin
  end
end
