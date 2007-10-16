set :application, "raptor"
set :repository,  "svn://p51.austin.ibm.com/raptor/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# deploy_base is my own variable that is the base of where all the
# rails applications live.
set :deploy_base, "/usr/local/www"

# The real database.yml is kept out of the tree in this path
set :db_path, "#{deploy_base}/database-files/#{application}-database.yml"

# The deploy_to is a variable that Capistrano needs
set :deploy_to, "#{deploy_base}/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml" 
set :use_sudo, false

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "apache@p51.austin.ibm.com"
role :web, "apache@p51.austin.ibm.com"
role :db,  "apache@p51.austin.ibm.com", :primary => true
