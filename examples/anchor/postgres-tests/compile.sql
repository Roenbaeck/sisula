-- Every view and function in the database, queried or called once. PostgreSQL checks the body of a function in SQL when it
-- is made, but a view or a function can still fail over rows (a division by nothing, a cast), so tools/postgres-tests.ps1 runs this
-- after the tests, when the views are queried over rows. A function is called with nulls for its arguments, since what the
-- perspectives show is for the tests to check.
DO $$
DECLARE
    o record;
    ran integer := 0;
    failed integer := 0;
BEGIN
    FOR o IN
        SELECT
            'view ' || n.nspname || '.' || c.relname AS object_name,
            'SELECT count(*) FROM ' || quote_ident(n.nspname) || '.' || quote_ident(c.relname) AS sql_text
        FROM
            pg_class c
        JOIN
            pg_namespace n ON n.oid = c.relnamespace
        WHERE
            c.relkind = 'v'
        AND
            n.nspname NOT IN ('pg_catalog', 'information_schema')
        UNION ALL
        SELECT
            'function ' || n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')',
            CASE WHEN p.proretset THEN 'SELECT count(*) FROM ' ELSE 'SELECT ' END
            || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '('
            || coalesce((SELECT string_agg('null::' || format_type(t, null), ', ' ORDER BY i) FROM unnest(p.proargtypes::oid[]) WITH ORDINALITY AS a(t, i)), '')
            || ')'
        FROM
            pg_proc p
        JOIN
            pg_namespace n ON n.oid = p.pronamespace
        WHERE
            n.nspname NOT IN ('pg_catalog', 'information_schema')
        AND
            p.prokind = 'f'
        ORDER BY
            1
    LOOP
        ran := ran + 1;
        BEGIN
            EXECUTE o.sql_text;
        EXCEPTION
            WHEN OTHERS THEN
                failed := failed + 1;
                INSERT INTO public.test_result (test, passed, detail) VALUES ('compile: ' || o.object_name, false, SQLERRM);
        END;
    END LOOP;
    INSERT INTO public.test_result (test, passed, detail)
    VALUES ('compile: every view and function runs', failed = 0, (ran - failed) || ' of ' || ran || ' ran');
END;
$$;
