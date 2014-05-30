# run via runner

normal_name = 'AMNETK'
hot_name = 'AMNETK - Hot'
me = User.find_by_ldap_id('pedzan@us.ibm.com')
darshan = {
  :user => User.find_by_ldap_id('darshanp@us.ibm.com'),
  :name => 'Darshan',
  :active => true
}
jim = {
  :user => User.find_by_ldap_id('jgaudin@us.ibm.com'),
  :name => 'Jim',
  :active => true
}
luis = {
  :user => User.find_by_ldap_id('pizana@us.ibm.com'),
  :name => 'Luis',
  :active => true
}
perry = {
  :user => User.find_by_ldap_id('pedzan@us.ibm.com'),
  :name => 'Perry',
  :active => true
}
tom = {
  :user => User.find_by_ldap_id('ltp@us.ibm.com'),
  :name => 'Tom',
  :active => true
}
min = {
  :user => User.find_by_ldap_id('minkim@us.ibm.com'),
  :name => 'Min',
  :active => true
}
sangeetha = {
  :user => User.find_by_ldap_id('ssrikant@us.ibm.com'),
  :name => 'Sangeetha',
  :active => true
}
uma = {
  :user => User.find_by_ldap_id('kuma@us.ibm.com'),
  :name => 'Uma',
  :active => true
}
bob = {
  :user => User.find_by_ldap_id('bobross@us.ibm.com'),
  :name => 'Bob',
  :active => true
}
ram = {
  :user => User.find_by_ldap_id('ramkumar@us.ibm.com'),
  :name => 'Ram',
  :active => true
}

q = Cached::Queue.find_by_queue_name('WWNETK')

# Now we can make stuff

amnet_normal = RotationGroup.find_by_name(normal_name) || RotationGroup.create(:name => normal_name, :queue => q)
amnet_hot = RotationGroup.find_by_name(hot_name) || RotationGroup.create(:name => hot_name, :queue => q)

[ darshan, jim, luis, perry, tom, min, sangeetha, uma, bob, ram ].each do |u|
  amnet_normal.rotation_group_members.find_by_name(u[:name]) || amnet_normal.rotation_group_members.create(u)
end

[ jim, luis, perry, tom, min, sangeetha, uma, bob, ram ].each do |u|
  amnet_hot.rotation_group_members.find_by_name(u[:name]) || amnet_hot.rotation_group_members.create(u)
end

no_op = RotationType.find_by_name('no-op')

normal_assign = amnet_normal.rotation_types.find_by_name('Assign') ||
  amnet_normal.rotation_types.create(:name => 'Assign',
                                     :pmr_required => true,
                                     :comments => 'Assign a non-hot PMR',
                                     :next_type_id => no_op.id)

normal_skip = amnet_normal.rotation_types.find_by_name('Skip') ||
  amnet_normal.rotation_types.create(:name => 'Skip',
                                     :pmr_required => true,
                                     :comments => 'Credit for a HOT PMR',
                                     :next_type_id => no_op.id)

amnet_normal.rotation_types.find_by_name('Vacation') ||
  amnet_normal.rotation_types.create(:name => 'Vacation',
                                     :pmr_required => false,
                                     :comments => 'When team member is on vacation',
                                     :next_type_id => no_op.id)

amnet_normal.rotation_types.find_by_name('Temp Skip') ||
  amnet_normal.rotation_types.create(:name => 'Temp Skip',
                                     :pmr_required => false,
                                     :comments => 'When team member needs a little breathing room',
                                     :next_type_id => no_op.id)

amnet_normal.rotation_types.find_by_name('Overload') ||
  amnet_normal.rotation_types.create(:name => 'Overload',
                                     :pmr_required => false,
                                     :comments => 'When team member is overloaded',
                                     :next_type_id => no_op.id)


hot_assign = amnet_hot.rotation_types.find_by_name('Assign') ||
  amnet_hot.rotation_types.create(:name => 'Assign',
                                  :pmr_required => true,
                                  :comments => 'Assign a hot PMR',
                                  :next_type_id => normal_skip.id)

hot_ifix = amnet_hot.rotation_types.find_by_name('Hot IFix') ||
  amnet_hot.rotation_types.create(:name => 'Hot IFix',
                                  :pmr_required => true,
                                  :comments => 'Assign a hot IFix PMR',
                                  :next_type_id => no_op.id)

amnet_hot.rotation_types.find_by_name('Vacation') ||
  amnet_hot.rotation_types.create(:name => 'Vacation',
                                     :pmr_required => false,
                                     :comments => 'When team member is on vacation',
                                     :next_type_id => no_op.id)

amnet_hot.rotation_types.find_by_name('Temp Skip') ||
  amnet_hot.rotation_types.create(:name => 'Temp Skip',
                                     :pmr_required => false,
                                     :comments => 'When team member needs a little breathing room',
                                     :next_type_id => no_op.id)

amnet_hot.rotation_types.find_by_name('Overload') ||
  amnet_hot.rotation_types.create(:name => 'Overload',
                                     :pmr_required => false,
                                     :comments => 'When team member is overloaded',
                                     :next_type_id => no_op.id)

# Create four Temp Skips for each person in each group.
[ amnet_normal, amnet_hot ].each do |group|
  (1..4).each do |_notused|
    group.sorted_group_members.each do |member|
      RotationAssignment.create(:rotation_group_id => group.id,
                                :pmr => "",
                                :assigned_by => me.id,
                                :assigned_to => member.user.id,
                                :rotation_type_id => no_op.id,
                                :notes => "Just to fill the table")
    end
  end
end
