class AddConstraints < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE users ADD CONSTRAINT uq_ldap_id UNIQUE (ldap_id)"

    execute "ALTER TABLE retusers ADD CONSTRAINT uq_retusers_user_id UNIQUE (user_id)"
    execute "ALTER TABLE retusers ADD CONSTRAINT uq_retusers_retid UNIQUE (retid)"
    execute "ALTER TABLE retusers ADD CONSTRAINT fk_retusers_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)
             ON DELETE CASCADE"

    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"

    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT uq_cached_queue_infos_queue_owner
             UNIQUE (queue_id, owner_id)"
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT fk_cached_queue_infos_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT fk_cached_queue_infos_owner_id
             FOREIGN KEY (owner_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"

    execute "ALTER TABLE cached_queues ADD CONSTRAINT uq_cached_queues_triple
             UNIQUE (queue_name, center, h_or_s)"

    execute "ALTER TABLE cached_calls ADD CONSTRAINT uq_cached_calls_pair
             UNIQUE (queue_id, ppg)"
    execute "ALTER TABLE cached_calls ADD CONSTRAINT fk_cached_calls_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_calls ADD CONSTRAINT fk_cached_calls_pmr_id
             FOREIGN KEY (pmr_id) REFERENCES cached_pmrs(id)
             ON DELETE CASCADE"

    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT uq_cached_pmrs_triple
             UNIQUE (problem, branch, country)"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_owner_id
             FOREIGN KEY (owner_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_resolver_id
             FOREIGN KEY (resolver_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"

    execute "ALTER TABLE cached_text_lines ADD CONSTRAINT uq_cached_text_lines_triple
             UNIQUE (pmr_id, line_type, line_number)"
    execute "ALTER TABLE cached_text_lines ADD CONSTRAINT fk_cached_text_lines_pmr_id
             FOREIGN KEY (pmr_id) REFERENCES cached_pmrs(id)
             ON DELETE CASCADE"
    
    execute "ALTER TABLE feedback_notes ADD CONSTRAINT fk_feedback_notes_feedback_id
             FOREIGN KEY (feedback_id) REFERENCES feedbacks(id)
             ON DELETE CASCADE"
    
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT uq_cached_registrations_signon
             UNIQUE (signon)"
  end

  def self.down
    execute "ALTER TABLE users DROP CONSTRAINT uq_ldap_id"
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_user_id"
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_retid"
    execute "ALTER TABLE retusers DROP CONSTRAINT fk_retusers_user_id"
    execute "ALTER TABLE favorite_queues DROP CONSTRAINT fk_favorite_queue_user_id"
    execute "ALTER TABLE favorite_queues DROP CONSTRAINT fk_favorite_queue_queue_id"
    execute "ALTER TABLE cached_queue_infos DROP CONSTRAINT uq_cached_queue_infos_queue_owner"
    execute "ALTER TABLE cached_queue_infos DROP CONSTRAINT fk_cached_queue_infos_queue_id"
    execute "ALTER TABLE cached_queue_infos DROP CONSTRAINT fk_cached_queue_infos_owner_id"
    execute "ALTER TABLE cached_queues DROP CONSTRAINT uq_cached_queues_triple"
    execute "ALTER TABLE cached_calls DROP CONSTRAINT uq_cached_calls_pair"
    execute "ALTER TABLE cached_calls DROP CONSTRAINT fk_cached_calls_queue_id"
    execute "ALTER TABLE cached_calls DROP CONSTRAINT fk_cached_calls_pmr_id"
    execute "ALTER TABLE cached_pmrs DROP CONSTRAINT uq_cached_pmrs_triple"
    execute "ALTER TABLE cached_pmrs DROP CONSTRAINT fk_cached_pmrs_owner_id"
    execute "ALTER TABLE cached_pmrs DROP CONSTRAINT fk_cached_pmrs_resolver_id"
    execute "ALTER TABLE cached_text_lines DROP CONSTRAINT uq_cached_text_lines_triple"
    execute "ALTER TABLE cached_text_lines DROP CONSTRAINT fk_cached_text_lines_pmr_id"
    execute "ALTER TABLE feedback_notes DROP CONSTRAINT fk_feedback_notes_feedback_id"
    execute "ALTER TABLE cached_registrations DROP CONSTRAINT uq_cached_registrations_signon"
  end
end
