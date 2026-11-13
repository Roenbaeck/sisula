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
-- ip_EV_QTY_Event_Quantity states a value of EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_QTY_Event_Quantity (
    p_owner IN EV_QTY_Event_Quantity.EV_QTY_EV_ID%TYPE,
    p_value IN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity%TYPE,
    p_metadata IN EV_QTY_Event_Quantity.Metadata_EV_QTY%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity%TYPE,
        b IN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_QTY_Event_Quantity
        FROM
            EV_QTY_Event_Quantity x
        WHERE
            x.EV_QTY_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_QTY_Event_Quantity, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_QTY_Event_Quantity for: ' || p_owner);
    END LOOP;
    INSERT INTO EV_QTY_Event_Quantity (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_QTY_Event_Quantity;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_PLC_Event_Place states a value of EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_PLC_Event_Place (
    p_owner IN EV_PLC_Event_Place.EV_PLC_EV_ID%TYPE,
    p_changing IN EV_PLC_Event_Place.EV_PLC_ChangedAt%TYPE,
    p_value IN EV_PLC_Event_Place.EV_PLC_Event_Place%TYPE,
    p_metadata IN EV_PLC_Event_Place.Metadata_EV_PLC%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN EV_PLC_Event_Place.EV_PLC_Event_Place%TYPE,
        b IN EV_PLC_Event_Place.EV_PLC_Event_Place%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = p_owner
        AND
            x.EV_PLC_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_PLC_Event_Place, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_PLC_Event_Place for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place p
        WHERE
            p.EV_PLC_EV_ID = p_owner
        AND
            p.EV_PLC_ChangedAt < p_changing
        ORDER BY
            p.EV_PLC_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.EV_PLC_Event_Place, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.EV_PLC_Event_Place
        FROM
            EV_PLC_Event_Place f
        WHERE
            f.EV_PLC_EV_ID = p_owner
        AND
            f.EV_PLC_ChangedAt > p_changing
        ORDER BY
            f.EV_PLC_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.EV_PLC_Event_Place, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in EV_PLC_Event_Place for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO EV_PLC_Event_Place (
        Metadata_EV_PLC,
        EV_PLC_EV_ID,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_PLC_Event_Place;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NAM_Subject_Name states a value of SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NAM_Subject_Name (
    p_owner IN SU_NAM_Subject_Name.SU_NAM_SU_ID%TYPE,
    p_value IN SU_NAM_Subject_Name.SU_NAM_Subject_Name%TYPE,
    p_metadata IN SU_NAM_Subject_Name.Metadata_SU_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_NAM_Subject_Name.SU_NAM_Subject_Name%TYPE,
        b IN SU_NAM_Subject_Name.SU_NAM_Subject_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_NAM_Subject_Name
        FROM
            SU_NAM_Subject_Name x
        WHERE
            x.SU_NAM_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_NAM_Subject_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NAM_Subject_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_NAM_Subject_Name (
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_NAM_Subject_Name;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_COD_Subject_Code states a value of SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_COD_Subject_Code (
    p_owner IN SU_COD_Subject_Code.SU_COD_SU_ID%TYPE,
    p_value IN SU_COD_Subject_Code.SU_COD_Subject_Code%TYPE,
    p_metadata IN SU_COD_Subject_Code.Metadata_SU_COD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_COD_Subject_Code.SU_COD_Subject_Code%TYPE,
        b IN SU_COD_Subject_Code.SU_COD_Subject_Code%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_COD_Subject_Code
        FROM
            SU_COD_Subject_Code x
        WHERE
            x.SU_COD_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_COD_Subject_Code, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_COD_Subject_Code for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_COD_Subject_Code (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_COD_Subject_Code;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_GRD_Subject_Grade states a value of SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_GRD_Subject_Grade (
    p_owner IN SU_GRD_Subject_Grade.SU_GRD_SU_ID%TYPE,
    p_value IN SU_GRD_Subject_Grade.SU_GRD_GRD_ID%TYPE,
    p_metadata IN SU_GRD_Subject_Grade.Metadata_SU_GRD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_GRD_Subject_Grade.SU_GRD_GRD_ID%TYPE,
        b IN SU_GRD_Subject_Grade.SU_GRD_GRD_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_GRD_GRD_ID
        FROM
            SU_GRD_Subject_Grade x
        WHERE
            x.SU_GRD_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_GRD_GRD_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_GRD_Subject_Grade for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_GRD_Subject_Grade (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_GRD_Subject_Grade;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_NOT_Subject_Note states a value of SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_NOT_Subject_Note (
    p_owner IN SU_NOT_Subject_Note.SU_NOT_SU_ID%TYPE,
    p_value IN SU_NOT_Subject_Note.SU_NOT_Subject_Note%TYPE,
    p_metadata IN SU_NOT_Subject_Note.Metadata_SU_NOT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_NOT_Subject_Note.SU_NOT_Subject_Note%TYPE,
        b IN SU_NOT_Subject_Note.SU_NOT_Subject_Note%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN DBMS_LOB.COMPARE(a, b) = 0;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.SU_NOT_Subject_Note
        FROM
            SU_NOT_Subject_Note x
        WHERE
            x.SU_NOT_SU_ID = p_owner
    ) LOOP
        IF same(r.SU_NOT_Subject_Note, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_NOT_Subject_Note for: ' || p_owner);
    END LOOP;
    INSERT INTO SU_NOT_Subject_Note (
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_SU_NOT_Subject_Note;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TTL_Subject_Title states a value of SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TTL_Subject_Title (
    p_owner IN SU_TTL_Subject_Title.SU_TTL_SU_ID%TYPE,
    p_changing IN SU_TTL_Subject_Title.SU_TTL_ChangedAt%TYPE,
    p_value IN SU_TTL_Subject_Title.SU_TTL_Subject_Title%TYPE,
    p_metadata IN SU_TTL_Subject_Title.Metadata_SU_TTL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_TTL_Subject_Title.SU_TTL_Subject_Title%TYPE,
        b IN SU_TTL_Subject_Title.SU_TTL_Subject_Title%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_TTL_Subject_Title
        FROM
            SU_TTL_Subject_Title x
        WHERE
            x.SU_TTL_SU_ID = p_owner
        AND
            x.SU_TTL_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_TTL_Subject_Title, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TTL_Subject_Title for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_TTL_Subject_Title (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_TTL_Subject_Title;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_STA_Subject_State states a value of SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_STA_Subject_State (
    p_owner IN SU_STA_Subject_State.SU_STA_SU_ID%TYPE,
    p_changing IN SU_STA_Subject_State.SU_STA_ChangedAt%TYPE,
    p_value IN SU_STA_Subject_State.SU_STA_Subject_State%TYPE,
    p_metadata IN SU_STA_Subject_State.Metadata_SU_STA%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_STA_Subject_State.SU_STA_Subject_State%TYPE,
        b IN SU_STA_Subject_State.SU_STA_Subject_State%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State x
        WHERE
            x.SU_STA_SU_ID = p_owner
        AND
            x.SU_STA_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_STA_Subject_State, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_STA_Subject_State for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State p
        WHERE
            p.SU_STA_SU_ID = p_owner
        AND
            p.SU_STA_ChangedAt < p_changing
        ORDER BY
            p.SU_STA_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_STA_Subject_State, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.SU_STA_Subject_State
        FROM
            SU_STA_Subject_State f
        WHERE
            f.SU_STA_SU_ID = p_owner
        AND
            f.SU_STA_ChangedAt > p_changing
        ORDER BY
            f.SU_STA_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_STA_Subject_State, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in SU_STA_Subject_State for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO SU_STA_Subject_State (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_STA_Subject_State;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LBL_Subject_Label states a value of SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LBL_Subject_Label (
    p_owner IN SU_LBL_Subject_Label.SU_LBL_SU_ID%TYPE,
    p_changing IN SU_LBL_Subject_Label.SU_LBL_ChangedAt%TYPE,
    p_value IN SU_LBL_Subject_Label.SU_LBL_Subject_Label%TYPE,
    p_metadata IN SU_LBL_Subject_Label.Metadata_SU_LBL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_LBL_Subject_Label.SU_LBL_Subject_Label%TYPE,
        b IN SU_LBL_Subject_Label.SU_LBL_Subject_Label%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_SU_ID = p_owner
        AND
            x.SU_LBL_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_LBL_Subject_Label, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LBL_Subject_Label for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label p
        WHERE
            p.SU_LBL_SU_ID = p_owner
        AND
            p.SU_LBL_ChangedAt < p_changing
        ORDER BY
            p.SU_LBL_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_LBL_Subject_Label, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.SU_LBL_ChangedAt,
            f.SU_LBL_Subject_Label
        FROM
            SU_LBL_Subject_Label f
        WHERE
            f.SU_LBL_SU_ID = p_owner
        AND
            f.SU_LBL_ChangedAt > p_changing
        ORDER BY
            f.SU_LBL_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_LBL_Subject_Label, p_value) THEN
            DELETE FROM
                SU_LBL_Subject_Label
            WHERE
                SU_LBL_SU_ID = p_owner
            AND
                SU_LBL_ChangedAt = r.SU_LBL_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO SU_LBL_Subject_Label (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_LBL_Subject_Label;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TAG_Subject_Tag states a value of SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TAG_Subject_Tag (
    p_owner IN SU_TAG_Subject_Tag.SU_TAG_SU_ID%TYPE,
    p_changing IN SU_TAG_Subject_Tag.SU_TAG_ChangedAt%TYPE,
    p_value IN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag%TYPE,
    p_metadata IN SU_TAG_Subject_Tag.Metadata_SU_TAG%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag%TYPE,
        b IN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag x
        WHERE
            x.SU_TAG_SU_ID = p_owner
        AND
            x.SU_TAG_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_TAG_Subject_Tag, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TAG_Subject_Tag for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag p
        WHERE
            p.SU_TAG_SU_ID = p_owner
        AND
            p.SU_TAG_ChangedAt < p_changing
        ORDER BY
            p.SU_TAG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_TAG_Subject_Tag, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.SU_TAG_ChangedAt,
            f.SU_TAG_Subject_Tag
        FROM
            SU_TAG_Subject_Tag f
        WHERE
            f.SU_TAG_SU_ID = p_owner
        AND
            f.SU_TAG_ChangedAt > p_changing
        ORDER BY
            f.SU_TAG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.SU_TAG_Subject_Tag, p_value) THEN
            DELETE FROM
                SU_TAG_Subject_Tag
            WHERE
                SU_TAG_SU_ID = p_owner
            AND
                SU_TAG_ChangedAt = r.SU_TAG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO SU_TAG_Subject_Tag (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_TAG_Subject_Tag;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_LVL_Subject_Level states a value of SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_LVL_Subject_Level (
    p_owner IN SU_LVL_Subject_Level.SU_LVL_SU_ID%TYPE,
    p_changing IN SU_LVL_Subject_Level.SU_LVL_ChangedAt%TYPE,
    p_value IN SU_LVL_Subject_Level.SU_LVL_GRD_ID%TYPE,
    p_metadata IN SU_LVL_Subject_Level.Metadata_SU_LVL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_LVL_Subject_Level.SU_LVL_GRD_ID%TYPE,
        b IN SU_LVL_Subject_Level.SU_LVL_GRD_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_LVL_GRD_ID
        FROM
            SU_LVL_Subject_Level x
        WHERE
            x.SU_LVL_SU_ID = p_owner
        AND
            x.SU_LVL_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_LVL_GRD_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_LVL_Subject_Level for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_LVL_Subject_Level (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_LVL_Subject_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_TXT_Subject_Text states a value of SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_TXT_Subject_Text (
    p_owner IN SU_TXT_Subject_Text.SU_TXT_SU_ID%TYPE,
    p_changing IN SU_TXT_Subject_Text.SU_TXT_ChangedAt%TYPE,
    p_value IN SU_TXT_Subject_Text.SU_TXT_Subject_Text%TYPE,
    p_metadata IN SU_TXT_Subject_Text.Metadata_SU_TXT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_TXT_Subject_Text.SU_TXT_Subject_Text%TYPE,
        b IN SU_TXT_Subject_Text.SU_TXT_Subject_Text%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN DBMS_LOB.COMPARE(a, b) = 0;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_TXT_Subject_Text
        FROM
            SU_TXT_Subject_Text x
        WHERE
            x.SU_TXT_SU_ID = p_owner
        AND
            x.SU_TXT_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_TXT_Subject_Text, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_TXT_Subject_Text for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_TXT_Subject_Text (
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_TXT_Subject_Text;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ASR_Subject_Assessment states a value of SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ASR_Subject_Assessment (
    p_owner IN SU_ASR_Subject_Assessment.SU_ASR_SU_ID%TYPE,
    p_changing IN SU_ASR_Subject_Assessment.SU_ASR_ChangedAt%TYPE,
    p_value IN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment%TYPE,
    p_metadata IN SU_ASR_Subject_Assessment.Metadata_SU_ASR%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment%TYPE,
        b IN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_ASR_Subject_Assessment
        FROM
            SU_ASR_Subject_Assessment x
        WHERE
            x.SU_ASR_SU_ID = p_owner
        AND
            x.SU_ASR_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_ASR_Subject_Assessment, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ASR_Subject_Assessment for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_ASR_Subject_Assessment (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_ASR_Subject_Assessment;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_SU_ERS_Subject_Erasable states a value of SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_SU_ERS_Subject_Erasable (
    p_owner IN SU_ERS_Subject_Erasable.SU_ERS_SU_ID%TYPE,
    p_changing IN SU_ERS_Subject_Erasable.SU_ERS_ChangedAt%TYPE,
    p_value IN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable%TYPE,
    p_metadata IN SU_ERS_Subject_Erasable.Metadata_SU_ERS%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable%TYPE,
        b IN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.SU_ERS_Subject_Erasable
        FROM
            SU_ERS_Subject_Erasable x
        WHERE
            x.SU_ERS_SU_ID = p_owner
        AND
            x.SU_ERS_ChangedAt = p_changing
    ) LOOP
        IF same(r.SU_ERS_Subject_Erasable, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in SU_ERS_Subject_Erasable for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO SU_ERS_Subject_Erasable (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_SU_ERS_Subject_Erasable;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_OB_NAM_Object_Name states a value of OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_OB_NAM_Object_Name (
    p_owner IN OB_NAM_Object_Name.OB_NAM_OB_ID%TYPE,
    p_value IN OB_NAM_Object_Name.OB_NAM_Object_Name%TYPE,
    p_metadata IN OB_NAM_Object_Name.Metadata_OB_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN OB_NAM_Object_Name.OB_NAM_Object_Name%TYPE,
        b IN OB_NAM_Object_Name.OB_NAM_Object_Name%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.OB_NAM_Object_Name
        FROM
            OB_NAM_Object_Name x
        WHERE
            x.OB_NAM_OB_ID = p_owner
    ) LOOP
        IF same(r.OB_NAM_Object_Name, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in OB_NAM_Object_Name for: ' || p_owner);
    END LOOP;
    INSERT INTO OB_NAM_Object_Name (
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_OB_NAM_Object_Name;
/
