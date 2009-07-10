# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def first_name
    application_user.first_name
  end

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

  def add_page_setting(name, object)
    # logger.debug("HELP: add_page_settings")
    (@page_settings ||= { })[name] = object
  end

  # As the page is rendered, calls, can be made to add_page_setting
  # which takes name and an arbitrary object and adds it to a has.
  # push_page_settings is called at the bottom of the body of the page
  # and produces a script take with the objects wrapped in the
  # pageSettings object.
  def push_page_settings
    # logger.debug("HELP: push_page_settings")
    unless @page_settings.nil? || @page_settings.empty?
      # logger.debug("HELP: push_page_settings out")
      ret = render(:partial => 'layouts/shared/page_settings')
      @page_settings = { }
      ret
    end
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

  def button(text, action)
    "<button onclick='#{action}' class='auto-button' id='B#{text.to_s.gsub(/[-, ]/, '_')}'>#{text.to_s}</button>"
  end

  def button_url(text, url)
    button(text, "Raptor.loadPage(\"#{url_for(url)}\")")
  end

  def home_button
    button_url "Home", root_path
  end

  def favorites_button
    button_url("Favorites", combined_favorite_queues_path)
  end

  def popup(binding, hash = { })
    hash = { :class => "popup"}.merge(hash)
    span binding, :class => 'popup-wrapper' do
      span binding, hash do
        yield binding
      end
    end
  end
end
