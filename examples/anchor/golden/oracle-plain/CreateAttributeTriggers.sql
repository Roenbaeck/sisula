-- ATTRIBUTE INSERT PROCEDURES ----------------------------------------------------------------------------------------
--
-- The procedures here state one value of an attribute, in the way that the model says: a row that is already there is
-- not stored again, another value at a time that has a value is a contradiction, and a value that is the same as the
-- one before it (a restatement) is skipped by an idempotent attribute and refused by one that may not be restated.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are
-- stored. Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- These are procedures and not triggers on the attribute tables, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. The triggers on the latest views call them, and so can a load:
--
--     BEGIN ip_AC_NAM_Actor_Name(p_owner => 1, p_changing => SYSTIMESTAMP, p_value => 'Ann', p_metadata => 1); END;
--
-- A row put straight into an attribute table by an INSERT is not looked at.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_DAT_Event_Date states a value of EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_DAT_Event_Date (
    p_owner IN EV_DAT_Event_Date.EV_ID%TYPE,
    p_value IN EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE,
        b IN EV_DAT_Event_Date.EV_DAT_Event_Date%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_DAT_Event_Date
        FROM
            EV_DAT_Event_Date x
        WHERE
            x.EV_ID = p_owner
    ) LOOP
        IF same(r.EV_DAT_Event_Date, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Event_Date for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_DAT_Event_Date (
        EV_ID,
        EV_DAT_Event_Date
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_EV_DAT_Event_Date;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Event_Audience states a value of EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_AUD_Event_Audience (
    p_owner IN EV_AUD_Event_Audience.EV_ID%TYPE,
    p_value IN EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE,
        b IN EV_AUD_Event_Audience.EV_AUD_Event_Audience%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_AUD_Event_Audience
        FROM
            EV_AUD_Event_Audience x
        WHERE
            x.EV_ID = p_owner
    ) LOOP
        IF same(r.EV_AUD_Event_Audience, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Event_Audience for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_AUD_Event_Audience (
        EV_ID,
        EV_AUD_Event_Audience
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_EV_AUD_Event_Audience;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Event_Revenue states a value of EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_REV_Event_Revenue (
    p_owner IN EV_REV_Event_Revenue.EV_ID%TYPE,
    p_value IN EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE,
        b IN EV_REV_Event_Revenue.EV_REV_Event_Revenue%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_REV_Event_Revenue
        FROM
            EV_REV_Event_Revenue x
        WHERE
            x.EV_ID = p_owner
    ) LOOP
        IF same(r.EV_REV_Event_Revenue, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Event_Revenue for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_REV_Event_Revenue (
        EV_ID,
        EV_REV_Event_Revenue
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_EV_REV_Event_Revenue;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Stage_Name states a value of ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_NAM_Stage_Name (
    p_owner IN ST_NAM_Stage_Name.ST_ID%TYPE,
    p_changing IN ST_NAM_Stage_Name.ST_NAM_ChangedAt%TYPE,
    p_value IN ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE,
        b IN ST_NAM_Stage_Name.ST_NAM_Stage_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_NAM_Stage_Name
        FROM
            ST_NAM_Stage_Name x
        WHERE
            x.ST_ID = p_owner
        AND
            x.ST_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_NAM_Stage_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Stage_Name for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO ST_NAM_Stage_Name (
        ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_NAM_Stage_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Stage_Location states a value of ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_LOC_Stage_Location (
    p_owner IN ST_LOC_Stage_Location.ST_ID%TYPE,
    p_value IN ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE,
        b IN ST_LOC_Stage_Location.ST_LOC_Stage_Location%TYPE
    ) RETURN BOOLEAN
    IS
        v_same NUMBER;
    BEGIN
        SELECT CASE WHEN STANDARD_HASH(a, 'MD5') = STANDARD_HASH(b, 'MD5') THEN 1 ELSE 0 END INTO v_same FROM dual;
        RETURN v_same = 1;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.ST_LOC_Stage_Location
        FROM
            ST_LOC_Stage_Location x
        WHERE
            x.ST_ID = p_owner
    ) LOOP
        IF same(r.ST_LOC_Stage_Location, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Stage_Location for: ' || p_owner);
    END LOOP;
    INSERT INTO ST_LOC_Stage_Location (
        ST_ID,
        ST_LOC_Stage_Location
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_ST_LOC_Stage_Location;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Stage_Average states a value of ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_AVG_Stage_Average (
    p_owner IN ST_AVG_Stage_Average.ST_ID%TYPE,
    p_changing IN ST_AVG_Stage_Average.ST_AVG_ChangedAt%TYPE,
    p_value IN ST_AVG_Stage_Average.UTL_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_AVG_Stage_Average.UTL_ID%TYPE,
        b IN ST_AVG_Stage_Average.UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.UTL_ID
        FROM
            ST_AVG_Stage_Average x
        WHERE
            x.ST_ID = p_owner
        AND
            x.ST_AVG_ChangedAt = p_changing
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Stage_Average for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.UTL_ID
        FROM
            ST_AVG_Stage_Average p
        WHERE
            p.ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < p_changing
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.ST_AVG_ChangedAt,
            f.UTL_ID
        FROM
            ST_AVG_Stage_Average f
        WHERE
            f.ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > p_changing
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            DELETE FROM
                ST_AVG_Stage_Average
            WHERE
                ST_ID = p_owner
            AND
                ST_AVG_ChangedAt = r.ST_AVG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO ST_AVG_Stage_Average (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_AVG_Stage_Average;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Stage_Minimum states a value of ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_MIN_Stage_Minimum (
    p_owner IN ST_MIN_Stage_Minimum.ST_ID%TYPE,
    p_value IN ST_MIN_Stage_Minimum.UTL_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN ST_MIN_Stage_Minimum.UTL_ID%TYPE,
        b IN ST_MIN_Stage_Minimum.UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.UTL_ID
        FROM
            ST_MIN_Stage_Minimum x
        WHERE
            x.ST_ID = p_owner
    ) LOOP
        IF same(r.UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Stage_Minimum for: ' || p_owner);
    END LOOP;
    INSERT INTO ST_MIN_Stage_Minimum (
        ST_ID,
        UTL_ID
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_ST_MIN_Stage_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Actor_Name states a value of AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_NAM_Actor_Name (
    p_owner IN AC_NAM_Actor_Name.AC_ID%TYPE,
    p_changing IN AC_NAM_Actor_Name.AC_NAM_ChangedAt%TYPE,
    p_value IN AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE,
        b IN AC_NAM_Actor_Name.AC_NAM_Actor_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name x
        WHERE
            x.AC_ID = p_owner
        AND
            x.AC_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_NAM_Actor_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Actor_Name for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name p
        WHERE
            p.AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < p_changing
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Actor_Name, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.AC_NAM_Actor_Name
        FROM
            AC_NAM_Actor_Name f
        WHERE
            f.AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > p_changing
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Actor_Name, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Actor_Name for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO AC_NAM_Actor_Name (
        AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_NAM_Actor_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Actor_Gender states a value of AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_GEN_Actor_Gender (
    p_owner IN AC_GEN_Actor_Gender.AC_ID%TYPE,
    p_value IN AC_GEN_Actor_Gender.GEN_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN AC_GEN_Actor_Gender.GEN_ID%TYPE,
        b IN AC_GEN_Actor_Gender.GEN_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.GEN_ID
        FROM
            AC_GEN_Actor_Gender x
        WHERE
            x.AC_ID = p_owner
    ) LOOP
        IF same(r.GEN_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Actor_Gender for: ' || p_owner);
    END LOOP;
    INSERT INTO AC_GEN_Actor_Gender (
        AC_ID,
        GEN_ID
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_AC_GEN_Actor_Gender;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Actor_ProfessionalLevel states a value of AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_PLV_Actor_ProfessionalLevel (
    p_owner IN AC_PLV_Actor_ProfessionalLevel.AC_ID%TYPE,
    p_changing IN AC_PLV_Actor_ProfessionalLevel.AC_PLV_ChangedAt%TYPE,
    p_value IN AC_PLV_Actor_ProfessionalLevel.PLV_ID%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN AC_PLV_Actor_ProfessionalLevel.PLV_ID%TYPE,
        b IN AC_PLV_Actor_ProfessionalLevel.PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.PLV_ID
        FROM
            AC_PLV_Actor_ProfessionalLevel x
        WHERE
            x.AC_ID = p_owner
        AND
            x.AC_PLV_ChangedAt = p_changing
    ) LOOP
        IF same(r.PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO AC_PLV_Actor_ProfessionalLevel (
        AC_ID,
        AC_PLV_ChangedAt,
        PLV_ID
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_PLV_Actor_ProfessionalLevel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Program_Name states a value of PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_NAM_Program_Name (
    p_owner IN PR_NAM_Program_Name.PR_ID%TYPE,
    p_value IN PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE,
        b IN PR_NAM_Program_Name.PR_NAM_Program_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.PR_NAM_Program_Name
        FROM
            PR_NAM_Program_Name x
        WHERE
            x.PR_ID = p_owner
    ) LOOP
        IF same(r.PR_NAM_Program_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Program_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO PR_NAM_Program_Name (
        PR_ID,
        PR_NAM_Program_Name
    )
    VALUES (
        p_owner,
        p_value
    );
END ip_PR_NAM_Program_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Program_Length states a value of PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_LEN_Program_Length (
    p_owner IN PR_LEN_Program_Length.PR_ID%TYPE,
    p_changing IN PR_LEN_Program_Length.PR_LEN_ChangedAt%TYPE,
    p_value IN PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE,
        b IN PR_LEN_Program_Length.PR_LEN_Program_Length%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.PR_LEN_Program_Length
        FROM
            PR_LEN_Program_Length x
        WHERE
            x.PR_ID = p_owner
        AND
            x.PR_LEN_ChangedAt = p_changing
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Program_Length for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.PR_LEN_Program_Length
        FROM
            PR_LEN_Program_Length p
        WHERE
            p.PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < p_changing
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.PR_LEN_ChangedAt,
            f.PR_LEN_Program_Length
        FROM
            PR_LEN_Program_Length f
        WHERE
            f.PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > p_changing
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Program_Length, p_value) THEN
            DELETE FROM
                PR_LEN_Program_Length
            WHERE
                PR_ID = p_owner
            AND
                PR_LEN_ChangedAt = r.PR_LEN_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO PR_LEN_Program_Length (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    VALUES (
        p_owner,
        p_changing,
        p_value
    );
END ip_PR_LEN_Program_Length;
/
