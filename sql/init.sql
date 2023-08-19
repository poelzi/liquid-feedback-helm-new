-- NOTE: This file creates an admin user with an empty password!

BEGIN;

INSERT INTO "unit" (
        "active",
        "name",
        "description"
    ) VALUES (
        true,
        'Default unit',
        'Default unit created by init script.'
    );
        

-- INSERT INTO "member" (
--         "login",
--         "password",
--         "active",
--         "admin",
--         "name",
--         "activated",
--         "last_activity"
--     ) VALUES (
--         'admin',
--         '$1$.EMPTY.$LDufa24OE2HZFXAXh71Eb1',
--         TRUE,
--         TRUE,
--         'Administrator',
--         NOW(),
--         NOW()
--     );

-- INSERT INTO "policy" (
--         "index",
--         "active",
--         "name",
--         "description",
--         "polling",
--         "min_admission_time",
--         "max_admission_time",
--         "discussion_time",
--         "verification_time",
--         "voting_time",
--         -- "issue_quorum_num",
--         -- "issue_quorum_den",
--         "initiative_quorum",
--         "initiative_quorum_num",
--         "initiative_quorum_den"
--     ) VALUES (
--         1,
--         TRUE,
--         'Extensive proceeding',
--         DEFAULT,
--         FALSE,
--         '1 month',
--         '1 month',
--         '5 months',
--         '1 month',
--         '3 weeks',
--         -- 10, 100,
--         -- NULL, NULL,
--         1,
--         10, 100
--     );
    -- ), (
    --     2,
    --     TRUE,
    --     'Standard proceeding',
    --     DEFAULT,
    --     FALSE,
    --     '1 month',
    --     '1 month',
    --     '1 month',
    --     '1 week',
    --     '1 week',
    --     -- 10, 100,
    --     NULL, NULL,
    --     1,
    --     10, 100
    -- ), (
    --    3,
    --    TRUE,
    --    'Fast proceeding',
    --    DEFAULT,
    --    FALSE,
    --    '48 hours',
    --    '48 hours',
    --    '3 hours',
    --    '1 hour',
    --    '20 hours',
    --     -- 1, 100,
    --     NULL, NULL,
    --     1,
    --     1, 100 );
INSERT INTO public.policy VALUES (1, 1, true, 'Extensive proceeding', '', false, '15 days', '30 days', '30 days', '5 mons', '1 mon', 1, 1, 100, 1, 1, 100, 'tuple', 'variant1', 50, 100, false, 0, 0, 50, 100, true, 0, 0, false, false);
INSERT INTO public.policy VALUES (2, 1, true, 'Standard proceeding', '', false, '00:00:00', '30 days', '1 mon', '7 days', '7 days', 1, 1, 100, 1, 1, 100, 'tuple', 'variant1', 50, 100, false, 0, 0, 50, 100, true, 0, 0, false, false);
INSERT INTO public.policy VALUES (3, 1, true, 'Fast proceeding', '', false, '00:00:00', '48:00:00', '03:00:00', '01:00:00', '20:00:00', 1, 1, 100, 1, 1, 100, 'tuple', 'variant1', 50, 100, false, 0, 0, 50, 100, true, 0, 0, false, false);


INSERT INTO "area" (
        "unit_id",
        "active",
        "name",
        "description"
    ) VALUES (
        1,
        TRUE,
        'Generic area',
        DEFAULT );

COMMIT;
