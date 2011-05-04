class CreateNoCycles < ActiveRecord::Migration
  def self.up
    execute "
      CREATE FUNCTION no_cycles(container_name_id integer,
                                item_id integer,
                                item_type character varying) RETURNS boolean AS $$
      DECLARE
        container_name_type character varying;
        temp_level integer;

      BEGIN
        SELECT type INTO container_name_type FROM names WHERE id = container_name_id;
        IF NOT FOUND THEN
          RETURN false;
        END IF;
        SELECT level INTO temp_level FROM nestings n WHERE n.container_id   = item_id AND
                                                           n.container_type = item_type AND
                                                           n.item_id        = container_name_id AND
                                                           n.item_type      = container_name_type;
        IF FOUND THEN
          RETURN false;
        END IF;
        RETURN true;
      END;
      $$ LANGUAGE plpgsql;"
  end

  def self.down
    execute "
      DROP FUNCTION no_cycles(container_name_id integer,
                              item_id integer,
                              item_type character varying)"
  end
end
