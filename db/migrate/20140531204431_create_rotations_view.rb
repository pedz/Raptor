class CreateRotationsView < ActiveRecord::Migration
  def self.up
    execute <<-EOF
      CREATE OR REPLACE VIEW rotations AS
      SELECT
        g.name as "Group",
        t.name as "Type",
        a.pmr as "PMR",
        u_to.ldap_id as "To",
        u_by.ldap_id as "By",
        a.notes as "Notes",
        a.created_at as "Created",
        a.updated_at as "Updated"
      FROM
        rotation_groups g,
        rotation_assignments a,
        rotation_types t,
        users u_to,
        users u_by
      WHERE
        a.rotation_group_id = g.id AND
        a.rotation_type_id = t.id AND
        a.assigned_to = u_to.id AND
        a.assigned_by = u_by.id
      ORDER BY a.created_at
      ;
      EOF
  end

  def self.down
    execute "DROP VIEW rotations;"
  end
end
