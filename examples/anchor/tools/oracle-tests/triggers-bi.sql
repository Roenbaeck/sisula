-- What the triggers and the perspectives of a bitemporal Anchor model do in Oracle, for the model oracle-triggers-bi.
--
-- Run it with SQL*Plus (or SQLcl) in an empty schema, after the generated script and the deploy check:
--
--     sqlplus user/password@service @golden/oracle-triggers-bi/_full.sql
--     sqlplus user/password@service @tools/oracle-tests/deploy.sql
--     sqlplus user/password@service @tools/oracle-tests/triggers-bi.sql
--
-- Every check is a row in the table test_result (test, passed, detail), which is listed at the end; the script rolls back what it
-- does to the model's tables, except for the knots, which it leaves. (None of the generated SQL had been run on an Oracle server
-- when this was written: a failure here is as likely to be in this script as in the templates, so read both.)
--
-- It is a translation, check by check, of postgres-tests/triggers-bi.sql (which has been run on PostgreSQL 16, and states what
-- the bitemporal triggers must do), and the checks have the same names, so a failure can be compared across databases. The
-- groups are numbered as there (b01 and so on). What differs, because the databases do:
--   - A check that expects an error catches it in a block of its own; the error is told by its code (SQLCODE: -20001 is a
--     contradiction, -20002 a restatement, -20003 something that is not updatable), and the text is looked for in SQLERRM
--     (which starts with ORA-20001: and so on, where PostgreSQL's message started with the text itself).
--   - Oracle undoes a statement that fails, with what its triggers did, so the statements that are expected to fail leave nothing
--     behind (a call of an ip_ procedure that is caught would leave what it did before it failed; this script has no such call:
--     the statements are the INSERTs, UPDATEs and DELETEs that the PostgreSQL test has).
--   - Every group is a block of its own, which reports an error that it did not expect as a failed check named "bNN the group ran
--     to its end", so one group does not stop the others. The groups use rows of their own, as the PostgreSQL ones do.
--   - The times are given explicitly where the rule does not depend on now. Where the PostgreSQL test left a time to now, so does
--     this one; a trigger takes now, a timestamp of microseconds, when it starts, so that two statements about the same posit
--     get positing times of their own if the clock of the server moves between them (a server on Windows has a coarser clock,
--     a few milliseconds: if a check about a posit that is stated twice fails with a primary key error on the annex table,
--     run it again).
--   - An insert of several rows is an INSERT ... SELECT ... FROM dual UNION ALL ... (there is no multi-row VALUES in Oracle). An
--     instead-of trigger is run once for each row of it.
--   - The nclob attributes (the note and the text) are compared with DBMS_LOB.COMPARE, and read through DBMS_LOB.SUBSTR; a
--     nclob cannot be compared with = in a query.
--   - The difference perspective is a table macro (SQL_MACRO), which is called in dynamic SQL here, as deploy.sql does.
--   - The posit tables of the attributes with a checksum (the note and the text) have no checksum column here, as in the
--     uni-temporal Oracle model: they are nclob columns, so what PostgreSQL's test states about the checksum is stated here
--     about the nclob.
-- Not run: b19 (the keys of the assembled views, which are indexes in SQL Server; here the annex tables have a key of their own,
-- as in PostgreSQL), and the deletable attributes, which the PostgreSQL test does not run either (the attribute SU_ERS is
-- deletable in the model, and the bitemporal templates handle it as any other attribute; b01 inserts a value of it).
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
SET DEFINE OFF
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
    INSERT INTO test_result VALUES (p_test, CASE WHEN p_ok THEN 1 ELSE 0 END, SUBSTR(p_detail, 1, 4000));
    COMMIT;
END check_that;
/

-- the knot of the grades (its identities are not generated); a row that is there already is left as it is
INSERT INTO GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) SELECT 1, 'A', 0 FROM dual WHERE NOT EXISTS (SELECT 1 FROM GRD_Grade WHERE GRD_ID = 1);
INSERT INTO GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) SELECT 2, 'B', 0 FROM dual WHERE NOT EXISTS (SELECT 1 FROM GRD_Grade WHERE GRD_ID = 2);
INSERT INTO GRD_Grade (GRD_ID, GRD_Grade, Metadata_GRD) SELECT 3, 'C', 0 FROM dual WHERE NOT EXISTS (SELECT 1 FROM GRD_Grade WHERE GRD_ID = 3);
COMMIT;

-- b01 an insert through the latest view: a posit and an assertion for each value
DECLARE
    v_s NUMBER;
    v_posits NUMBER;
    v_assertions NUMBER;
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_COD_Subject_Code, SU_GRD_GRD_ID, SU_NOT_Subject_Note,
        SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt, SU_LBL_Subject_Label, SU_LBL_ChangedAt,
        SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt,
        SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ERS_Subject_Erasable, SU_ERS_ChangedAt)
    VALUES (0, 'name', 'code', 1, 'note', 'title', t20200101, 'state', t20200101, 'label', t20200101,
        'tag', t20200101, 1, t20200101, 'text', t20200101, 'assessment', t20200101, 'erasable', t20200101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    SELECT
        (SELECT COUNT(*) FROM SU_NAM_Subject_Name_Posit WHERE SU_NAM_SU_ID = v_s) + (SELECT COUNT(*) FROM SU_COD_Subject_Code_Posit WHERE SU_COD_SU_ID = v_s)
        + (SELECT COUNT(*) FROM SU_GRD_Subject_Grade_Posit WHERE SU_GRD_SU_ID = v_s) + (SELECT COUNT(*) FROM SU_NOT_Subject_Note_Posit WHERE SU_NOT_SU_ID = v_s)
        + (SELECT COUNT(*) FROM SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = v_s) + (SELECT COUNT(*) FROM SU_STA_Subject_State_Posit WHERE SU_STA_SU_ID = v_s)
        + (SELECT COUNT(*) FROM SU_LBL_Subject_Label_Posit WHERE SU_LBL_SU_ID = v_s) + (SELECT COUNT(*) FROM SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = v_s)
        + (SELECT COUNT(*) FROM SU_LVL_Subject_Level_Posit WHERE SU_LVL_SU_ID = v_s) + (SELECT COUNT(*) FROM SU_TXT_Subject_Text_Posit WHERE SU_TXT_SU_ID = v_s)
        + (SELECT COUNT(*) FROM SU_ASR_Subject_Assessment_Posit WHERE SU_ASR_SU_ID = v_s) + (SELECT COUNT(*) FROM SU_ERS_Subject_Erasable_Posit WHERE SU_ERS_SU_ID = v_s),
        (SELECT COUNT(*) FROM SU_TTL_Subject_Title_Annex a JOIN SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = v_s)
    INTO v_posits, v_assertions
    FROM dual;
    check_that('b01 an insert through the latest view stores a posit for each value', v_posits = 12 AND v_assertions = 1,
        v_posits || ' posits, expected 12; ' || v_assertions || ' assertions of the title');
EXCEPTION WHEN OTHERS THEN
    check_that('b01 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b02 an update that leaves every value and reliability as it is states nothing (State is not restatable)
DECLARE
    v_s NUMBER;
    v_before NUMBER;
    v_after NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    FUNCTION assertions RETURN NUMBER IS
        v_n NUMBER;
    BEGIN
        SELECT
            (SELECT COUNT(*) FROM SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM SU_NOT_Subject_Note_Annex)
            + (SELECT COUNT(*) FROM SU_TTL_Subject_Title_Annex) + (SELECT COUNT(*) FROM SU_STA_Subject_State_Annex) + (SELECT COUNT(*) FROM SU_LVL_Subject_Level_Annex)
            + (SELECT COUNT(*) FROM SU_TXT_Subject_Text_Annex)
        INTO v_n FROM dual;
        RETURN v_n;
    END assertions;
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_GRD_GRD_ID, SU_NOT_Subject_Note, SU_TTL_Subject_Title, SU_TTL_ChangedAt,
        SU_STA_Subject_State, SU_STA_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt)
    VALUES (0, 'name', 1, 'note', 'title', t20200101, 'state', t20200101, 1, t20200101, 'text', t20200101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    v_before := assertions;
    BEGIN
        UPDATE lSU_Subject SET SU_NAM_Subject_Name = SU_NAM_Subject_Name, SU_GRD_GRD_ID = SU_GRD_GRD_ID, SU_NOT_Subject_Note = SU_NOT_Subject_Note,
            SU_TTL_Subject_Title = SU_TTL_Subject_Title, SU_STA_Subject_State = SU_STA_Subject_State, SU_LVL_GRD_ID = SU_LVL_GRD_ID,
            SU_TXT_Subject_Text = SU_TXT_Subject_Text, SU_TTL_Reliability = SU_TTL_Reliability
        WHERE SU_ID = v_s;
        UPDATE lSU_Subject SET SU_GRD_GRD_Grade = SU_GRD_GRD_Grade, Reliability = 1 WHERE SU_ID = v_s;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    v_after := assertions;
    check_that('b02 an update that leaves everything as it is states nothing', v_code IS NULL AND v_after = v_before,
        (v_after - v_before) || ' new assertions' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b02 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b03 a new value of a historized attribute is a new version from now
DECLARE
    v_s NUMBER;
    v_n NUMBER;
    v_shown VARCHAR2(4000);
    v_changed TIMESTAMP;
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt) VALUES (0, 'first', TIMESTAMP '2020-01-01 00:00:00');
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 'second' WHERE SU_ID = v_s;
    SELECT SU_TTL_Subject_Title, SU_TTL_ChangedAt INTO v_shown, v_changed FROM lSU_Subject WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = v_s;
    check_that('b03 a new value is a new version from now', v_n = 2 AND v_shown = 'second' AND v_changed > TIMESTAMP '2025-01-01 00:00:00',
        v_n || ' posits, shown ' || COALESCE(v_shown, 'nothing') || ' from ' || COALESCE(TO_CHAR(v_changed, 'YYYY-MM-DD HH24:MI:SS'), 'nothing'));
EXCEPTION WHEN OTHERS THEN
    check_that('b03 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b04 the same value with a changing time of its own is a restatement, and the settings decide
DECLARE
    v_s NUMBER;
    v_n NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20210101 CONSTANT TIMESTAMP := TIMESTAMP '2021-01-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_STA_Subject_State, SU_STA_ChangedAt,
        SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_LVL_GRD_ID, SU_LVL_ChangedAt, SU_TXT_Subject_Text, SU_TXT_ChangedAt)
    VALUES (0, 'x', t20200101, 'x', t20200101, 'x', t20200101, 'x', t20200101, 1, t20200101, 'x', t20200101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 'x', SU_TTL_ChangedAt = t20210101 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_TTL_Subject_Title_Posit WHERE SU_TTL_SU_ID = v_s;
    check_that('b04 restatable: a restatement is stored', v_n = 2, v_n || ' posits, expected 2');
    BEGIN
        UPDATE lSU_Subject SET SU_STA_Subject_State = 'x', SU_STA_ChangedAt = t20210101 WHERE SU_ID = v_s;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_n FROM SU_STA_Subject_State_Posit WHERE SU_STA_SU_ID = v_s;
    check_that('b04 not restatable: a restatement is an error', v_code = -20002 AND INSTR(v_msg, 'Restatement in SU_STA_Subject_State') > 0 AND v_n = 1,
        v_n || ' posits; ' || COALESCE(v_msg, 'no error'));
    UPDATE lSU_Subject SET SU_LBL_Subject_Label = 'x', SU_LBL_ChangedAt = t20210101 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_LBL_Subject_Label_Posit WHERE SU_LBL_SU_ID = v_s;
    check_that('b04 not restatable, idempotent: a restatement is skipped', v_n = 1, v_n || ' posits, expected 1');
    UPDATE lSU_Subject SET SU_TAG_Subject_Tag = 'x', SU_TAG_ChangedAt = t20210101 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = v_s;
    check_that('b04 restatable, idempotent: a restatement is skipped', v_n = 1, v_n || ' posits, expected 1');
    UPDATE lSU_Subject SET SU_LVL_GRD_ID = 1, SU_LVL_ChangedAt = t20210101 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_LVL_Subject_Level_Posit WHERE SU_LVL_SU_ID = v_s;
    check_that('b04 knotted, restatable: a restatement is stored', v_n = 2, v_n || ' posits, expected 2');
    UPDATE lSU_Subject SET SU_TXT_Subject_Text = 'x', SU_TXT_ChangedAt = t20210101 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_TXT_Subject_Text_Posit WHERE SU_TXT_SU_ID = v_s;
    check_that('b04 with a checksum, restatable: a restatement is stored', v_n = 2, v_n || ' posits, expected 2');
EXCEPTION WHEN OTHERS THEN
    check_that('b04 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b05 another static value is a correction; the same states nothing
DECLARE
    v_s NUMBER;
    v_before NUMBER;
    v_after NUMBER;
    v_name VARCHAR2(4000);
    v_code VARCHAR2(4000);
    v_grade NUMBER;
    v_note VARCHAR2(4000);
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    FUNCTION assertions RETURN NUMBER IS
        v_n NUMBER;
    BEGIN
        SELECT (SELECT COUNT(*) FROM SU_NAM_Subject_Name_Annex) + (SELECT COUNT(*) FROM SU_COD_Subject_Code_Annex)
            + (SELECT COUNT(*) FROM SU_GRD_Subject_Grade_Annex) + (SELECT COUNT(*) FROM SU_NOT_Subject_Note_Annex)
        INTO v_n FROM dual;
        RETURN v_n;
    END assertions;
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_COD_Subject_Code, SU_COD_PositedAt, SU_GRD_GRD_ID, SU_GRD_PositedAt, SU_NOT_Subject_Note, SU_NOT_PositedAt)
    VALUES (0, 'n1', t20240101, 'c1', t20240101, 1, t20240101, 'note one', t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    v_before := assertions;
    UPDATE lSU_Subject SET SU_NAM_Subject_Name = 'n1', SU_COD_Subject_Code = 'c1', SU_GRD_GRD_Grade = 'A', SU_NOT_Subject_Note = 'note one' WHERE SU_ID = v_s;
    v_after := assertions;
    check_that('b05 the same static value states nothing', v_after = v_before, (v_after - v_before) || ' new assertions');
    UPDATE lSU_Subject SET SU_NAM_Subject_Name = 'n2', SU_COD_Subject_Code = 'c2', SU_GRD_GRD_Grade = 'B', SU_NOT_Subject_Note = 'note two',
        SU_NAM_PositedAt = t20240201, SU_COD_PositedAt = t20240201, SU_GRD_PositedAt = t20240201, SU_NOT_PositedAt = t20240201 WHERE SU_ID = v_s;
    SELECT SU_NAM_Subject_Name, SU_COD_Subject_Code, SU_GRD_GRD_ID, DBMS_LOB.SUBSTR(SU_NOT_Subject_Note, 4000, 1)
    INTO v_name, v_code, v_grade, v_note FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b05 another static value is a correction', v_name = 'n2' AND v_code = 'c2' AND v_grade = 2 AND v_note = 'note two',
        'shown ' || COALESCE(v_name, 'nothing') || ', ' || COALESCE(v_code, 'nothing') || ', ' || COALESCE(TO_CHAR(v_grade), 'nothing') || ', ' || COALESCE(v_note, 'nothing'));
EXCEPTION WHEN OTHERS THEN
    check_that('b05 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b06 the shown value asserted again at a positing time of its own: stored when assertive, skipped when not
DECLARE
    v_s NUMBER;
    v_title NUMBER;
    v_assessment NUMBER;
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240601 CONSTANT TIMESTAMP := TIMESTAMP '2024-06-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt)
    VALUES (0, 't', t20200101, t20240101, 'a', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 't', SU_TTL_PositedAt = t20240601, SU_ASR_Subject_Assessment = 'a', SU_ASR_PositedAt = t20240601 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_title FROM SU_TTL_Subject_Title_Annex a JOIN SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = v_s;
    SELECT COUNT(*) INTO v_assessment FROM SU_ASR_Subject_Assessment_Annex a JOIN SU_ASR_Subject_Assessment_Posit p ON p.SU_ASR_ID = a.SU_ASR_ID WHERE p.SU_ASR_SU_ID = v_s;
    check_that('b06 assertive: a re-assertion is stored', v_title = 2, v_title || ' assertions, expected 2');
    check_that('b06 not assertive: a re-assertion is skipped', v_assessment = 1, v_assessment || ' assertions, expected 1');
EXCEPTION WHEN OTHERS THEN
    check_that('b06 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b07 not assertive: A, then B, then A again at the same changing time shows A (the last A used to be lost)
DECLARE
    v_s NUMBER;
    v_shown VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt) VALUES (0, 'A', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    INSERT INTO SU_ASR_Subject_Assessment (Metadata_SU_ASR, SU_ASR_SU_ID, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt, SU_ASR_Reliability)
    VALUES (0, v_s, 'B', t20200101, t20240201, 1);
    SELECT SU_ASR_Subject_Assessment INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b07 a value at the same changing time corrects the shown one', v_shown = 'B', 'shown ' || COALESCE(v_shown, 'nothing'));
    INSERT INTO SU_ASR_Subject_Assessment (Metadata_SU_ASR, SU_ASR_SU_ID, SU_ASR_Subject_Assessment, SU_ASR_ChangedAt, SU_ASR_PositedAt, SU_ASR_Reliability)
    VALUES (0, v_s, 'A', t20200101, t20240301, 1);
    SELECT SU_ASR_Subject_Assessment INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b07 not assertive: switching back to an earlier value is stored', v_shown = 'A', 'shown ' || COALESCE(v_shown, 'nothing') || ', expected A');
EXCEPTION WHEN OTHERS THEN
    check_that('b07 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b08 a reliability of 0 retracts the shown version, through the attribute's own column and through the Reliability
--     column; an unchanged reliability states nothing
DECLARE
    v_s NUMBER;
    v_t NUMBER;
    v_shown VARCHAR2(4000);
    v_before NUMBER;
    v_after NUMBER;
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20210101 CONSTANT TIMESTAMP := TIMESTAMP '2021-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, 'x', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 'y', SU_TTL_ChangedAt = t20210101, SU_TTL_PositedAt = t20240201 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_before FROM SU_TTL_Subject_Title_Annex;
    UPDATE lSU_Subject SET Reliability = 1 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_after FROM SU_TTL_Subject_Title_Annex;
    check_that('b08 an unchanged reliability states nothing', v_after = v_before, (v_after - v_before) || ' new assertions');
    UPDATE lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = t20240301 WHERE SU_ID = v_s;
    SELECT SU_TTL_Subject_Title INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b08 reliability 0 in the attribute''s own column retracts the shown version', v_shown = 'x', 'shown ' || COALESCE(v_shown, 'nothing') || ', expected x');
    INSERT INTO lSU_Subject (Metadata_SU, SU_STA_Subject_State, SU_STA_ChangedAt, SU_STA_PositedAt) VALUES (0, 's', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_t FROM SU_Subject;
    UPDATE lSU_Subject SET Reliability = 0, SU_STA_PositedAt = t20240201 WHERE SU_ID = v_t;
    SELECT SU_STA_Subject_State INTO v_shown FROM lSU_Subject WHERE SU_ID = v_t;
    check_that('b08 reliability 0 in the Reliability column retracts the shown version', v_shown IS NULL, 'shown ' || COALESCE(v_shown, 'nothing'));
EXCEPTION WHEN OTHERS THEN
    check_that('b08 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b09 null retracts the shown version; a value after that is a new version
DECLARE
    v_s NUMBER;
    v_shown VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, 'x', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = NULL, SU_TTL_PositedAt = t20240201 WHERE SU_ID = v_s;
    SELECT SU_TTL_Subject_Title INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b09 null retracts the shown version', v_shown IS NULL, 'shown ' || COALESCE(v_shown, 'nothing'));
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 'y' WHERE SU_ID = v_s;
    SELECT SU_TTL_Subject_Title INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b09 a value after a retraction is stated', v_shown = 'y', 'shown ' || COALESCE(v_shown, 'nothing'));
EXCEPTION WHEN OTHERS THEN
    check_that('b09 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b10 a delete retracts each shown posit once, also one asserted twice (that used to collide on the annex key)
DECLARE
    v_s NUMBER;
    v_title VARCHAR2(4000);
    v_name VARCHAR2(4000);
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240601 CONSTANT TIMESTAMP := TIMESTAMP '2024-06-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt)
    VALUES (0, 'n', t20240101, 't', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 't', SU_TTL_PositedAt = t20240601 WHERE SU_ID = v_s;
    BEGIN
        DELETE FROM lSU_Subject WHERE SU_ID = v_s;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT SU_TTL_Subject_Title, SU_NAM_Subject_Name INTO v_title, v_name FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b10 a delete retracts the shown posits', v_code IS NULL AND v_title IS NULL AND v_name IS NULL,
        'shown ' || COALESCE(v_title, 'nothing') || ' and ' || COALESCE(v_name, 'nothing') || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b10 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b11 inserts straight into the assembled views: the identical is ignored
DECLARE
    v_s NUMBER;
    v_n NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    BEGIN
        INSERT INTO SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, v_s, 't', t20200101, t20240101, 1);
        INSERT INTO SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, v_s, 't', t20200101, t20240101, 1);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_n FROM SU_TTL_Subject_Title_Annex a JOIN SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = v_s;
    check_that('b11 the identical inserted again is ignored', v_code IS NULL AND v_n = 1, v_n || ' assertions' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b11 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b12 idempotent, out of order: an earlier version with the same value as the next one keeps the earlier start
DECLARE
    v_s NUMBER;
    v_changed TIMESTAMP;
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20210101 CONSTANT TIMESTAMP := TIMESTAMP '2021-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    INSERT INTO SU_LBL_Subject_Label (Metadata_SU_LBL, SU_LBL_SU_ID, SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_LBL_PositedAt, SU_LBL_Reliability) VALUES (0, v_s, 'x', t20210101, t20240101, 1);
    INSERT INTO SU_LBL_Subject_Label (Metadata_SU_LBL, SU_LBL_SU_ID, SU_LBL_Subject_Label, SU_LBL_ChangedAt, SU_LBL_PositedAt, SU_LBL_Reliability) VALUES (0, v_s, 'x', t20200101, t20240201, 1);
    SELECT SU_LBL_ChangedAt INTO v_changed FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b12 idempotent: the value counts from the earlier time', v_changed = t20200101,
        'shown from ' || COALESCE(TO_CHAR(v_changed, 'YYYY-MM-DD HH24:MI:SS'), 'nothing'));
EXCEPTION WHEN OTHERS THEN
    check_that('b12 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b13 ties
DECLARE
    v_s1 NUMBER;
    v_s2 NUMBER;
    v_o NUMBER;
    v_n NUMBER;
    v_shown VARCHAR2(4000);
    v_owner NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20210101 CONSTANT TIMESTAMP := TIMESTAMP '2021-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
    t20240601 CONSTANT TIMESTAMP := TIMESTAMP '2024-06-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s1;
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s2;
    INSERT INTO OB_Object (Metadata_OB) VALUES (0) RETURNING OB_ID INTO v_o;
    -- historized, with identifiers and a value
    INSERT INTO lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
    VALUES (0, t20200101, t20240101, v_s1, v_o, 1);
    UPDATE lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = 1 WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    SELECT COUNT(*) INTO v_n FROM SU_holder_OB_item_GRD_grade_Annex a JOIN SU_holder_OB_item_GRD_grade_Posit p ON p.SU_holder_OB_item_GRD_grade_ID = a.SU_holder_OB_item_GRD_grade_ID WHERE p.SU_ID_holder = v_s1 AND p.OB_ID_item = v_o;
    check_that('b13 a tie: unchanged values state nothing', v_n = 1, v_n || ' assertions, expected 1');
    UPDATE lSU_holder_OB_item_GRD_grade SET grade_GRD_Grade = 'B', SU_holder_OB_item_GRD_grade_ChangedAt = t20210101, SU_holder_OB_item_GRD_grade_PositedAt = t20240201 WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    SELECT MAX(grade_GRD_Grade) INTO v_shown FROM lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    check_that('b13 a tie: a new value by knot value is a new version', v_shown = 'B', 'shown ' || COALESCE(v_shown, 'nothing'));
    BEGIN
        UPDATE lSU_holder_OB_item_GRD_grade SET GRD_ID_grade = NULL, SU_holder_OB_item_GRD_grade_PositedAt = t20240301 WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT MAX(grade_GRD_Grade) INTO v_shown FROM lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    check_that('b13 a tie: null retracts the shown version', v_code IS NULL AND v_shown = 'A',
        'shown ' || COALESCE(v_shown, 'nothing') || ', expected A' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
    UPDATE lSU_holder_OB_item_GRD_grade SET SU_holder_OB_item_GRD_grade_Reliability = 0 WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    SELECT COUNT(*) INTO v_n FROM lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = v_s1 AND OB_ID_item = v_o;
    check_that('b13 a tie: reliability 0 retracts the shown version', v_n = 0, v_n || ' shown, expected 0');
    -- historized, not assertive
    INSERT INTO lSU_keeper_OB_thing_GRD_rank (Metadata_SU_keeper_OB_thing_GRD_rank, SU_keeper_OB_thing_GRD_rank_ChangedAt, SU_keeper_OB_thing_GRD_rank_PositedAt, SU_ID_keeper, OB_ID_thing, GRD_ID_rank)
    VALUES (0, t20200101, t20240101, v_s1, v_o, 1);
    UPDATE lSU_keeper_OB_thing_GRD_rank SET GRD_ID_rank = 1, SU_keeper_OB_thing_GRD_rank_PositedAt = t20240601 WHERE SU_ID_keeper = v_s1 AND OB_ID_thing = v_o;
    SELECT COUNT(*) INTO v_n FROM SU_keeper_OB_thing_GRD_rank_Annex a JOIN SU_keeper_OB_thing_GRD_rank_Posit p ON p.SU_keeper_OB_thing_GRD_rank_ID = a.SU_keeper_OB_thing_GRD_rank_ID WHERE p.SU_ID_keeper = v_s1 AND p.OB_ID_thing = v_o;
    check_that('b13 a tie that is not assertive: a re-assertion is skipped', v_n = 1, v_n || ' assertions, expected 1');
    -- static, with an identifier and a value
    INSERT INTO lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_part_SU_owner_PositedAt, OB_ID_part, SU_ID_owner) VALUES (0, t20240101, v_o, v_s1);
    UPDATE lOB_part_SU_owner SET SU_ID_owner = v_s2 WHERE OB_ID_part = v_o;
    SELECT MAX(SU_ID_owner) INTO v_owner FROM lOB_part_SU_owner WHERE OB_ID_part = v_o;
    check_that('b13 a static tie: another value is a correction', v_owner = v_s2, 'shown owner ' || COALESCE(TO_CHAR(v_owner), 'nothing'));
    -- historized, without identifiers
    INSERT INTO lSU_partner_SU_with (Metadata_SU_partner_SU_with, SU_partner_SU_with_ChangedAt, SU_ID_partner, SU_ID_with) VALUES (0, t20200101, v_s1, v_s2);
    UPDATE lSU_partner_SU_with SET SU_ID_with = v_s2 WHERE SU_ID_partner = v_s1;
    SELECT COUNT(*) INTO v_n FROM SU_partner_SU_with_Annex a JOIN SU_partner_SU_with_Posit p ON p.SU_partner_SU_with_ID = a.SU_partner_SU_with_ID WHERE p.SU_ID_partner = v_s1;
    check_that('b13 a tie without identifiers: unchanged values state nothing', v_n = 1, v_n || ' assertions, expected 1');
EXCEPTION WHEN OTHERS THEN
    check_that('b13 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b14 a nexus with an attribute, through its latest view
DECLARE
    v_s NUMBER;
    v_e NUMBER;
    v_n NUMBER;
    v_a NUMBER;
    v_b NUMBER;
    v_made NUMBER;
    v_matched NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    BEGIN
        INSERT INTO lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity) VALUES (0, v_s, 5);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT MAX(EV_ID) INTO v_e FROM EV_Event WHERE SU_ID_for = v_s;
    SELECT COUNT(*) INTO v_n FROM EV_QTY_Event_Quantity_Posit WHERE EV_QTY_EV_ID = v_e;
    check_that('b14 a nexus with an attribute through its latest view', v_code IS NULL AND v_n = 1, v_n || ' values' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
    -- several new nexus rows in one insert: each keeps its own roles and values
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_a;
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_b;
    v_code := NULL;
    v_msg := NULL;
    BEGIN
        INSERT INTO lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity)
        SELECT 0, v_a, 7 FROM dual UNION ALL SELECT 0, v_b, 8 FROM dual UNION ALL SELECT 0, v_a, 9 FROM dual;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_made FROM EV_Event WHERE SU_ID_for IN (v_a, v_b);
    SELECT COUNT(*) INTO v_matched FROM EV_Event ev JOIN EV_QTY_Event_Quantity_Posit q ON q.EV_QTY_EV_ID = ev.EV_ID
        WHERE (ev.SU_ID_for = v_a AND q.EV_QTY_Event_Quantity IN (7, 9)) OR (ev.SU_ID_for = v_b AND q.EV_QTY_Event_Quantity = 8);
    check_that('b14 several new nexus rows in one insert keep their own values', v_code IS NULL AND v_made = 3 AND v_matched = 3,
        v_made || ' rows, ' || v_matched || ' with their own values' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b14 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b15 a posit asserted again at a positing time that already has an assertion of it: the same reliability states
--     nothing, another one is a contradiction
DECLARE
    v_s NUMBER;
    v_o NUMBER;
    v_n NUMBER;
    v_shown VARCHAR2(4000);
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, 'x', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    BEGIN
        INSERT INTO SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, v_s, 'x', t20200101, t20240101, 1);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_n FROM SU_TTL_Subject_Title_Annex a JOIN SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID WHERE p.SU_TTL_SU_ID = v_s;
    check_that('b15 the same reliability at a positing time that is taken states nothing', v_code IS NULL AND v_n = 1, v_n || ' assertions' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
    v_code := NULL;
    v_msg := NULL;
    BEGIN
        INSERT INTO SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, v_s, 'x', t20200101, t20240101, 0);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT SU_TTL_Subject_Title INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b15 another reliability at a positing time that is taken is a contradiction', v_code = -20001 AND INSTR(v_msg, 'Contradiction in SU_TTL_Subject_Title') > 0 AND v_shown = 'x',
        'shown ' || COALESCE(v_shown, 'nothing') || '; ' || COALESCE(v_msg, 'no error'));
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    INSERT INTO OB_Object (Metadata_OB) VALUES (0) RETURNING OB_ID INTO v_o;
    INSERT INTO lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
    VALUES (0, t20200101, t20240101, v_s, v_o, 1);
    v_code := NULL;
    v_msg := NULL;
    BEGIN
        INSERT INTO SU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_ID_holder, OB_ID_item, GRD_ID_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_holder_OB_item_GRD_grade_Reliability)
        VALUES (0, v_s, v_o, 1, t20200101, t20240101, 0);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_n FROM lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = v_s AND OB_ID_item = v_o;
    check_that('b15 a tie: another reliability at a positing time that is taken is a contradiction', v_code = -20001 AND INSTR(v_msg, 'Contradiction in SU_holder_OB_item_GRD_grade') > 0 AND v_n = 1,
        v_n || ' shown; ' || COALESCE(v_msg, 'no error'));
EXCEPTION WHEN OTHERS THEN
    check_that('b15 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b16 another value at the same changing time is a correction, which retracts what it corrects at its own positing
--     time, so retracting the correction leaves nothing of the corrected value in effect (it used to come back)
DECLARE
    v_s NUMBER;
    v_n NUMBER;
    v_shown VARCHAR2(4000);
    t20190101 CONSTANT TIMESTAMP := TIMESTAMP '2019-01-01 00:00:00';
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
    t20240401 CONSTANT TIMESTAMP := TIMESTAMP '2024-04-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt) VALUES (0, 'n1', t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_NAM_Subject_Name = 'n2', SU_NAM_PositedAt = t20240201 WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_NAM_Subject_Name_Annex a JOIN SU_NAM_Subject_Name_Posit p ON p.SU_NAM_ID = a.SU_NAM_ID
        WHERE p.SU_NAM_SU_ID = v_s AND p.SU_NAM_Subject_Name = 'n1' AND a.SU_NAM_PositedAt = t20240201 AND a.SU_NAM_Reliability = 0;
    check_that('b16 a static correction retracts the corrected posit at its positing time', v_n = 1, v_n || ' retractions of n1, expected 1');
    UPDATE lSU_Subject SET SU_NAM_Reliability = 0, SU_NAM_PositedAt = t20240301 WHERE SU_ID = v_s;
    SELECT SU_NAM_Subject_Name INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b16 retracting a static correction leaves nothing in effect', v_shown IS NULL, 'shown ' || COALESCE(v_shown, 'nothing'));
    -- historized: a value at the changing time of the shown version corrects it, and only it
    INSERT INTO lSU_Subject (Metadata_SU, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt) VALUES (0, 'early', t20190101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TTL_Subject_Title = 't1', SU_TTL_ChangedAt = t20200101, SU_TTL_PositedAt = t20240201 WHERE SU_ID = v_s;
    INSERT INTO SU_TTL_Subject_Title (Metadata_SU_TTL, SU_TTL_SU_ID, SU_TTL_Subject_Title, SU_TTL_ChangedAt, SU_TTL_PositedAt, SU_TTL_Reliability) VALUES (0, v_s, 't2', t20200101, t20240301, 1);
    SELECT COUNT(*) INTO v_n FROM SU_TTL_Subject_Title_Annex a JOIN SU_TTL_Subject_Title_Posit p ON p.SU_TTL_ID = a.SU_TTL_ID
        WHERE p.SU_TTL_SU_ID = v_s AND a.SU_TTL_Reliability = 0;
    check_that('b16 a historized correction retracts the version it corrects and no other', v_n = 1, v_n || ' retractions, expected 1');
    UPDATE lSU_Subject SET SU_TTL_Reliability = 0, SU_TTL_PositedAt = t20240401 WHERE SU_ID = v_s;
    SELECT SU_TTL_Subject_Title INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b16 retracting a historized correction shows the version before it', v_shown = 'early', 'shown ' || COALESCE(v_shown, 'nothing') || ', expected early');
    -- knotted, by the value of the knot, and with a checksum
    INSERT INTO lSU_Subject (Metadata_SU, SU_GRD_GRD_ID, SU_GRD_PositedAt, SU_NOT_Subject_Note, SU_NOT_PositedAt) VALUES (0, 1, t20240101, 'note one', t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_GRD_GRD_Grade = 'B', SU_GRD_PositedAt = t20240201, SU_NOT_Subject_Note = 'note two', SU_NOT_PositedAt = t20240201 WHERE SU_ID = v_s;
    SELECT
        (SELECT COUNT(*) FROM SU_GRD_Subject_Grade_Annex a JOIN SU_GRD_Subject_Grade_Posit p ON p.SU_GRD_ID = a.SU_GRD_ID
            WHERE p.SU_GRD_SU_ID = v_s AND p.SU_GRD_GRD_ID = 1 AND a.SU_GRD_PositedAt = t20240201 AND a.SU_GRD_Reliability = 0)
        + (SELECT COUNT(*) FROM SU_NOT_Subject_Note_Annex a JOIN SU_NOT_Subject_Note_Posit p ON p.SU_NOT_ID = a.SU_NOT_ID
            WHERE p.SU_NOT_SU_ID = v_s AND DBMS_LOB.COMPARE(p.SU_NOT_Subject_Note, TO_NCLOB('note one')) = 0 AND a.SU_NOT_PositedAt = t20240201 AND a.SU_NOT_Reliability = 0)
    INTO v_n FROM dual;
    check_that('b16 a correction of a knotted attribute and of one with a checksum retracts the corrected posits', v_n = 2, v_n || ' retractions, expected 2');
EXCEPTION WHEN OTHERS THEN
    check_that('b16 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b17 a static tie: other values are a correction, which retracts what it corrects
DECLARE
    v_s1 NUMBER;
    v_s2 NUMBER;
    v_o NUMBER;
    v_n NUMBER;
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s1;
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s2;
    INSERT INTO OB_Object (Metadata_OB) VALUES (0) RETURNING OB_ID INTO v_o;
    INSERT INTO lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_part_SU_owner_PositedAt, OB_ID_part, SU_ID_owner) VALUES (0, t20240101, v_o, v_s1);
    UPDATE lOB_part_SU_owner SET SU_ID_owner = v_s2, OB_part_SU_owner_PositedAt = t20240201 WHERE OB_ID_part = v_o;
    SELECT COUNT(*) INTO v_n FROM OB_part_SU_owner_Annex a JOIN OB_part_SU_owner_Posit p ON p.OB_part_SU_owner_ID = a.OB_part_SU_owner_ID
        WHERE p.OB_ID_part = v_o AND p.SU_ID_owner = v_s1 AND a.OB_part_SU_owner_PositedAt = t20240201 AND a.OB_part_SU_owner_Reliability = 0;
    check_that('b17 a static tie correction retracts the corrected posit at its positing time', v_n = 1, v_n || ' retractions, expected 1');
    UPDATE lOB_part_SU_owner SET OB_part_SU_owner_Reliability = 0, OB_part_SU_owner_PositedAt = t20240301 WHERE OB_ID_part = v_o;
    SELECT COUNT(*) INTO v_n FROM lOB_part_SU_owner WHERE OB_ID_part = v_o;
    check_that('b17 retracting a static tie correction leaves nothing in effect', v_n = 0, v_n || ' shown, expected 0');
EXCEPTION WHEN OTHERS THEN
    check_that('b17 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b18 a nexus is updated and deleted through its latest view, as an anchor is, and its roles are not updatable
DECLARE
    v_s NUMBER;
    v_s2 NUMBER;
    v_e NUMBER;
    v_n NUMBER;
    v_quantity NUMBER;
    v_for NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s2;
    INSERT INTO lEV_Event (Metadata_EV, SU_ID_for, EV_QTY_Event_Quantity, EV_QTY_PositedAt) VALUES (0, v_s, 5, t20240101);
    SELECT MAX(EV_ID) INTO v_e FROM EV_Event WHERE SU_ID_for = v_s;
    BEGIN
        UPDATE lEV_Event SET EV_QTY_Event_Quantity = 6, EV_QTY_PositedAt = t20240201 WHERE EV_ID = v_e;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT MAX(EV_QTY_Event_Quantity) INTO v_quantity FROM lEV_Event WHERE EV_ID = v_e;
    SELECT COUNT(*) INTO v_n FROM EV_QTY_Event_Quantity_Annex a JOIN EV_QTY_Event_Quantity_Posit p ON p.EV_QTY_ID = a.EV_QTY_ID
        WHERE p.EV_QTY_EV_ID = v_e AND p.EV_QTY_Event_Quantity = 5 AND a.EV_QTY_PositedAt = t20240201 AND a.EV_QTY_Reliability = 0;
    check_that('b18 an update of a nexus attribute through the latest view is a correction', v_code IS NULL AND v_quantity = 6 AND v_n = 1,
        'shown ' || COALESCE(TO_CHAR(v_quantity), 'nothing') || ', ' || v_n || ' retractions of 5' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
    v_code := NULL;
    v_msg := NULL;
    BEGIN
        UPDATE lEV_Event SET SU_ID_for = v_s2 WHERE EV_ID = v_e;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT MAX(SU_ID_for) INTO v_for FROM EV_Event WHERE EV_ID = v_e;
    check_that('b18 a role of a nexus is not updatable', v_code = -20003 AND INSTR(v_msg, 'The role column SU_ID_for is not updatable') > 0 AND v_for = v_s,
        'for ' || COALESCE(TO_CHAR(v_for), 'nothing') || '; ' || COALESCE(v_msg, 'no error'));
    v_code := NULL;
    v_msg := NULL;
    BEGIN
        DELETE FROM lEV_Event WHERE EV_ID = v_e;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT MAX(EV_QTY_Event_Quantity) INTO v_quantity FROM lEV_Event WHERE EV_ID = v_e;
    check_that('b18 a delete through the latest view of a nexus retracts its shown values', v_code IS NULL AND v_quantity IS NULL,
        'shown ' || COALESCE(TO_CHAR(v_quantity), 'nothing') || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b18 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b20 a historized attribute of a nexus: a new value is a new version, which the difference perspective shows, and a
--     restatement is an error when the attribute is not restatable
DECLARE
    v_s NUMBER;
    v_e NUMBER;
    v_n NUMBER;
    v_place VARCHAR2(4000);
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20210101 CONSTANT TIMESTAMP := TIMESTAMP '2021-01-01 00:00:00';
    t20220101 CONSTANT TIMESTAMP := TIMESTAMP '2022-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    INSERT INTO lEV_Event (Metadata_EV, SU_ID_for, EV_PLC_Event_Place, EV_PLC_ChangedAt, EV_PLC_PositedAt) VALUES (0, v_s, 'p1', t20200101, t20240101);
    SELECT MAX(EV_ID) INTO v_e FROM EV_Event WHERE SU_ID_for = v_s;
    UPDATE lEV_Event SET EV_PLC_Event_Place = 'p2', EV_PLC_ChangedAt = t20210101, EV_PLC_PositedAt = t20240201 WHERE EV_ID = v_e;
    SELECT MAX(EV_PLC_Event_Place) INTO v_place FROM lEV_Event WHERE EV_ID = v_e;
    -- the difference perspective is a table macro, called in dynamic SQL; its selection is null (all attributes)
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM dEV_Event(TIMESTAMP ''2019-01-01 00:00:00'', TIMESTAMP ''2022-01-01 00:00:00'', CAST(NULL AS VARCHAR2(10))) WHERE EV_ID = :e'
        INTO v_n USING v_e;
    check_that('b20 a new value of a historized nexus attribute is a new version, which the difference perspective shows', v_place = 'p2' AND v_n = 2,
        'shown ' || COALESCE(v_place, 'nothing') || ', ' || v_n || ' differences, expected 2');
    BEGIN
        UPDATE lEV_Event SET EV_PLC_Event_Place = 'p2', EV_PLC_ChangedAt = t20220101, EV_PLC_PositedAt = t20240301 WHERE EV_ID = v_e;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_n FROM EV_PLC_Event_Place_Posit WHERE EV_PLC_EV_ID = v_e;
    check_that('b20 a restatement of a nexus attribute that is not restatable is an error', v_code = -20002 AND INSTR(v_msg, 'Restatement in EV_PLC_Event_Place') > 0 AND v_n = 2,
        v_n || ' posits; ' || COALESCE(v_msg, 'no error'));
EXCEPTION WHEN OTHERS THEN
    check_that('b20 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b21 another value at a positing time that already has one is a contradiction; a correction to the value of the version
--     before retracts what it corrects, although an idempotent attribute skips the restatement; and a retraction followed
--     by an assertion at the same positing time is a correction written in two statements
DECLARE
    v_s NUMBER;
    v_n NUMBER;
    v_shown VARCHAR2(4000);
    v_changed TIMESTAMP;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20210101 CONSTANT TIMESTAMP := TIMESTAMP '2021-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
    t20240201 CONSTANT TIMESTAMP := TIMESTAMP '2024-02-01 00:00:00';
    t20240301 CONSTANT TIMESTAMP := TIMESTAMP '2024-03-01 00:00:00';
BEGIN
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt) VALUES (0, 'n1', t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    BEGIN
        INSERT INTO SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Reliability) VALUES (0, v_s, 'n2', t20240101, 1);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT COUNT(*) INTO v_n FROM SU_NAM_Subject_Name_Posit WHERE SU_NAM_SU_ID = v_s;
    check_that('b21 another value at a positing time that has one is a contradiction', v_code = -20001 AND INSTR(v_msg, 'Contradiction in SU_NAM_Subject_Name') > 0 AND v_n = 1,
        v_n || ' posits; ' || COALESCE(v_msg, 'no error'));
    -- idempotent: A, then B at a changing time of its own, then A at that time
    INSERT INTO lSU_Subject (Metadata_SU, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_TAG_PositedAt) VALUES (0, 'A', t20200101, t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    UPDATE lSU_Subject SET SU_TAG_Subject_Tag = 'B', SU_TAG_ChangedAt = t20210101, SU_TAG_PositedAt = t20240201 WHERE SU_ID = v_s;
    INSERT INTO SU_TAG_Subject_Tag (Metadata_SU_TAG, SU_TAG_SU_ID, SU_TAG_Subject_Tag, SU_TAG_ChangedAt, SU_TAG_PositedAt, SU_TAG_Reliability) VALUES (0, v_s, 'A', t20210101, t20240301, 1);
    SELECT SU_TAG_Subject_Tag, SU_TAG_ChangedAt INTO v_shown, v_changed FROM lSU_Subject WHERE SU_ID = v_s;
    SELECT COUNT(*) INTO v_n FROM SU_TAG_Subject_Tag_Posit WHERE SU_TAG_SU_ID = v_s;
    check_that('b21 idempotent: a correction to the value of the version before retracts the corrected version', v_shown = 'A' AND v_changed = t20200101 AND v_n = 2,
        'shown ' || COALESCE(v_shown, 'nothing') || ' from ' || COALESCE(TO_CHAR(v_changed, 'YYYY-MM-DD HH24:MI:SS'), 'nothing') || ', ' || v_n || ' posits, expected A from 2020-01-01 and 2 posits');
    -- a retraction and then an assertion at the same positing time
    INSERT INTO lSU_Subject (Metadata_SU, SU_NAM_Subject_Name, SU_NAM_PositedAt) VALUES (0, 'm1', t20240101);
    SELECT MAX(SU_ID) INTO v_s FROM SU_Subject;
    v_code := NULL;
    v_msg := NULL;
    BEGIN
        INSERT INTO SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Reliability) VALUES (0, v_s, 'm1', t20240201, 0);
        INSERT INTO SU_NAM_Subject_Name (Metadata_SU_NAM, SU_NAM_SU_ID, SU_NAM_Subject_Name, SU_NAM_PositedAt, SU_NAM_Reliability) VALUES (0, v_s, 'm2', t20240201, 1);
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT SU_NAM_Subject_Name INTO v_shown FROM lSU_Subject WHERE SU_ID = v_s;
    check_that('b21 a retraction and an assertion at one positing time make a correction', v_code IS NULL AND v_shown = 'm2',
        'shown ' || COALESCE(v_shown, 'nothing') || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b21 the group ran to its end', FALSE, SQLERRM);
END;
/

-- b22 a delete through the latest view of a tie retracts what it shows
DECLARE
    v_s NUMBER;
    v_o NUMBER;
    v_n NUMBER;
    v_code NUMBER;
    v_msg VARCHAR2(4000);
    t20200101 CONSTANT TIMESTAMP := TIMESTAMP '2020-01-01 00:00:00';
    t20240101 CONSTANT TIMESTAMP := TIMESTAMP '2024-01-01 00:00:00';
BEGIN
    INSERT INTO SU_Subject (Metadata_SU) VALUES (0) RETURNING SU_ID INTO v_s;
    INSERT INTO OB_Object (Metadata_OB) VALUES (0) RETURNING OB_ID INTO v_o;
    INSERT INTO lSU_holder_OB_item_GRD_grade (Metadata_SU_holder_OB_item_GRD_grade, SU_holder_OB_item_GRD_grade_ChangedAt, SU_holder_OB_item_GRD_grade_PositedAt, SU_ID_holder, OB_ID_item, GRD_ID_grade)
    VALUES (0, t20200101, t20240101, v_s, v_o, 1);
    INSERT INTO lOB_part_SU_owner (Metadata_OB_part_SU_owner, OB_part_SU_owner_PositedAt, OB_ID_part, SU_ID_owner) VALUES (0, t20240101, v_o, v_s);
    BEGIN
        DELETE FROM lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = v_s AND OB_ID_item = v_o;
        DELETE FROM lOB_part_SU_owner WHERE OB_ID_part = v_o;
    EXCEPTION WHEN OTHERS THEN
        v_code := SQLCODE;
        v_msg := SQLERRM;
    END;
    SELECT (SELECT COUNT(*) FROM lSU_holder_OB_item_GRD_grade WHERE SU_ID_holder = v_s AND OB_ID_item = v_o)
        + (SELECT COUNT(*) FROM lOB_part_SU_owner WHERE OB_ID_part = v_o)
    INTO v_n FROM dual;
    check_that('b22 a delete through the latest view of a tie retracts what it shows', v_code IS NULL AND v_n = 0,
        v_n || ' shown, expected 0' || CASE WHEN v_msg IS NOT NULL THEN ' ' || v_msg END);
EXCEPTION WHEN OTHERS THEN
    check_that('b22 the group ran to its end', FALSE, SQLERRM);
END;
/
ROLLBACK;

SET PAGESIZE 0
SELECT CASE passed WHEN 1 THEN 'PASS  ' ELSE 'FAIL  ' END || test || CASE WHEN passed = 0 AND detail IS NOT NULL THEN ': ' || detail END FROM test_result;
SELECT 'checks: ' || COUNT(*) || ', failed: ' || SUM(CASE passed WHEN 0 THEN 1 ELSE 0 END) FROM test_result;
