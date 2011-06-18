# -*- coding: utf-8 -*-
module SM
  class ToFlow
    def handle_special_COMMENT(special)
      special.text
    end
  end
end

namespace :doc do
  RAILS_INCLUDES = [
                    'README',
                    'vendor/rails/railties/CHANGELOG',
                    'vendor/rails/railties/MIT-LICENSE',
                    'vendor/rails/activerecord/README',
                    'vendor/rails/activerecord/CHANGELOG',
                    'vendor/rails/activerecord/lib/active_record/**/*.rb',
                    'vendor/rails/actionpack/README',
                    'vendor/rails/actionpack/CHANGELOG',
                    'vendor/rails/actionpack/lib/action_controller/**/*.rb',
                    'vendor/rails/actionpack/lib/action_view/**/*.rb',
                    'vendor/rails/actionmailer/README',
                    'vendor/rails/actionmailer/CHANGELOG',
                    'vendor/rails/actionmailer/lib/action_mailer/base.rb',
                    'vendor/rails/actionwebservice/README',
                    'vendor/rails/actionwebservice/CHANGELOG',
                    'vendor/rails/actionwebservice/lib/action_web_service.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/*.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/api/*.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/client/*.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/container/*.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/dispatcher/*.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/protocol/*.rb',
                    'vendor/rails/actionwebservice/lib/action_web_service/support/*.rb',
                    'vendor/rails/activesupport/README',
                    'vendor/rails/activesupport/CHANGELOG',
                    'vendor/rails/activesupport/lib/active_support/**/*.rb',
                   ]
  
  RAILS_EXCLUDES = [
                    'vendor/rails/activerecord/lib/active_record/vendor/*',
                   ]
  
  desc "Generate ri documentation for the Rails framework"
  Rake::RDocTask.new("rails-ri") { |rdoc|
    rdoc.rdoc_dir = 'doc/api/ri'
    rdoc.template = "#{ENV['template']}.rb" if ENV['template']
    rdoc.title    = "Rails Framework Documentation"
    rdoc.options << '--line-numbers' << '--inline-source' << '--ri'
    RAILS_INCLUDES.each { |l| rdoc.rdoc_files.include(l) }
    RAILS_EXCLUDES.each { |l| rdoc.rdoc_files.exclude(l) }
  }
end
