-- 
-- Insert default db values into liquid feedback
--

INSERT INTO system_setting (member_ttl) VALUES ('1 year');

INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 hour', 20, 6);

INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 day', 80, 12);

INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 hour', 200, 60);

INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 day', 800, 120);

INSERT INTO policy
    (id, index, active, name, description, polling, min_admission_time, max_admission_time, discussion_time, verification_time, voting_time, issue_quorum, issue_quorum_num, issue_quorum_den, initiative_quorum, initiative_quorum_num, initiative_quorum_den, defeat_strength, tie_breaking, direct_majority_num, direct_majority_den, direct_majority_strict, direct_majority_positive, direct_majority_non_negative, indirect_majority_num, indirect_majority_den, indirect_majority_strict, indirect_majority_positive, indirect_majority_non_negative, no_reverse_beat_path, no_multistage_majority)
VALUES 
    (1, 1, true, 'Default', '', false, '8 days', '14 days', '14 days', '7 days', '7 days', 1, 1, 100, 1, 1, 100, 'tuple', 'variant1', 50, 100, false, 0, 0, 50, 100, true, 0, 0, false, false);


INSERT INTO unit (name) VALUES ('Our organization');

INSERT INTO area (unit_id, name) VALUES (1, 'Default area');

INSERT INTO allowed_policy (area_id, policy_id, default_policy) VALUES (1, 1, TRUE);

-- Admin user with empty password
INSERT INTO member (login, name, admin, password, activated, last_activity)
VALUES ('admin', 'Administrator', TRUE, '$6$XafBXjY3oMahH7a5$8XdJTz0vSUDweK/29uGIYJe7R8/26UORsTI4nOGSCd5HEFeW1xDWgjRuJaRhnQoO5wP.RwyEWxv5JFwvuUN7o/', NOW(), NOW());
