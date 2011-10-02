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

    follow_redirect!
    assert_select('title', "New Retain User")

    # See if we can create a new retain user
    post(path, :retuser => {
           :retid => @retid,
           :apptest => 0,
           :password => @password,
           :password_confirmation => @password})

    # we should redirect to our previous location which is
    # favorite_queues.
    assert_redirected_to "/raptor/favorite_queues"

    # Make sure we set up everything correctly.
    new_user = User.find_by_ldap_id(@ldap_id)
    new_retuser = new_user.current_retain_id
    assert_equal new_retuser.retid, @retid
    assert_equal new_retuser.password, @password

    # Remember the arguments we need later
    @queue_name = @pedz_queue.queue_name
    @h_or_s = @pedz_queue.h_or_s
    @center = @pedz_queue.center.center

    # Delete the queues and center so we can test that when a favorite
    # queue is created, it can also create the queue and the center.
    @amnet_queue.delete
    @pedz_queue.delete
    @tomp_queue.delete
    @ssrika_queue.delete
    @center_165.delete

    follow_redirect!
    assert_select('title', "Favorite Queues")

    # Create is done via post.  We create a new favorite queue.
    post("/raptor/favorite_queues",
         :cached_queue => {
           # We throw in a downcase to make sure that it is changed to
           # upper case.  To really do this right, I should do this
           # multiple times using various edge cases.
           :queue_name => @queue_name.downcase,
           :h_or_s => @h_or_s
         },
         :cached_center => {
           :center => @center
         })

    # Find the new queue (and center).
    new_queue = Cached::Queue.find_by_queue_name(@queue_name)
    # Assert that it is no null
    assert_not_nil new_queue
    # Find the new favorite queue
    new_favorite_queue = new_queue.favorite_queues[0]
    # Make sure that it is not null
    assert_not_nil new_favorite_queue
    # Now we know where we should have been redirected to.
    assert_redirected_to "/raptor/favorite_queues/#{new_favorite_queue.id}"

    # Now, lets go to the list of favorite queues again.  This time,
    # we should not get redirected and we should have an element in
    # the list.
    get "/raptor/favorite_queues"
    # Should be a simple success
    assert_response(:success)
    # Get the list of hashes and verify what we can.
    temp = assigns["favorite_queue_hashes"]
    assert_equal temp.length, 1
    fqh = temp[0]
    assert_equal fqh[:favorite_queue].id, new_favorite_queue.id
    assert_equal fqh[:id], new_favorite_queue.id
    # We've killed the Queue Infos so we should be considering this a
    # team queue (and we guess that it is not empty)
    assert_equal fqh[:team], true
    assert_equal fqh[:q_class], "team-nonempty"
  end
end
