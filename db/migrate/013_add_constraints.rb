class AddConstraints < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE users ADD CONSTRAINT uq_ldap_id UNIQUE (ldap_id)"

    execute "ALTER TABLE retusers ADD CONSTRAINT uq_retusers_user_id UNIQUE (user_id)"
    execute "ALTER TABLE retusers ADD CONSTRAINT uq_retusers_retid UNIQUE (retid)"
    execute "ALTER TABLE retusers ADD CONSTRAINT fk_retusers_user_id
             FOREIGN KEY (user_id) users(id)"

    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_user_id
             FOREIGN KEY (user_id) users(id)"
    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_queue_id
             FOREIGN KEY (queue_id) cached_queues(id)"

    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT uq_cached_queue_infos_queue_owner
             UNIQUE (queue_id, owner_id)"
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT fk_cached_queue_infos_queue_id
             FOREIGN KEY (queue_id) cached_queues(id)"
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT fk_cached_queue_infos_owner_id
             FOREIGN KEY (owner_id) retusers(id)"

    execute "ALTER TABLE cached_queues ADD CONSTRAINT uq_cached_queues_triple
             UNIQUE (queue_name, center, h_or_s)"

    execute "ALTER TABLE cached_calls ADD CONSTRAINT uq_cached_calls_pair
             UNIQUE (queue_id, ppg)"
    execute "ALTER TABLE cached_calls ADD CONSTRAINT fk_cached_calls_queue_id
             FOREIGN KEY (queue_id) cached_queues(id)"
    execute "ALTER TABLE cached_calls ADD CONSTRAINT fk_cached_calls_pmr_id
             FOREIGN KEY (pmr_id) cached_pmrs(id)"

    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT uq_cached_pmrs_triple
             UNIQUE (problem, branch, country)"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_owner_id
             FOREIGN KEY (owner_id) cached_registrations(id)"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_resolver_id
             FOREIGN KEY (resolver_id) cached_registrations(id)"

    execute "ALTER TABLE cached_text_lines ADD CONSTRAINT uq_cached_text_lines_triple
             UNIQUE (pmr_id, line_type, line_number)"
    execute "ALTER TABLE cached_text_lines ADD CONSTRAINT fk_cached_text_lines_pmr_id
             FOREIGN KEY (pmr_id) cached_pmrs(id)"
    
    execute "ALTER TABLE feedback_notes ADD CONSTRAINT fk_feedback_notes_feedback_id
             FOREIGN KEY (feedback_id) feedbacks(id)"
    
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT uq_cached_registrations_signon
             UNIQUE (signon)"
  end

  def self.down
  end
end
