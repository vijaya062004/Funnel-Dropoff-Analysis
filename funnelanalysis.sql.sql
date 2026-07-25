create database analysis
go
select*
from dbo.funnel_events_sample
-------
WITH stage_count AS
(
    SELECT
        step,
        COUNT(DISTINCT user_id) AS users
    FROM dbo.funnel_events_sample
    GROUP BY step
),
conversion AS
(
    SELECT
        step,
        users,
        LAG(users) OVER (
            ORDER BY
            CASE step
                WHEN 'visited_site' THEN 1
                WHEN 'signup_started' THEN 2
                WHEN 'details_filled' THEN 3
                WHEN 'email_verified' THEN 4
                WHEN 'purchase_completed' THEN 5
            END
        ) AS previous_users
    FROM stage_count
)
SELECT
    step,
    users,
    previous_users,
    CASE
        WHEN previous_users IS NULL THEN '100%'
        ELSE CONCAT( CAST(users * 100.0 / previous_users AS DECIMAL(5,2)),'%'
)
END AS conversion_rate
FROM conversion;
WITH stage_count AS
(
    SELECT
        step,
        COUNT(DISTINCT user_id) AS users
    FROM dbo.funnel_events_sample
    GROUP BY step
),

dropoff AS
(
    SELECT
        step,
        users,

        LAG(users) OVER
        (
            ORDER BY
            CASE step
                WHEN 'visited_site' THEN 1
                WHEN 'signup_started' THEN 2
                WHEN 'details_filled' THEN 3
                WHEN 'email_verified' THEN 4
                WHEN 'purchase_completed' THEN 5
            END
        ) AS previous_users

    FROM stage_count
)

SELECT
    step,
    users,
    previous_users,
    previous_users - users AS drop_off
FROM dropoff;