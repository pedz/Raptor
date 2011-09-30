require 'test_helper'

class NewUserSequenceTest < ActionController::IntegrationTest
  # fixtures :all

  # Replace this with your real tests.
  test "the truth" do
    # We are going to delete the pedzan user and retain id's and
    # everything associated with them so we can come in as a new user.
    u = @pedzan
    r = @pedzan_retuser
    retid = r.retid
    password = r.password
    r.favorite_queues.each do |fq|
      fq.delete
    end
    r.registration.delete
    r.delete
    u.owned_names.each do |name|
      puts "name is #{name.name}"
      name.conditions.each do |condition|
        condition.delete
      end
      name.container_names.each do |foo|
        puts "bob"
        foo.delete
      end
      name.argument_defaults.each do |foo|
        puts "fred"
        foo.delete
      end
      name.delete
    end
    u.delete
    puts "hi"
  end
end
