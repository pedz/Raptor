set :application, "raptor"
set :repository,  "svn://p51.austin.ibm.com/raptor/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/usr/local/www/raptor"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml" 
set :use_sudo, false

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "apache@p51.austin.ibm.com"
role :web, "apache@p51.austin.ibm.com"
role :db,  "apache@p51.austin.ibm.com", :primary => true
