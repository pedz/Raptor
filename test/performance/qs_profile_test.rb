require 'test_helper'
require 'performance_test_help'

class QsProfileTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def test_homepage
    get '/combined_qs/PEDZ,S,165'
    get '/combined_qs/GAUDIN,S,165'
    get '/combined_qs/PEDZ,S,165'
    get '/combined_qs/GAUDIN,S,165'
    get '/combined_qs/PEDZ,S,165'
    get '/combined_qs/GAUDIN,S,165'
    get '/combined_qs/PEDZ,S,165'
    get '/combined_qs/GAUDIN,S,165'
    get '/combined_qs/PEDZ,S,165'
    get '/combined_qs/GAUDIN,S,165'
  end
end
