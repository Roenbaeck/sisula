-- What the triggers and the perspectives of a uni-temporal Anchor model do in Oracle, for the model oracle-triggers.
--
-- Run it with SQL*Plus (or SQLcl) in an empty schema, after the generated script and the deploy check:
--
--     sqlplus user/password@service @golden/oracle-triggers/_full.sql
--     sqlplus user/password@service @tools/oracle-tests/deploy.sql
--     sqlplus user/password@service @tools/oracle-tests/triggers-uni.sql
--
-- Every check is a row in the table test_result (test, passed, detail), which is listed at the end; the script rolls back what it
-- does to the model's tables, except for the knots, which it leaves. (None of the generated SQL had been run on an Oracle server
-- when this was written: a failure here is as likely to be in this script as in the templates, so read both.)
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
SET LINESIZE 200
SET PAGESIZE 100
WHENEVER SQLERROR CONTINUE

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE test_result';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE test_result (test VARCHAR2(200), passed NUMBER(1), detail VARCHAR2(4000));

CREATE OR REPLACE PROCEDURE check_that (p_test IN VARCHAR2, p_ok IN BOOLEAN, p_detail IN VARCHAR2 DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO test_result VALUES (p_test, CASE WHEN p_ok THEN 1 ELSE 0 END, p_detail);
    COMMIT;
END check_that;
/

-- the knot of the grades (its identities are not generated)
INSERT INTO GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) VALUES (1, 'A', 1);
INSERT INTO GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) VALUES (2, 'B', 1);
COMMIT;

DECLARE
    v_id NUMBER;
    v_count NUMBER;
    v_text VARCHAR2(4000);
    v_code NUMBER;
    v_start TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
BEGIN
    -- an insert through the latest view makes the anchor, and the attributes that have a value
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_COD_Subject_Code, SU_GRD_GRD_Grade, SU_TTL_Subject_Title, SU_TTL_ChangedAt)
    VALUES (1, 'Alpha', 'A-1', 'A', 'First title', v_start);
    SELECT MAX(SU_ID) INTO v_id FROM SU_Subject;
    check_that('insert: the anchor is made', v_id IS NOT NULL);
    SELECT COUNT(*) INTO v_count FROM SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = v_id;
    check_that('insert: a static attribute is stored', v_count = 1);
    SELECT COUNT(*) INTO v_count FROM SU_GRD_Subject_Grade WHERE SU_GRD_SU_ID = v_id AND SU_GRD_GRD_ID = 1;
    check_that('insert: a knotted attribute given by its value gets the identity of the knot value', v_count = 1);
    SELECT COUNT(*) INTO v_count FROM SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = v_id AND SU_TTL_ChangedAt = v_start;
    check_that('insert: a historized attribute gets the changing time that was given', v_count = 1);

    -- the latest view shows what was stored
    SELECT SU_NAM_Subject_Name INTO v_text FROM lSU_Subject WHERE SU_ID = v_id;
    check_that('latest view shows the name', v_text = 'Alpha', v_text);

    -- another version of a historized attribute is a new row, and the latest view shows the newest
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 'Second title', SU_TTL_ChangedAt = v_start + INTERVAL '1' DAY WHERE SU_ID = v_id;
    SELECT COUNT(*) INTO v_count FROM SU_TTL_Subject_Title WHERE SU_TTL_SU_ID = v_id;
    check_that('update: a new version of a historized attribute is a new row', v_count = 2, 'rows: ' || v_count);
    SELECT SU_TTL_Subject_Title INTO v_text FROM lSU_Subject WHERE SU_ID = v_id;
    check_that('update: the latest view shows the newest version', v_text = 'Second title', v_text);

    -- the point-in-time perspective (a table macro) shows the version in effect at a time, and the now perspective the latest
    SELECT SU_TTL_Subject_Title INTO v_text FROM pSU_Subject(v_start + INTERVAL '12' HOUR) WHERE SU_ID = v_id;
    check_that('point in time: the first version at noon on the first day', v_text = 'First title', v_text);
    SELECT SU_TTL_Subject_Title INTO v_text FROM nSU_Subject WHERE SU_ID = v_id;
    check_that('now perspective: the newest version', v_text = 'Second title', v_text);

    -- a static attribute cannot get another value: a contradiction
    BEGIN
        UPDATE lSU_Subject SET SU_NAM_Subject_Name = 'Beta' WHERE SU_ID = v_id;
        check_that('update: another value of a static attribute is a contradiction', FALSE, 'no error');
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        check_that('update: another value of a static attribute is a contradiction', v_code = -20001, SQLERRM);
    END;

    -- the same value again states nothing
    UPDATE lSU_Subject SET SU_NAM_Subject_Name = 'Alpha' WHERE SU_ID = v_id;
    SELECT COUNT(*) INTO v_count FROM SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = v_id;
    check_that('update: the same value again states nothing', v_count = 1, 'rows: ' || v_count);

    -- the identity cannot be updated
    BEGIN
        UPDATE lSU_Subject SET SU_ID = v_id + 1000 WHERE SU_ID = v_id;
        check_that('update: the identity is not updatable', FALSE, 'no error');
    EXCEPTION WHEN OTHERS THEN
        check_that('update: the identity is not updatable', SQLCODE = -20003, SQLERRM);
    END;

    -- a deletable attribute: a null with the deletable column set moves what there is to the deletion table
    UPDATE lSU_Subject SET Deletable_SU_NAM = 1, SU_NAM_Subject_Name = NULL WHERE SU_ID = v_id;
    SELECT COUNT(*) INTO v_count FROM SU_NAM_Subject_Name WHERE SU_NAM_SU_ID = v_id;
    check_that('update: a deleted value is gone from the attribute table', v_count = 0, 'rows: ' || v_count);
    SELECT COUNT(*) INTO v_count FROM SU_NAM_Subject_Name_Deleted WHERE SU_NAM_SU_ID = v_id;
    check_that('update: a deleted value is in the deletion table', v_count = 1, 'rows: ' || v_count);

    -- a delete through the view removes the anchor when no attribute has a row left
    DELETE FROM lSU_Subject WHERE SU_ID = v_id;
    SELECT COUNT(*) INTO v_count FROM SU_Subject WHERE SU_ID = v_id;
    check_that('delete: the anchor is removed', v_count = 0, 'rows: ' || v_count);

    -- a tie through its latest view, between two anchors made the same way
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name) VALUES (1, 'One');
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name) VALUES (1, 'Two');
    DECLARE
        v_one NUMBER;
        v_two NUMBER;
    BEGIN
        SELECT SU_ID INTO v_one FROM lSU_Subject WHERE SU_NAM_Subject_Name = 'One';
        SELECT SU_ID INTO v_two FROM lSU_Subject WHERE SU_NAM_Subject_Name = 'Two';
        INSERT INTO lSU_partner_SU_with (Metadata_SU_partner_SU_with, SU_partner_SU_with_ChangedAt, SU_ID_partner, SU_ID_with)
        VALUES (1, v_start, v_one, v_two);
        SELECT COUNT(*) INTO v_count FROM SU_partner_SU_with WHERE SU_ID_partner = v_one AND SU_ID_with = v_two;
        check_that('tie: an insert through the latest view stores the row', v_count = 1, 'rows: ' || v_count);
        BEGIN
            INSERT INTO lSU_partner_SU_with (Metadata_SU_partner_SU_with, SU_partner_SU_with_ChangedAt, SU_ID_partner, SU_ID_with)
            VALUES (1, v_start, v_one, v_two);
            SELECT COUNT(*) INTO v_count FROM SU_partner_SU_with WHERE SU_ID_partner = v_one AND SU_ID_with = v_two;
            check_that('tie: the identical row is not stored again', v_count = 1, 'rows: ' || v_count);
        EXCEPTION WHEN OTHERS THEN
            check_that('tie: the identical row is not stored again', FALSE, SQLERRM);
        END;
        -- a nexus through its latest view, with a role and an attribute
        INSERT INTO lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity) VALUES (1, v_one, 5);
        SELECT COUNT(*) INTO v_count FROM EV_Event WHERE SU_ID_for = v_one;
        check_that('nexus: an insert through the latest view makes the nexus and its role', v_count = 1, 'rows: ' || v_count);
        SELECT COUNT(*) INTO v_count FROM EV_QTY_Event_Quantity;
        check_that('nexus: an insert through the latest view stores its attribute', v_count = 1, 'rows: ' || v_count);
    END;

EXCEPTION WHEN OTHERS THEN
    check_that('the script ran to its end', FALSE, SQLERRM);
END;
/
ROLLBACK;

SET PAGESIZE 0
SELECT CASE passed WHEN 1 THEN 'PASS  ' ELSE 'FAIL  ' END || test || CASE WHEN passed = 0 AND detail IS NOT NULL THEN ': ' || detail END FROM test_result;
SELECT 'checks: ' || COUNT(*) || ', failed: ' || SUM(CASE passed WHEN 0 THEN 1 ELSE 0 END) FROM test_result;
