module Combined
  class Component < Base
    set_expire_time 1.year

    set_db_keys :short_component_name
    add_skipped_fields :short_component_name

    add_extra_fields :multiple_rls_table_entry
    add_skipped_fields :valid, :start_date, :end_date # db fields

    set_db_constants :component_name, :release_name
  end
end
