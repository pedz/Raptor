require 'test_helper'

class NewUserSequenceTest < ActionController::IntegrationTest
  # fixtures :all

  # Replace this with your real tests.
  test "whatever" do
    puts "Test started"
    # We are going to delete the pedzan user and retain id's and
    # everything associated with them so we can come in as a new user.
    u = @pedzan
    r = @pedzan_retuser
    @ldap_id = u.ldap_id
    @retid = r.retid
    @password = r.password

    temp = Cached::Registration.find_by_signon(@retid)
    assert_not_nil temp

    r.favorite_queues.each do |fq|
      fq.delete
    end
    r.registration.delete
    r.delete
    u.owned_names.each do |name|
      name.conditions.each do |condition|
        condition.delete
      end
      name.container_names.each do |tmp|
        tmp.delete
      end
      name.argument_defaults.each do |tmp|
        tmp.delete
      end
      name.delete
    end
    u.delete
    puts "user deleted"

    temp = Cached::Registration.find_by_signon(@retid)
    assert_nil temp

    # See if we get to the welcome page
    get "/raptor"
    assert_response(:success)
    assert_select('title', "Welcome to Raptor")

    # See if we get redirected to enter our 
    get "/raptor/favorite_queues"
    new_user = User.find_by_ldap_id(@ldap_id)
    assert_nil(new_user.current_retain_id)
    path = "/raptor/settings/users/#{new_user.id}/retusers"
    assert_redirected_to "#{path}/new"

    # See if we can create a new retain user
    post(path, :retuser => {
           :retid => @retid,
           :apptest => 0,
           :password => @password,
           :password_confirmation => @password})

    # we should redirect to our previous location which is favorite_queues.
    assert_redirected_to "/raptor/favorite_queues"
    new_user = User.find_by_ldap_id(@ldap_id)
    new_retuser = new_user.current_retain_id
    assert_equal new_retuser.retid, @retid
    assert_equal new_retuser.password, @password

    puts @pedz_queue.queue_name
  end
end
