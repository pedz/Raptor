# -*- coding: utf-8 -*-
#
# I'm not sure where to put this.  Currently, this approach seems to
# be working:
#
#  1: Create a fresh test database:
#       rake db:drop db:create db:migrate RAILS_ENV=test
#  2: Run the tests:
#       rake test:units
#         or
#       ruby -Itest test/unit/name_test.rb 
#         or
#       ruby -Itest test/unit/name_test.rb -n test_entity_has_one_association
#
# Soemtimes the silly code tries to delete things and that fails.
# Starting with a fresh empty database seems to solve that.  Also, I'm
# making it so that the fixtures are all loaded in test_helper
# (below).  That seems to help too.
#

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  set_fixture_class(
                    :cached_calls => Cached::Call,
                    :cached_centers => Cached::Center,
                    :cached_components => Cached::Component,
                    :cached_customers => Cached::Customer,
                    :cached_pmrs => Cached::Pmr,
                    :cached_psars => Cached::Psar,
                    :cached_queues => Cached::Queue,
                    :cached_queue_infos => Cached::QueueInfo,
                    :cached_registrations => Cached::Registration,
                    :cached_text_lines => Cached::TextLine
                    )
  
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = true

  fixtures(:users,
           :retusers,
           :cached_centers,
           :cached_queues,
           :cached_registrations,
           :cached_queue_infos,
           :cached_customers,
           :favorite_queues,
           :argument_types,
           :name_types,
           :association_types,
           :relationship_types,
           :names,
           :relationships,
           :conditions,
           :argument_defaults)

  # Add more helper methods to be used by all tests here...
  def assert_includes(elem, array, message = nil)
    message = build_message message, '<?> is not found in <?>.', elem, array
    assert_block message do
      array.include? elem
    end
  end

  def assert_does_not_include(elem, array, message = nil)
    message = build_message message, '<?> is was found in <?>.', elem, array
    assert_block message do
      !array.include? elem
    end
  end
end

module LdapConstants
  GOOD_EMAIL          = 'pedzan@us.ibm.com'
  GOOD_PASSWORD       = 'r0ckcafe'
  GOOD_CONTRACTOR_UID = 'C-5UEV897' # Mine (Perry)
  GOOD_REGULAR_UID    = '807520897' # Tom Phillips
  GOOD_MANAGER_UID    = '617362897' # Bill Clark
  BAD_UID             = '000000897'
  GOOD_DEPT           = '5IEA'      # our dept.
end
