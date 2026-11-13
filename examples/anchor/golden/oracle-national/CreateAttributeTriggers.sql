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
-- ip_EV_DAT_Händelse_Datum states a value of EV_DAT_Händelse_Datum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_DAT_Händelse_Datum (
    p_owner IN attributes.EV_DAT_Händelse_Datum.EV_DAT_EV_ID%TYPE,
    p_value IN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum%TYPE,
    p_metadata IN attributes.EV_DAT_Händelse_Datum.Metadata_EV_DAT%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum%TYPE,
        b IN attributes.EV_DAT_Händelse_Datum.EV_DAT_Händelse_Datum%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_DAT_Händelse_Datum
        FROM
            attributes.EV_DAT_Händelse_Datum x
        WHERE
            x.EV_DAT_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_DAT_Händelse_Datum, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_DAT_Händelse_Datum for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_DAT_Händelse_Datum (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_Händelse_Datum
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_DAT_Händelse_Datum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_AUD_Händelse_Publik states a value of EV_AUD_Händelse_Publik
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_AUD_Händelse_Publik (
    p_owner IN attributes.EV_AUD_Händelse_Publik.EV_AUD_EV_ID%TYPE,
    p_value IN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik%TYPE,
    p_metadata IN attributes.EV_AUD_Händelse_Publik.Metadata_EV_AUD%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik%TYPE,
        b IN attributes.EV_AUD_Händelse_Publik.EV_AUD_Händelse_Publik%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_AUD_Händelse_Publik
        FROM
            attributes.EV_AUD_Händelse_Publik x
        WHERE
            x.EV_AUD_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_AUD_Händelse_Publik, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_AUD_Händelse_Publik for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_AUD_Händelse_Publik (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Händelse_Publik
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_AUD_Händelse_Publik;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_REV_Händelse_Intäkt states a value of EV_REV_Händelse_Intäkt
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_REV_Händelse_Intäkt (
    p_owner IN attributes.EV_REV_Händelse_Intäkt.EV_REV_EV_ID%TYPE,
    p_value IN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt%TYPE,
    p_metadata IN attributes.EV_REV_Händelse_Intäkt.Metadata_EV_REV%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt%TYPE,
        b IN attributes.EV_REV_Händelse_Intäkt.EV_REV_Händelse_Intäkt%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_REV_Händelse_Intäkt
        FROM
            attributes.EV_REV_Händelse_Intäkt x
        WHERE
            x.EV_REV_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_REV_Händelse_Intäkt, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_REV_Händelse_Intäkt for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_REV_Händelse_Intäkt (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_Händelse_Intäkt
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_REV_Händelse_Intäkt;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_STA_Händelse_Status states a value of EV_STA_Händelse_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_STA_Händelse_Status (
    p_owner IN attributes.EV_STA_Händelse_Status.EV_STA_EV_ID%TYPE,
    p_changing IN attributes.EV_STA_Händelse_Status.EV_STA_ChangedAt%TYPE,
    p_value IN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status%TYPE,
    p_metadata IN attributes.EV_STA_Händelse_Status.Metadata_EV_STA%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status%TYPE,
        b IN attributes.EV_STA_Händelse_Status.EV_STA_Händelse_Status%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_STA_Händelse_Status
        FROM
            attributes.EV_STA_Händelse_Status x
        WHERE
            x.EV_STA_EV_ID = p_owner
        AND
            x.EV_STA_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_STA_Händelse_Status, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_STA_Händelse_Status for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.EV_STA_Händelse_Status (
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Händelse_Status
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_STA_Händelse_Status;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_UTL_Händelse_Utnyttjande states a value of EV_UTL_Händelse_Utnyttjande
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_UTL_Händelse_Utnyttjande (
    p_owner IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_EV_ID%TYPE,
    p_value IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_UTL_ID%TYPE,
    p_metadata IN attributes.EV_UTL_Händelse_Utnyttjande.Metadata_EV_UTL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_UTL_ID%TYPE,
        b IN attributes.EV_UTL_Händelse_Utnyttjande.EV_UTL_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.EV_UTL_UTL_ID
        FROM
            attributes.EV_UTL_Händelse_Utnyttjande x
        WHERE
            x.EV_UTL_EV_ID = p_owner
    ) LOOP
        IF same(r.EV_UTL_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_UTL_Händelse_Utnyttjande for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.EV_UTL_Händelse_Utnyttjande (
        Metadata_EV_UTL,
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_EV_UTL_Händelse_Utnyttjande;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_LVL_Händelse_Level states a value of EV_LVL_Händelse_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_EV_LVL_Händelse_Level (
    p_owner IN attributes.EV_LVL_Händelse_Level.EV_LVL_EV_ID%TYPE,
    p_changing IN attributes.EV_LVL_Händelse_Level.EV_LVL_ChangedAt%TYPE,
    p_value IN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID%TYPE,
    p_metadata IN attributes.EV_LVL_Händelse_Level.Metadata_EV_LVL%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID%TYPE,
        b IN attributes.EV_LVL_Händelse_Level.EV_LVL_PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.EV_LVL_PLV_ID
        FROM
            attributes.EV_LVL_Händelse_Level x
        WHERE
            x.EV_LVL_EV_ID = p_owner
        AND
            x.EV_LVL_ChangedAt = p_changing
    ) LOOP
        IF same(r.EV_LVL_PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_LVL_Händelse_Level for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.EV_LVL_Händelse_Level (
        Metadata_EV_LVL,
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_EV_LVL_Händelse_Level;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_NAM_Scen_Namn states a value of ST_NAM_Scen_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_NAM_Scen_Namn (
    p_owner IN attributes.ST_NAM_Scen_Namn.ST_NAM_ST_ID%TYPE,
    p_changing IN attributes.ST_NAM_Scen_Namn.ST_NAM_ChangedAt%TYPE,
    p_value IN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn%TYPE,
    p_metadata IN attributes.ST_NAM_Scen_Namn.Metadata_ST_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn%TYPE,
        b IN attributes.ST_NAM_Scen_Namn.ST_NAM_Scen_Namn%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_NAM_Scen_Namn
        FROM
            attributes.ST_NAM_Scen_Namn x
        WHERE
            x.ST_NAM_ST_ID = p_owner
        AND
            x.ST_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_NAM_Scen_Namn, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_NAM_Scen_Namn for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.ST_NAM_Scen_Namn (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Scen_Namn
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_NAM_Scen_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_LOC_Scen_Plats states a value of ST_LOC_Scen_Plats
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_LOC_Scen_Plats (
    p_owner IN attributes.ST_LOC_Scen_Plats.ST_LOC_ST_ID%TYPE,
    p_value IN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats%TYPE,
    p_metadata IN attributes.ST_LOC_Scen_Plats.Metadata_ST_LOC%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats%TYPE,
        b IN attributes.ST_LOC_Scen_Plats.ST_LOC_Scen_Plats%TYPE
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
            x.ST_LOC_Scen_Plats
        FROM
            attributes.ST_LOC_Scen_Plats x
        WHERE
            x.ST_LOC_ST_ID = p_owner
    ) LOOP
        IF same(r.ST_LOC_Scen_Plats, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_LOC_Scen_Plats for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.ST_LOC_Scen_Plats (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Scen_Plats
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_ST_LOC_Scen_Plats;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_AVG_Scen_Medel states a value of ST_AVG_Scen_Medel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_AVG_Scen_Medel (
    p_owner IN attributes.ST_AVG_Scen_Medel.ST_AVG_ST_ID%TYPE,
    p_changing IN attributes.ST_AVG_Scen_Medel.ST_AVG_ChangedAt%TYPE,
    p_value IN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID%TYPE,
    p_metadata IN attributes.ST_AVG_Scen_Medel.Metadata_ST_AVG%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID%TYPE,
        b IN attributes.ST_AVG_Scen_Medel.ST_AVG_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel x
        WHERE
            x.ST_AVG_ST_ID = p_owner
        AND
            x.ST_AVG_ChangedAt = p_changing
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_AVG_Scen_Medel for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel p
        WHERE
            p.ST_AVG_ST_ID = p_owner
        AND
            p.ST_AVG_ChangedAt < p_changing
        ORDER BY
            p.ST_AVG_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.ST_AVG_ChangedAt,
            f.ST_AVG_UTL_ID
        FROM
            attributes.ST_AVG_Scen_Medel f
        WHERE
            f.ST_AVG_ST_ID = p_owner
        AND
            f.ST_AVG_ChangedAt > p_changing
        ORDER BY
            f.ST_AVG_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.ST_AVG_UTL_ID, p_value) THEN
            DELETE FROM
                attributes.ST_AVG_Scen_Medel
            WHERE
                ST_AVG_ST_ID = p_owner
            AND
                ST_AVG_ChangedAt = r.ST_AVG_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO attributes.ST_AVG_Scen_Medel (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_ST_AVG_Scen_Medel;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_MIN_Scen_Minimum states a value of ST_MIN_Scen_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_ST_MIN_Scen_Minimum (
    p_owner IN attributes.ST_MIN_Scen_Minimum.ST_MIN_ST_ID%TYPE,
    p_value IN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID%TYPE,
    p_metadata IN attributes.ST_MIN_Scen_Minimum.Metadata_ST_MIN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID%TYPE,
        b IN attributes.ST_MIN_Scen_Minimum.ST_MIN_UTL_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.ST_MIN_UTL_ID
        FROM
            attributes.ST_MIN_Scen_Minimum x
        WHERE
            x.ST_MIN_ST_ID = p_owner
    ) LOOP
        IF same(r.ST_MIN_UTL_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_MIN_Scen_Minimum for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.ST_MIN_Scen_Minimum (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_ST_MIN_Scen_Minimum;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_NAM_Skådespelare_Namn states a value of AC_NAM_Skådespelare_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_NAM_Skådespelare_Namn (
    p_owner IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_AC_ID%TYPE,
    p_changing IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_ChangedAt%TYPE,
    p_value IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn%TYPE,
    p_metadata IN attributes.AC_NAM_Skådespelare_Namn.Metadata_AC_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn%TYPE,
        b IN attributes.AC_NAM_Skådespelare_Namn.AC_NAM_Skådespelare_Namn%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn x
        WHERE
            x.AC_NAM_AC_ID = p_owner
        AND
            x.AC_NAM_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_NAM_Skådespelare_Namn, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an attribute that may not be restated refuses it)
    FOR r IN (
        SELECT
            p.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn p
        WHERE
            p.AC_NAM_AC_ID = p_owner
        AND
            p.AC_NAM_ChangedAt < p_changing
        ORDER BY
            p.AC_NAM_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Skådespelare_Namn, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.AC_NAM_Skådespelare_Namn
        FROM
            attributes.AC_NAM_Skådespelare_Namn f
        WHERE
            f.AC_NAM_AC_ID = p_owner
        AND
            f.AC_NAM_ChangedAt > p_changing
        ORDER BY
            f.AC_NAM_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.AC_NAM_Skådespelare_Namn, p_value) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Restatement in AC_NAM_Skådespelare_Namn for: ' || p_owner || ', ' || p_changing);
        END IF;
    END LOOP;
    INSERT INTO attributes.AC_NAM_Skådespelare_Namn (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Skådespelare_Namn
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_NAM_Skådespelare_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_GEN_Skådespelare_Kön states a value of AC_GEN_Skådespelare_Kön
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_GEN_Skådespelare_Kön (
    p_owner IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_AC_ID%TYPE,
    p_value IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID%TYPE,
    p_metadata IN attributes.AC_GEN_Skådespelare_Kön.Metadata_AC_GEN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID%TYPE,
        b IN attributes.AC_GEN_Skådespelare_Kön.AC_GEN_GEN_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.AC_GEN_GEN_ID
        FROM
            attributes.AC_GEN_Skådespelare_Kön x
        WHERE
            x.AC_GEN_AC_ID = p_owner
    ) LOOP
        IF same(r.AC_GEN_GEN_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_GEN_Skådespelare_Kön for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.AC_GEN_Skådespelare_Kön (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_AC_GEN_Skådespelare_Kön;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_PLV_Skådespelare_Yrkesnivå states a value of AC_PLV_Skådespelare_Yrkesnivå
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_AC_PLV_Skådespelare_Yrkesnivå (
    p_owner IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_AC_ID%TYPE,
    p_changing IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_ChangedAt%TYPE,
    p_value IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID%TYPE,
    p_metadata IN attributes.AC_PLV_Skådespelare_Yrkesnivå.Metadata_AC_PLV%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID%TYPE,
        b IN attributes.AC_PLV_Skådespelare_Yrkesnivå.AC_PLV_PLV_ID%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.AC_PLV_PLV_ID
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå x
        WHERE
            x.AC_PLV_AC_ID = p_owner
        AND
            x.AC_PLV_ChangedAt = p_changing
    ) LOOP
        IF same(r.AC_PLV_PLV_ID, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    INSERT INTO attributes.AC_PLV_Skådespelare_Yrkesnivå (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_AC_PLV_Skådespelare_Yrkesnivå;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_NAM_Föreställning_Namn states a value of PR_NAM_Föreställning_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_NAM_Föreställning_Namn (
    p_owner IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_PR_ID%TYPE,
    p_value IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn%TYPE,
    p_metadata IN attributes.PR_NAM_Föreställning_Namn.Metadata_PR_NAM%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn%TYPE,
        b IN attributes.PR_NAM_Föreställning_Namn.PR_NAM_Föreställning_Namn%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value for an entity that already has a value is a contradiction
    FOR r IN (
        SELECT
            x.PR_NAM_Föreställning_Namn
        FROM
            attributes.PR_NAM_Föreställning_Namn x
        WHERE
            x.PR_NAM_PR_ID = p_owner
    ) LOOP
        IF same(r.PR_NAM_Föreställning_Namn, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_NAM_Föreställning_Namn for: ' || p_owner);
    END LOOP;
    INSERT INTO attributes.PR_NAM_Föreställning_Namn (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Föreställning_Namn
    )
    VALUES (
        p_metadata,
        p_owner,
        p_value
    );
END ip_PR_NAM_Föreställning_Namn;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_LEN_Föreställning_Längd states a value of PR_LEN_Föreställning_Längd
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE attributes.ip_PR_LEN_Föreställning_Längd (
    p_owner IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_PR_ID%TYPE,
    p_changing IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_ChangedAt%TYPE,
    p_value IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd%TYPE,
    p_metadata IN attributes.PR_LEN_Föreställning_Längd.Metadata_PR_LEN%TYPE
)
IS
    -- whether two values of the attribute are the same
    FUNCTION same (
        a IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd%TYPE,
        b IN attributes.PR_LEN_Föreställning_Längd.PR_LEN_Föreställning_Längd%TYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        RETURN a = b;
    END same;
BEGIN
    -- the identical is not stored again, another value at the same time is a contradiction
    FOR r IN (
        SELECT
            x.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd x
        WHERE
            x.PR_LEN_PR_ID = p_owner
        AND
            x.PR_LEN_ChangedAt = p_changing
    ) LOOP
        IF same(r.PR_LEN_Föreställning_Längd, p_value) THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_LEN_Föreställning_Längd for: ' || p_owner || ', ' || p_changing);
    END LOOP;
    -- what is the same as the value before it, or as the value after it, is a restatement
    -- (an idempotent attribute does not store it, and removes the one after it that the new value makes a restatement of)
    FOR r IN (
        SELECT
            p.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd p
        WHERE
            p.PR_LEN_PR_ID = p_owner
        AND
            p.PR_LEN_ChangedAt < p_changing
        ORDER BY
            p.PR_LEN_ChangedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Föreställning_Längd, p_value) THEN
            RETURN;
        END IF;
    END LOOP;
    FOR r IN (
        SELECT
            f.PR_LEN_ChangedAt,
            f.PR_LEN_Föreställning_Längd
        FROM
            attributes.PR_LEN_Föreställning_Längd f
        WHERE
            f.PR_LEN_PR_ID = p_owner
        AND
            f.PR_LEN_ChangedAt > p_changing
        ORDER BY
            f.PR_LEN_ChangedAt ASC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        IF same(r.PR_LEN_Föreställning_Längd, p_value) THEN
            DELETE FROM
                attributes.PR_LEN_Föreställning_Längd
            WHERE
                PR_LEN_PR_ID = p_owner
            AND
                PR_LEN_ChangedAt = r.PR_LEN_ChangedAt;
        END IF;
    END LOOP;
    INSERT INTO attributes.PR_LEN_Föreställning_Längd (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Föreställning_Längd
    )
    VALUES (
        p_metadata,
        p_owner,
        p_changing,
        p_value
    );
END ip_PR_LEN_Föreställning_Längd;
/
