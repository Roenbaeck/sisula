-- Every view and function in the database, queried or called once. Snowflake compiles the body of a view or a function
-- only when it is used, so SQL that it cannot evaluate, such as a subquery of a kind that it does not support, shows
-- only then. tools/snowflake-tests.ps1 runs this after the tests, so that the views are queried over rows; a function
-- is called with nulls for its arguments, since what the perspectives show is for the tests to check.
EXECUTE IMMEDIATE $$
DECLARE
    objects CURSOR FOR
        SELECT
            'view ' || table_schema || '.' || table_name AS object_name,
            'SELECT count(*) FROM "' || table_schema || '"."' || table_name || '"' AS sql_text
        FROM
            information_schema.views
        WHERE
            table_schema <> 'INFORMATION_SCHEMA'
        UNION ALL
        SELECT
            'function ' || function_schema || '.' || function_name || argument_signature,
            iff(data_type LIKE 'TABLE%', 'SELECT count(*) FROM TABLE(', 'SELECT ')
            || '"' || function_schema || '"."' || function_name || '"'
            -- (CHANGINGTIMEPOINT TIMESTAMP_NTZ, SELECTION VARCHAR) becomes (null::TIMESTAMP_NTZ, null::VARCHAR)
            || regexp_replace(argument_signature, '[^(), ]+ ([A-Z_]+)', 'null::\\1')
            || iff(data_type LIKE 'TABLE%', ')', '')
        FROM
            information_schema.functions
        WHERE
            function_schema <> 'INFORMATION_SCHEMA'
        ORDER BY
            1;
    object_name VARCHAR;
    sql_text VARCHAR;
    error_text VARCHAR;
    ran INTEGER DEFAULT 0;
    failed INTEGER DEFAULT 0;
BEGIN
    FOR o IN objects DO
        object_name := o.object_name;
        sql_text := o.sql_text;
        ran := ran + 1;
        BEGIN
            EXECUTE IMMEDIATE :sql_text;
        EXCEPTION
            WHEN OTHER THEN
                failed := failed + 1;
                error_text := SQLERRM;
                INSERT INTO public.test_result (test, passed, detail) VALUES ('compile: ' || :object_name, false, :error_text);
        END;
    END FOR;
    INSERT INTO public.test_result (test, passed, detail)
    VALUES ('compile: every view and function runs', :failed = 0, (:ran - :failed) || ' of ' || :ran || ' ran');
    RETURN ran;
END;
$$;
