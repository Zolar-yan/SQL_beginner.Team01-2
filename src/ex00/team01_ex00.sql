WITH 
    users AS (
        SELECT 
            COALESCE(name, 'not defined') AS name,
            COALESCE(lastname, 'not defined') AS lastname,
      id
        FROM public.user
    ),
    balances AS (
        SELECT 
            b.user_id,
            b.currency_id,
            b.type,
            SUM(b.money) AS volume
        FROM balance b
        GROUP BY b.user_id, b.currency_id, b.type
    ),
    currencies AS (
        SELECT 
            c.id,
            COALESCE(c.name, 'not defined') as name,
            COALESCE(
                (SELECT c2.rate_to_usd
                 FROM currency c2
                 WHERE c2.name = c.name
                 ORDER BY c2.id DESC
                 LIMIT 1),
                1
            ) AS rate_to_usd
        FROM currency c
        GROUP BY c.id, c.name
    )
SELECT 
    COALESCE(u.name, 'not defined') AS name,
    COALESCE(u.lastname, 'not defined') AS lastname,
    b.type,
    b.volume,
     COALESCE(c.name, 'not defined') AS currency_name,
     COALESCE(c.rate_to_usd , 1) AS last_rate_to_usd,
    COALESCE(b.volume * c.rate_to_usd, b.volume) AS total_volume_in_usd
FROM users u
FULL OUTER JOIN balances b ON u.id = b.user_id
FULL OUTER JOIN currencies c ON b.currency_id = c.id
ORDER BY 1 DESC,2,3;
