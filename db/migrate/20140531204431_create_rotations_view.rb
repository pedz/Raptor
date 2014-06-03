class CreateRotationsView < ActiveRecord::Migration
  def self.up
    execute <<-EOF
      CREATE OR REPLACE VIEW rotations AS
      SELECT
        a.id as "id",
        g.name as "rotation_group",
        a.pmr as "pmr",
        u_by.ldap_id as "assigned_by",
        u_to.ldap_id as "assigned_to",
        a.notes as "notes",
        t.name as "rotation_type",
        a.created_at as "created_at",
        a.updated_at as "updated_at"
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
