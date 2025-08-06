insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

CREATE OR REPLACE FUNCTION nearest_rate(p_cur_id BIGINT, p_date TIMESTAMP) RETURNS NUMERIC AS $$
DECLARE
    res NUMERIC = NULL;
BEGIN
    SELECT rate_to_usd
    INTO res
    FROM currency C
    WHERE C.id = p_cur_id
    ORDER BY ABS(EXTRACT(EPOCH FROM (C.updated - p_date)))  
    LIMIT 1;

    RETURN res;
END;
$$ LANGUAGE plpgsql;

SELECT
    COALESCE(U.name, 'not defined') AS name,
    COALESCE(U.lastname, 'not defined') AS lastname,
    C.name AS name,
    (B.money * nearest_rate (B.currency_id, b.updated)) AS currency_in_usd
FROM balance B
    LEFT JOIN "user" U ON B.user_id = U.id
    LEFT JOIN (
        SELECT DISTINCT id, name from currency
    ) C ON c.id = B.currency_id
WHERE
    C.name is not NULL
ORDER BY 1 DESC, 2, 3;



