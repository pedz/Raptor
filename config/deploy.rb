
set :application, "raptor"
set :repository,  "apache@tcp237:repositories/raptor.git"
set :domain, "apache@tcp237.austin.ibm.com"
set :scm, :git
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# deploy_base is my own variable that is the base of where all the
# rails applications live.
set :deploy_base, "/usr/local/www"

# The real database.yml is kept out of the tree in this path
set :db_path,     "#{deploy_base}/database-files/#{application}-database.yml"
set :retain_path, "#{deploy_base}/database-files/#{application}-retain.yml"

# The deploy_to is a variable that Capistrano needs
set :deploy_to, "#{deploy_base}/#{application}"
set :use_sudo, false

role :app, domain
role :web, domain
role :db,  domain, :primary => true
