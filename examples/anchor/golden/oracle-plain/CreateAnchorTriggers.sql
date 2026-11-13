-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates (the insert procedures of the
-- attributes, ip_<attribute>, see to that).
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lST_Stage
INSTEAD OF INSERT ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    v_id := :NEW.ST_ID;
    IF v_id IS NULL THEN
        INSERT INTO ST_Stage (
            ST_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING ST_ID INTO v_id;
    END IF;
    IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
        ip_ST_NAM_Stage_Name(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_NAM_ChangedAt, v_now),
            p_value => :NEW.ST_NAM_Stage_Name
        );
    END IF;
    IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
        ip_ST_LOC_Stage_Location(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_value => :NEW.ST_LOC_Stage_Location
        );
    END IF;
    v_AVG := :NEW.UTL_ID;
    IF v_AVG IS NULL AND :NEW.UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_AVG := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_AVG IS NOT NULL THEN
        ip_ST_AVG_Stage_Average(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_changing => COALESCE(:NEW.ST_AVG_ChangedAt, v_now),
            p_value => v_AVG
        );
    END IF;
    v_MIN := :NEW.UTL_ID;
    IF v_MIN IS NULL AND :NEW.UTL_Utilization IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.UTL_ID
            FROM
                UTL_Utilization k
            WHERE
                k.UTL_Utilization = :NEW.UTL_Utilization
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_MIN := kv.UTL_ID;
        END LOOP;
    END IF;
    IF v_MIN IS NOT NULL THEN
        ip_ST_MIN_Stage_Minimum(
            p_owner => COALESCE(:NEW.ST_ID, v_id),
            p_value => v_MIN
        );
    END IF;
END it_lST_Stage;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lST_Stage
INSTEAD OF UPDATE ON lST_Stage
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_AVG number(3);
    v_MIN number(3);
BEGIN
    IF (:NEW.ST_ID <> :OLD.ST_ID
        OR (:NEW.ST_ID IS NULL AND :OLD.ST_ID IS NOT NULL)
        OR (:NEW.ST_ID IS NOT NULL AND :OLD.ST_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column ST_ID is not updatable.');
    END IF;
    IF (:NEW.ST_NAM_Stage_Name <> :OLD.ST_NAM_Stage_Name
        OR (:NEW.ST_NAM_Stage_Name IS NULL AND :OLD.ST_NAM_Stage_Name IS NOT NULL)
        OR (:NEW.ST_NAM_Stage_Name IS NOT NULL AND :OLD.ST_NAM_Stage_Name IS NULL))
    OR (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_NAM_Stage_Name IS NOT NULL THEN
            ip_ST_NAM_Stage_Name(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_NAM_ChangedAt <> :OLD.ST_NAM_ChangedAt
                        OR (:NEW.ST_NAM_ChangedAt IS NULL AND :OLD.ST_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_NAM_ChangedAt IS NOT NULL AND :OLD.ST_NAM_ChangedAt IS NULL))
                    THEN :NEW.ST_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.ST_NAM_Stage_Name
            );
        END IF;
    END IF;
    IF (:NEW.ST_LOC_Stage_Location <> :OLD.ST_LOC_Stage_Location
        OR (:NEW.ST_LOC_Stage_Location IS NULL AND :OLD.ST_LOC_Stage_Location IS NOT NULL)
        OR (:NEW.ST_LOC_Stage_Location IS NOT NULL AND :OLD.ST_LOC_Stage_Location IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.ST_LOC_Stage_Location IS NOT NULL THEN
            ip_ST_LOC_Stage_Location(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_value => :NEW.ST_LOC_Stage_Location
            );
        END IF;
    END IF;
    IF (:NEW.UTL_ID <> :OLD.UTL_ID
        OR (:NEW.UTL_ID IS NULL AND :OLD.UTL_ID IS NOT NULL)
        OR (:NEW.UTL_ID IS NOT NULL AND :OLD.UTL_ID IS NULL))
    OR (:NEW.UTL_Utilization <> :OLD.UTL_Utilization
        OR (:NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL)
        OR (:NEW.UTL_Utilization IS NOT NULL AND :OLD.UTL_Utilization IS NULL))
    OR (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_AVG := :NEW.UTL_ID;
        IF (v_AVG = :OLD.UTL_ID OR (v_AVG IS NULL AND :OLD.UTL_ID IS NULL))
        AND :NEW.UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_AVG := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_AVG IS NOT NULL AND (
            (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL)) OR
            :OLD.UTL_ID IS NULL OR
            :OLD.UTL_ID <> v_AVG
        ) THEN
            ip_ST_AVG_Stage_Average(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_changing => CASE
                    WHEN (:NEW.ST_AVG_ChangedAt <> :OLD.ST_AVG_ChangedAt
                        OR (:NEW.ST_AVG_ChangedAt IS NULL AND :OLD.ST_AVG_ChangedAt IS NOT NULL)
                        OR (:NEW.ST_AVG_ChangedAt IS NOT NULL AND :OLD.ST_AVG_ChangedAt IS NULL))
                    THEN :NEW.ST_AVG_ChangedAt
                    ELSE v_now
                END,
                p_value => v_AVG
            );
        END IF;
    END IF;
    IF (:NEW.UTL_ID <> :OLD.UTL_ID
        OR (:NEW.UTL_ID IS NULL AND :OLD.UTL_ID IS NOT NULL)
        OR (:NEW.UTL_ID IS NOT NULL AND :OLD.UTL_ID IS NULL))
    OR (:NEW.UTL_Utilization <> :OLD.UTL_Utilization
        OR (:NEW.UTL_Utilization IS NULL AND :OLD.UTL_Utilization IS NOT NULL)
        OR (:NEW.UTL_Utilization IS NOT NULL AND :OLD.UTL_Utilization IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_MIN := :NEW.UTL_ID;
        IF (v_MIN = :OLD.UTL_ID OR (v_MIN IS NULL AND :OLD.UTL_ID IS NULL))
        AND :NEW.UTL_Utilization IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.UTL_ID
                FROM
                    UTL_Utilization k
                WHERE
                    k.UTL_Utilization = :NEW.UTL_Utilization
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_MIN := kv.UTL_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_MIN IS NOT NULL AND (
            :OLD.UTL_ID IS NULL OR
            :OLD.UTL_ID <> v_MIN
        ) THEN
            ip_ST_MIN_Stage_Minimum(
                p_owner => COALESCE(:NEW.ST_ID, :NEW.ST_ID),
                p_value => v_MIN
            );
        END IF;
    END IF;
    -- a null on a deletable attribute moves what the entity has of it to the deletion table
    IF :NEW.Deletable_ST_MIN = 1
    AND :OLD.UTL_ID IS NOT NULL
    AND (:NEW.UTL_ID IS NULL OR :NEW.UTL_Utilization IS NULL)
    THEN
        INSERT INTO ST_MIN_Stage_Minimum_Deleted (
            ST_ID,
            UTL_ID,
            ST_MIN_Deleted
        )
        SELECT
            x.ST_ID,
            x.UTL_ID,
            v_now
        FROM
            ST_MIN_Stage_Minimum x
        WHERE
            x.ST_ID = :OLD.ST_ID;
        DELETE FROM
            ST_MIN_Stage_Minimum
        WHERE
            ST_ID = :OLD.ST_ID;
    END IF;
END ut_lST_Stage;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_Stage
INSTEAD OF DELETE ON lST_Stage
FOR EACH ROW
BEGIN
    DELETE FROM
        ST_NAM_Stage_Name x
    WHERE
        x.ST_ID = :OLD.ST_ID
    AND
        x.ST_NAM_ChangedAt = :OLD.ST_NAM_ChangedAt
    ;
    DELETE FROM
        ST_LOC_Stage_Location x
    WHERE
        x.ST_ID = :OLD.ST_ID
    ;
    DELETE FROM
        ST_AVG_Stage_Average x
    WHERE
        x.ST_ID = :OLD.ST_ID
    AND
        x.ST_AVG_ChangedAt = :OLD.ST_AVG_ChangedAt
    ;
    DELETE FROM
        ST_MIN_Stage_Minimum x
    WHERE
        x.ST_ID = :OLD.ST_ID
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        ST_Stage a
    WHERE
        a.ST_ID = :OLD.ST_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_NAM_Stage_Name x
        WHERE
            x.ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_LOC_Stage_Location x
        WHERE
            x.ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_AVG_Stage_Average x
        WHERE
            x.ST_ID = a.ST_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            ST_MIN_Stage_Minimum x
        WHERE
            x.ST_ID = a.ST_ID
    )
    ;
END dt_lST_Stage;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_Actor
INSTEAD OF INSERT ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    v_id := :NEW.AC_ID;
    IF v_id IS NULL THEN
        INSERT INTO AC_Actor (
            AC_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING AC_ID INTO v_id;
    END IF;
    IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
        ip_AC_NAM_Actor_Name(
            p_owner => COALESCE(:NEW.AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_NAM_ChangedAt, v_now),
            p_value => :NEW.AC_NAM_Actor_Name
        );
    END IF;
    v_GEN := :NEW.GEN_ID;
    IF v_GEN IS NULL AND :NEW.GEN_Gender IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.GEN_ID
            FROM
                GEN_Gender k
            WHERE
                k.GEN_Gender = :NEW.GEN_Gender
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_GEN := kv.GEN_ID;
        END LOOP;
    END IF;
    IF v_GEN IS NOT NULL THEN
        ip_AC_GEN_Actor_Gender(
            p_owner => COALESCE(:NEW.AC_ID, v_id),
            p_value => v_GEN
        );
    END IF;
    v_PLV := :NEW.PLV_ID;
    IF v_PLV IS NULL AND :NEW.PLV_ProfessionalLevel IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PLV_ID
            FROM
                PLV_ProfessionalLevel k
            WHERE
                k.PLV_Checksum = STANDARD_HASH(:NEW.PLV_ProfessionalLevel, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PLV := kv.PLV_ID;
        END LOOP;
    END IF;
    IF v_PLV IS NOT NULL THEN
        ip_AC_PLV_Actor_ProfessionalLevel(
            p_owner => COALESCE(:NEW.AC_ID, v_id),
            p_changing => COALESCE(:NEW.AC_PLV_ChangedAt, v_now),
            p_value => v_PLV
        );
    END IF;
END it_lAC_Actor;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_Actor
INSTEAD OF UPDATE ON lAC_Actor
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_GEN number(3);
    v_PLV number(3);
BEGIN
    IF (:NEW.AC_ID <> :OLD.AC_ID
        OR (:NEW.AC_ID IS NULL AND :OLD.AC_ID IS NOT NULL)
        OR (:NEW.AC_ID IS NOT NULL AND :OLD.AC_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID is not updatable.');
    END IF;
    IF (:NEW.AC_NAM_Actor_Name <> :OLD.AC_NAM_Actor_Name
        OR (:NEW.AC_NAM_Actor_Name IS NULL AND :OLD.AC_NAM_Actor_Name IS NOT NULL)
        OR (:NEW.AC_NAM_Actor_Name IS NOT NULL AND :OLD.AC_NAM_Actor_Name IS NULL))
    OR (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.AC_NAM_Actor_Name IS NOT NULL THEN
            ip_AC_NAM_Actor_Name(
                p_owner => COALESCE(:NEW.AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_NAM_ChangedAt <> :OLD.AC_NAM_ChangedAt
                        OR (:NEW.AC_NAM_ChangedAt IS NULL AND :OLD.AC_NAM_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_NAM_ChangedAt IS NOT NULL AND :OLD.AC_NAM_ChangedAt IS NULL))
                    THEN :NEW.AC_NAM_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.AC_NAM_Actor_Name
            );
        END IF;
    END IF;
    IF (:NEW.GEN_ID <> :OLD.GEN_ID
        OR (:NEW.GEN_ID IS NULL AND :OLD.GEN_ID IS NOT NULL)
        OR (:NEW.GEN_ID IS NOT NULL AND :OLD.GEN_ID IS NULL))
    OR (:NEW.GEN_Gender <> :OLD.GEN_Gender
        OR (:NEW.GEN_Gender IS NULL AND :OLD.GEN_Gender IS NOT NULL)
        OR (:NEW.GEN_Gender IS NOT NULL AND :OLD.GEN_Gender IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_GEN := :NEW.GEN_ID;
        IF (v_GEN = :OLD.GEN_ID OR (v_GEN IS NULL AND :OLD.GEN_ID IS NULL))
        AND :NEW.GEN_Gender IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.GEN_ID
                FROM
                    GEN_Gender k
                WHERE
                    k.GEN_Gender = :NEW.GEN_Gender
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_GEN := kv.GEN_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_GEN IS NOT NULL AND (
            :OLD.GEN_ID IS NULL OR
            :OLD.GEN_ID <> v_GEN
        ) THEN
            ip_AC_GEN_Actor_Gender(
                p_owner => COALESCE(:NEW.AC_ID, :NEW.AC_ID),
                p_value => v_GEN
            );
        END IF;
    END IF;
    IF (:NEW.PLV_ID <> :OLD.PLV_ID
        OR (:NEW.PLV_ID IS NULL AND :OLD.PLV_ID IS NOT NULL)
        OR (:NEW.PLV_ID IS NOT NULL AND :OLD.PLV_ID IS NULL))
    OR (:NEW.PLV_ProfessionalLevel <> :OLD.PLV_ProfessionalLevel
        OR (:NEW.PLV_ProfessionalLevel IS NULL AND :OLD.PLV_ProfessionalLevel IS NOT NULL)
        OR (:NEW.PLV_ProfessionalLevel IS NOT NULL AND :OLD.PLV_ProfessionalLevel IS NULL))
    OR (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
    THEN
        -- the identity of the knot value, given as it is or looked up from the value
        v_PLV := :NEW.PLV_ID;
        IF (v_PLV = :OLD.PLV_ID OR (v_PLV IS NULL AND :OLD.PLV_ID IS NULL))
        AND :NEW.PLV_ProfessionalLevel IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.PLV_ID
                FROM
                    PLV_ProfessionalLevel k
                WHERE
                    k.PLV_Checksum = STANDARD_HASH(:NEW.PLV_ProfessionalLevel, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_PLV := kv.PLV_ID;
            END LOOP;
        END IF;
        -- a value that is left as it is states nothing
        IF v_PLV IS NOT NULL AND (
            (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL)) OR
            :OLD.PLV_ID IS NULL OR
            :OLD.PLV_ID <> v_PLV
        ) THEN
            ip_AC_PLV_Actor_ProfessionalLevel(
                p_owner => COALESCE(:NEW.AC_ID, :NEW.AC_ID),
                p_changing => CASE
                    WHEN (:NEW.AC_PLV_ChangedAt <> :OLD.AC_PLV_ChangedAt
                        OR (:NEW.AC_PLV_ChangedAt IS NULL AND :OLD.AC_PLV_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_PLV_ChangedAt IS NOT NULL AND :OLD.AC_PLV_ChangedAt IS NULL))
                    THEN :NEW.AC_PLV_ChangedAt
                    ELSE v_now
                END,
                p_value => v_PLV
            );
        END IF;
    END IF;
END ut_lAC_Actor;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_Actor
INSTEAD OF DELETE ON lAC_Actor
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_NAM_Actor_Name x
    WHERE
        x.AC_ID = :OLD.AC_ID
    AND
        x.AC_NAM_ChangedAt = :OLD.AC_NAM_ChangedAt
    ;
    DELETE FROM
        AC_GEN_Actor_Gender x
    WHERE
        x.AC_ID = :OLD.AC_ID
    ;
    DELETE FROM
        AC_PLV_Actor_ProfessionalLevel x
    WHERE
        x.AC_ID = :OLD.AC_ID
    AND
        x.AC_PLV_ChangedAt = :OLD.AC_PLV_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        AC_Actor a
    WHERE
        a.AC_ID = :OLD.AC_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            AC_NAM_Actor_Name x
        WHERE
            x.AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            AC_GEN_Actor_Gender x
        WHERE
            x.AC_ID = a.AC_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            AC_PLV_Actor_ProfessionalLevel x
        WHERE
            x.AC_ID = a.AC_ID
    )
    ;
END dt_lAC_Actor;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_Program
INSTEAD OF INSERT ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_id number(10);
BEGIN
    v_id := :NEW.PR_ID;
    IF v_id IS NULL THEN
        INSERT INTO PR_Program (
            PR_Dummy
        )
        VALUES (
            NULL
        )
        RETURNING PR_ID INTO v_id;
    END IF;
    IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
        ip_PR_NAM_Program_Name(
            p_owner => COALESCE(:NEW.PR_ID, v_id),
            p_value => :NEW.PR_NAM_Program_Name
        );
    END IF;
    IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
        ip_PR_LEN_Program_Length(
            p_owner => COALESCE(:NEW.PR_ID, v_id),
            p_changing => COALESCE(:NEW.PR_LEN_ChangedAt, v_now),
            p_value => :NEW.PR_LEN_Program_Length
        );
    END IF;
END it_lPR_Program;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lPR_Program
INSTEAD OF UPDATE ON lPR_Program
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    IF (:NEW.PR_ID <> :OLD.PR_ID
        OR (:NEW.PR_ID IS NULL AND :OLD.PR_ID IS NOT NULL)
        OR (:NEW.PR_ID IS NOT NULL AND :OLD.PR_ID IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID is not updatable.');
    END IF;
    IF (:NEW.PR_NAM_Program_Name <> :OLD.PR_NAM_Program_Name
        OR (:NEW.PR_NAM_Program_Name IS NULL AND :OLD.PR_NAM_Program_Name IS NOT NULL)
        OR (:NEW.PR_NAM_Program_Name IS NOT NULL AND :OLD.PR_NAM_Program_Name IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_NAM_Program_Name IS NOT NULL THEN
            ip_PR_NAM_Program_Name(
                p_owner => COALESCE(:NEW.PR_ID, :NEW.PR_ID),
                p_value => :NEW.PR_NAM_Program_Name
            );
        END IF;
    END IF;
    IF (:NEW.PR_LEN_Program_Length <> :OLD.PR_LEN_Program_Length
        OR (:NEW.PR_LEN_Program_Length IS NULL AND :OLD.PR_LEN_Program_Length IS NOT NULL)
        OR (:NEW.PR_LEN_Program_Length IS NOT NULL AND :OLD.PR_LEN_Program_Length IS NULL))
    OR (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
    THEN
        -- a value that is left as it is states nothing; what is stated is a value that is not null
        IF :NEW.PR_LEN_Program_Length IS NOT NULL THEN
            ip_PR_LEN_Program_Length(
                p_owner => COALESCE(:NEW.PR_ID, :NEW.PR_ID),
                p_changing => CASE
                    WHEN (:NEW.PR_LEN_ChangedAt <> :OLD.PR_LEN_ChangedAt
                        OR (:NEW.PR_LEN_ChangedAt IS NULL AND :OLD.PR_LEN_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_LEN_ChangedAt IS NOT NULL AND :OLD.PR_LEN_ChangedAt IS NULL))
                    THEN :NEW.PR_LEN_ChangedAt
                    ELSE v_now
                END,
                p_value => :NEW.PR_LEN_Program_Length
            );
        END IF;
    END IF;
END ut_lPR_Program;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lPR_Program
INSTEAD OF DELETE ON lPR_Program
FOR EACH ROW
BEGIN
    DELETE FROM
        PR_NAM_Program_Name x
    WHERE
        x.PR_ID = :OLD.PR_ID
    ;
    DELETE FROM
        PR_LEN_Program_Length x
    WHERE
        x.PR_ID = :OLD.PR_ID
    AND
        x.PR_LEN_ChangedAt = :OLD.PR_LEN_ChangedAt
    ;
    -- an anchor that has no attribute rows left is removed
    DELETE FROM
        PR_Program a
    WHERE
        a.PR_ID = :OLD.PR_ID
    AND NOT EXISTS (
        SELECT
            1
        FROM
            PR_NAM_Program_Name x
        WHERE
            x.PR_ID = a.PR_ID
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            PR_LEN_Program_Length x
        WHERE
            x.PR_ID = a.PR_ID
    )
    ;
END dt_lPR_Program;
/
