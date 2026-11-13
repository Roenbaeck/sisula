-- Checks a deployed Anchor model in Oracle: nothing is invalid, every view can be queried, every table macro can be called.
--
-- Run it with SQL*Plus (or SQLcl) in the schema that the generated script was run in, right after the script:
--
--     sqlplus user/password@service @golden/oracle-triggers/_full.sql
--     sqlplus user/password@service @tools/oracle-tests/deploy.sql
--
-- It prints one line for every check that fails and ends with a summary. Nothing is changed in the model.
-- (None of the generated SQL has been run on an Oracle server when this was written; what this finds is the first news from one.)
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
SET LINESIZE 200
SET PAGESIZE 0

DECLARE
    v_failed NUMBER := 0;
    v_checked NUMBER := 0;
    v_count NUMBER;
    PROCEDURE report(p_what IN VARCHAR2) IS
    BEGIN
        v_failed := v_failed + 1;
        DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_what);
    END report;
BEGIN
    -- 1. what did not compile (triggers and procedures that name something wrong are invalid; the errors say what)
    FOR o IN (SELECT object_name, object_type FROM user_objects WHERE status = 'INVALID' ORDER BY object_type, object_name) LOOP
        v_checked := v_checked + 1;
        BEGIN
            EXECUTE IMMEDIATE 'ALTER ' || CASE o.object_type WHEN 'PACKAGE BODY' THEN 'PACKAGE' ELSE o.object_type END || ' ' || o.object_name || ' COMPILE';
        EXCEPTION WHEN OTHERS THEN
            NULL;   -- the errors are read from USER_ERRORS below
        END;
    END LOOP;
    FOR e IN (SELECT name, type, line, position, text FROM user_errors ORDER BY name, sequence) LOOP
        report(e.type || ' ' || e.name || ' (' || e.line || ',' || e.position || '): ' || e.text);
    END LOOP;
    FOR o IN (SELECT object_name, object_type FROM user_objects WHERE status = 'INVALID' ORDER BY object_type, object_name) LOOP
        report('invalid ' || o.object_type || ' ' || o.object_name);
    END LOOP;

    -- 2. every view can be queried (a view over a table macro is expanded when it is queried)
    FOR v IN (SELECT view_name FROM user_views ORDER BY view_name) LOOP
        v_checked := v_checked + 1;
        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (SELECT * FROM ' || v.view_name || ' WHERE ROWNUM <= 1)' INTO v_count;
        EXCEPTION WHEN OTHERS THEN
            report('view ' || v.view_name || ': ' || SQLERRM);
        END;
    END LOOP;

    -- 3. every table macro can be called, with null arguments (the parameters are what the macro text is written around)
    FOR f IN (
        SELECT
            o.object_name,
            LISTAGG('NULL', ', ') WITHIN GROUP (ORDER BY a.position) AS arguments
        FROM
            user_objects o
        JOIN
            user_arguments a ON a.object_name = o.object_name AND a.position > 0 AND a.package_name IS NULL
        WHERE
            o.object_type = 'FUNCTION'
        AND
            EXISTS (SELECT 1 FROM user_source s WHERE s.name = o.object_name AND s.type = 'FUNCTION' AND UPPER(s.text) LIKE '%SQL_MACRO%')
        GROUP BY
            o.object_name
        ORDER BY
            o.object_name
    ) LOOP
        v_checked := v_checked + 1;
        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (SELECT * FROM ' || f.object_name || '(' || f.arguments || ') WHERE ROWNUM <= 1)' INTO v_count;
        EXCEPTION WHEN OTHERS THEN
            report('macro ' || f.object_name || ': ' || SQLERRM);
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_failed = 0 THEN 'All ' || v_checked || ' checks passed.' ELSE v_failed || ' of the findings above; ' || v_checked || ' checks made.' END);
END;
/
