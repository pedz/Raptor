# -*- coding: utf-8 -*-
class CreateNoCycles < ActiveRecord::Migration
  def self.up
    execute "CREATE LANGUAGE plpgsql;"
    execute "
      CREATE FUNCTION no_cycles(container_name_id integer,
                                itemId integer,
                                itemType character varying) RETURNS boolean AS $$
      DECLARE
        container_name_type character varying;
        temp_level integer;

      BEGIN
        SELECT
          nt.base_type INTO container_name_type
        FROM
          names n,
          name_types nt
        WHERE
          n.id = container_name_id AND
          n.type = nt.name
        ;
        IF NOT FOUND THEN
          RETURN false;
        END IF;
        SELECT level INTO temp_level FROM nestings n WHERE n.container_id   = itemId AND
                                                           n.container_type = itemType AND
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
    execute "DROP LANGUAGE plpgsql;"
  end
end
