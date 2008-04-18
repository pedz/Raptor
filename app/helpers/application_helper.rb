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

  def print_stats
    calls = Retain::Connection.request_count
    time = Retain::Connection.total_time
    avg = time / [ calls, 1.0 ].max
    res = "<span id='retain-stats'>"
    res << "#{calls} Retain calls executed used "
    res << "#{"%.3f" % time} seconds or "
    res << "#{"%.3f" % avg} seconds per call. "
    res << "</span>"
    res
  end

  def std_scripts(*extras)
    [ "prototype",
      "scriptaculous",
      "firebug/firebug",
      "raptor",
      "application" ] + extras
  end
  
  def std_styles(*extras)
    [ "scaffold", "application" ] + extras
  end
  
  def admin?
    session[:user].admin
  end

  def button(text, action)
    "<button onclick='#{action}' class='auto-button' id='#{text.to_s}'>#{text.to_s}</button>"
  end

  def button_url(text, url)
    button(text, "Raptor.loadPage(\"#{url_for(url)}\")")
  end
end
