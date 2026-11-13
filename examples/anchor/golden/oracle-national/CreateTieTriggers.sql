-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- A tie and its latest view behave like a table that is loaded with plain statements. The rules for a row of a tie (it is
-- stored only when it is not there already, a contradiction is refused and, for an idempotent tie, what only states again
-- what the row before it says is left out) are in an insert procedure for each tie, ip_<tie>. The latest view has
-- three 'instead of' triggers: insert, update, and delete. They propagate such operations to the tie table in a consistent
-- way, the insert and update triggers by calling the insert procedure. Default values are used for some columns if not
-- provided by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures and not in a trigger on the tie table, since Oracle does not let a row trigger read the table
-- it is on (ORA-04091), which these rules do. A load can call the procedure itself:
--
--     BEGIN ip_AC_parent_AC_child(p_AC_parent => 1, p_AC_child => 2); END;
--
-- A row put straight into a tie table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a row of AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN ties.AC_partner_AC_with_ONG_currently.AC_ID_partner%TYPE,
    p_AC_with IN ties.AC_partner_AC_with_ONG_currently.AC_ID_with%TYPE,
    p_ONG_currently IN ties.AC_partner_AC_with_ONG_currently.ONG_ID_currently%TYPE,
    p_changing IN ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE,
    p_metadata IN ties.AC_partner_AC_with_ONG_currently.Metadata_AC_partner_AC_with_ONG_currently%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_metadata ties.AC_partner_AC_with_ONG_currently.Metadata_AC_partner_AC_with_ONG_currently%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_partner_AC_with_ONG_currently x
        WHERE
            x.AC_ID_partner = p_AC_partner
        AND
            x.AC_ID_with = p_AC_with
        AND
            x.ONG_ID_currently = p_ONG_currently
        AND
            x.AC_partner_AC_with_ONG_currently_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_partner_AC_with_ONG_currently (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    VALUES (
        v_metadata,
        v_changing,
        p_AC_partner,
        p_AC_with,
        p_ONG_currently
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.currently_ONG_Pågående IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                knots.ONG_Pågående k
            WHERE
                k.ONG_Pågående = :NEW.currently_ONG_Pågående
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_lAC_partner_AC_with_ONG_currently;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_partner_AC_with_ONG_currently
INSTEAD OF UPDATE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing ties.AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_ONG_currently number(3);
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.currently_ONG_Pågående <> :OLD.currently_ONG_Pågående
        OR (:NEW.currently_ONG_Pågående IS NULL AND :OLD.currently_ONG_Pågående IS NOT NULL)
        OR (:NEW.currently_ONG_Pågående IS NOT NULL AND :OLD.currently_ONG_Pågående IS NULL)) THEN
        v_ONG_currently := NULL;
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                knots.ONG_Pågående k
            WHERE
                k.ONG_Pågående = :NEW.currently_ONG_Pågående
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    -- values that are left as they are state nothing
    IF
        :NEW.AC_ID_partner IS NOT NULL
    AND
        :NEW.AC_ID_with IS NOT NULL
    AND
        v_ONG_currently IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_partner <> :OLD.AC_ID_partner
                OR (:NEW.AC_ID_partner IS NULL AND :OLD.AC_ID_partner IS NOT NULL)
                OR (:NEW.AC_ID_partner IS NOT NULL AND :OLD.AC_ID_partner IS NULL))
        OR
            (:NEW.AC_ID_with <> :OLD.AC_ID_with
                OR (:NEW.AC_ID_with IS NULL AND :OLD.AC_ID_with IS NOT NULL)
                OR (:NEW.AC_ID_with IS NOT NULL AND :OLD.AC_ID_with IS NULL))
        OR
            (v_ONG_currently <> :OLD.ONG_ID_currently
                OR (v_ONG_currently IS NULL AND :OLD.ONG_ID_currently IS NOT NULL)
                OR (v_ONG_currently IS NOT NULL AND :OLD.ONG_ID_currently IS NULL))
        )
    THEN
        ties.ip_AC_partner_AC_with_ONG_currently(
            p_AC_partner => :NEW.AC_ID_partner,
            p_AC_with => :NEW.AC_ID_with,
            p_ONG_currently => v_ONG_currently,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
        );
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_partner_AC_with_ONG_currently x
    WHERE
        x.AC_partner_AC_with_ONG_currently_ChangedAt = :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
    AND
        x.AC_ID_partner = :OLD.AC_ID_partner
    AND
        x.AC_ID_with = :OLD.AC_ID_with
    AND
        x.ONG_ID_currently = :OLD.ONG_ID_currently
    ;
END dt_lAC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a row of AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_subset_PN_of (
    p_AC_subset IN ties.AC_subset_PN_of.AC_ID_subset%TYPE,
    p_PN_of IN ties.AC_subset_PN_of.PN_ID_of%TYPE,
    p_metadata IN ties.AC_subset_PN_of.Metadata_AC_subset_PN_of%TYPE
)
IS
    v_metadata ties.AC_subset_PN_of.Metadata_AC_subset_PN_of%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_subset_PN_of x
        WHERE
            x.AC_ID_subset = p_AC_subset
        AND
            x.PN_ID_of = p_PN_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_subset_PN_of (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of
    )
    VALUES (
        v_metadata,
        p_AC_subset,
        p_PN_of
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_subset_PN_of
INSTEAD OF INSERT ON ties.lAC_subset_PN_of
FOR EACH ROW
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_lAC_subset_PN_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_subset_PN_of
INSTEAD OF UPDATE ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- values that are left as they are state nothing
    IF
        :NEW.AC_ID_subset IS NOT NULL
    AND
        :NEW.PN_ID_of IS NOT NULL
    AND
        (
            (:NEW.AC_ID_subset <> :OLD.AC_ID_subset
                OR (:NEW.AC_ID_subset IS NULL AND :OLD.AC_ID_subset IS NOT NULL)
                OR (:NEW.AC_ID_subset IS NOT NULL AND :OLD.AC_ID_subset IS NULL))
        OR
            (:NEW.PN_ID_of <> :OLD.PN_ID_of
                OR (:NEW.PN_ID_of IS NULL AND :OLD.PN_ID_of IS NOT NULL)
                OR (:NEW.PN_ID_of IS NOT NULL AND :OLD.PN_ID_of IS NULL))
        )
    THEN
        ties.ip_AC_subset_PN_of(
            p_AC_subset => :NEW.AC_ID_subset,
            p_PN_of => :NEW.PN_ID_of,
            p_metadata => :NEW.Metadata_AC_subset_PN_of
        );
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_subset_PN_of
INSTEAD OF DELETE ON ties.lAC_subset_PN_of
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_subset_PN_of x
    WHERE
        x.AC_ID_subset = :OLD.AC_ID_subset
    AND
        x.PN_ID_of = :OLD.PN_ID_of
    ;
END dt_lAC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_rollsattes states a row of EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_rollsattes (
    p_EV_in IN ties.EV_in_AC_rollsattes.EV_ID_in%TYPE,
    p_AC_rollsattes IN ties.EV_in_AC_rollsattes.AC_ID_rollsattes%TYPE,
    p_metadata IN ties.EV_in_AC_rollsattes.Metadata_EV_in_AC_rollsattes%TYPE
)
IS
    v_metadata ties.EV_in_AC_rollsattes.Metadata_EV_in_AC_rollsattes%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.EV_in_AC_rollsattes x
        WHERE
            x.EV_ID_in = p_EV_in
        AND
            x.AC_ID_rollsattes = p_AC_rollsattes
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.EV_in_AC_rollsattes (
        Metadata_EV_in_AC_rollsattes,
        EV_ID_in,
        AC_ID_rollsattes
    )
    VALUES (
        v_metadata,
        p_EV_in,
        p_AC_rollsattes
    );
END ip_EV_in_AC_rollsattes;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_rollsattes
INSTEAD OF INSERT ON ties.lEV_in_AC_rollsattes
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_rollsattes => :NEW.AC_ID_rollsattes,
        p_metadata => :NEW.Metadata_EV_in_AC_rollsattes
    );
END it_lEV_in_AC_rollsattes;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_rollsattes instead of DELETE trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lEV_in_AC_rollsattes
INSTEAD OF DELETE ON ties.lEV_in_AC_rollsattes
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.EV_in_AC_rollsattes x
    WHERE
        x.EV_ID_in = :OLD.EV_ID_in
    AND
        x.AC_ID_rollsattes = :OLD.AC_ID_rollsattes
    ;
END dt_lEV_in_AC_rollsattes;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_deltar_PR_in_RAT_fick states a row of AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_deltar_PR_in_RAT_fick (
    p_AC_deltar IN ties.AC_deltar_PR_in_RAT_fick.AC_ID_deltar%TYPE,
    p_PR_in IN ties.AC_deltar_PR_in_RAT_fick.PR_ID_in%TYPE,
    p_RAT_fick IN ties.AC_deltar_PR_in_RAT_fick.RAT_ID_fick%TYPE,
    p_changing IN ties.AC_deltar_PR_in_RAT_fick.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE,
    p_metadata IN ties.AC_deltar_PR_in_RAT_fick.Metadata_AC_deltar_PR_in_RAT_fick%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.AC_deltar_PR_in_RAT_fick.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE;
    v_metadata ties.AC_deltar_PR_in_RAT_fick.Metadata_AC_deltar_PR_in_RAT_fick%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_deltar_PR_in_RAT_fick x
        WHERE
            x.AC_ID_deltar = p_AC_deltar
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.RAT_ID_fick = p_RAT_fick
        AND
            x.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_deltar_PR_in_RAT_fick x
        WHERE
            x.AC_ID_deltar = p_AC_deltar
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_deltar_PR_in_RAT_fick for: '
            || p_AC_deltar
            || ', '
            || p_PR_in
            || ', '
            || v_changing
        );
    END LOOP;
    INSERT INTO ties.AC_deltar_PR_in_RAT_fick (
        Metadata_AC_deltar_PR_in_RAT_fick,
        AC_deltar_PR_in_RAT_fick_ChangedAt,
        AC_ID_deltar,
        PR_ID_in,
        RAT_ID_fick
    )
    VALUES (
        v_metadata,
        v_changing,
        p_AC_deltar,
        p_PR_in,
        p_RAT_fick
    );
END ip_AC_deltar_PR_in_RAT_fick;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_deltar_PR_in_RAT_fick
INSTEAD OF INSERT ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_RAT_fick number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_fick := :NEW.RAT_ID_fick;
    IF v_RAT_fick IS NULL AND :NEW.fick_RAT_Betyg IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                knots.RAT_Betyg k
            WHERE
                k.RAT_Checksum = STANDARD_HASH(:NEW.fick_RAT_Betyg, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_fick := kv.RAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_deltar_PR_in_RAT_fick(
        p_AC_deltar => :NEW.AC_ID_deltar,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_fick => v_RAT_fick,
        p_changing => :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt,
        p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
    );
END it_lAC_deltar_PR_in_RAT_fick;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_deltar_PR_in_RAT_fick instead of UPDATE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_deltar_PR_in_RAT_fick
INSTEAD OF UPDATE ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing ties.AC_deltar_PR_in_RAT_fick.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE;
    v_RAT_fick number(3);
BEGIN
    IF (:NEW.AC_ID_deltar <> :OLD.AC_ID_deltar
        OR (:NEW.AC_ID_deltar IS NULL AND :OLD.AC_ID_deltar IS NOT NULL)
        OR (:NEW.AC_ID_deltar IS NOT NULL AND :OLD.AC_ID_deltar IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID_deltar is not updatable.');
    END IF;
    IF (:NEW.PR_ID_in <> :OLD.PR_ID_in
        OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
        OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID_in is not updatable.');
    END IF;
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt <> :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL)
        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_fick := :NEW.RAT_ID_fick;
    IF (:NEW.fick_RAT_Betyg <> :OLD.fick_RAT_Betyg
        OR (:NEW.fick_RAT_Betyg IS NULL AND :OLD.fick_RAT_Betyg IS NOT NULL)
        OR (:NEW.fick_RAT_Betyg IS NOT NULL AND :OLD.fick_RAT_Betyg IS NULL)) THEN
        v_RAT_fick := NULL;
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                knots.RAT_Betyg k
            WHERE
                k.RAT_Checksum = STANDARD_HASH(:NEW.fick_RAT_Betyg, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_fick := kv.RAT_ID;
        END LOOP;
    END IF;
    -- values that are left as they are state nothing
    IF
        v_RAT_fick IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_deltar <> :OLD.AC_ID_deltar
                OR (:NEW.AC_ID_deltar IS NULL AND :OLD.AC_ID_deltar IS NOT NULL)
                OR (:NEW.AC_ID_deltar IS NOT NULL AND :OLD.AC_ID_deltar IS NULL))
        OR
            (:NEW.PR_ID_in <> :OLD.PR_ID_in
                OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
                OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL))
        OR
            (v_RAT_fick <> :OLD.RAT_ID_fick
                OR (v_RAT_fick IS NULL AND :OLD.RAT_ID_fick IS NOT NULL)
                OR (v_RAT_fick IS NOT NULL AND :OLD.RAT_ID_fick IS NULL))
        )
    THEN
        ties.ip_AC_deltar_PR_in_RAT_fick(
            p_AC_deltar => :NEW.AC_ID_deltar,
            p_PR_in => :NEW.PR_ID_in,
            p_RAT_fick => v_RAT_fick,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
        );
    END IF;
END ut_lAC_deltar_PR_in_RAT_fick;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_deltar_PR_in_RAT_fick
INSTEAD OF DELETE ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_deltar_PR_in_RAT_fick x
    WHERE
        x.AC_deltar_PR_in_RAT_fick_ChangedAt = :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
    AND
        x.AC_ID_deltar = :OLD.AC_ID_deltar
    AND
        x.PR_ID_in = :OLD.PR_ID_in
    ;
END dt_lAC_deltar_PR_in_RAT_fick;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_spelas states a row of ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_spelas (
    p_ST_at IN ties.ST_at_PR_spelas.ST_ID_at%TYPE,
    p_PR_spelas IN ties.ST_at_PR_spelas.PR_ID_spelas%TYPE,
    p_changing IN ties.ST_at_PR_spelas.ST_at_PR_spelas_ChangedAt%TYPE,
    p_metadata IN ties.ST_at_PR_spelas.Metadata_ST_at_PR_spelas%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.ST_at_PR_spelas.ST_at_PR_spelas_ChangedAt%TYPE;
    v_metadata ties.ST_at_PR_spelas.Metadata_ST_at_PR_spelas%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.ST_at_PR_spelas x
        WHERE
            x.ST_ID_at = p_ST_at
        AND
            x.PR_ID_spelas = p_PR_spelas
        AND
            x.ST_at_PR_spelas_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.ST_at_PR_spelas (
        Metadata_ST_at_PR_spelas,
        ST_at_PR_spelas_ChangedAt,
        ST_ID_at,
        PR_ID_spelas
    )
    VALUES (
        v_metadata,
        v_changing,
        p_ST_at,
        p_PR_spelas
    );
END ip_ST_at_PR_spelas;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_spelas
INSTEAD OF INSERT ON ties.lST_at_PR_spelas
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_spelas => :NEW.PR_ID_spelas,
        p_changing => :NEW.ST_at_PR_spelas_ChangedAt,
        p_metadata => :NEW.Metadata_ST_at_PR_spelas
    );
END it_lST_at_PR_spelas;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_spelas instead of DELETE trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lST_at_PR_spelas
INSTEAD OF DELETE ON ties.lST_at_PR_spelas
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.ST_at_PR_spelas x
    WHERE
        x.ST_at_PR_spelas_ChangedAt = :OLD.ST_at_PR_spelas_ChangedAt
    AND
        x.ST_ID_at = :OLD.ST_ID_at
    AND
        x.PR_ID_spelas = :OLD.PR_ID_spelas
    ;
END dt_lST_at_PR_spelas;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_förälder_AC_barn_PAT_har states a row of AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_förälder_AC_barn_PAT_har (
    p_AC_förälder IN ties.AC_förälder_AC_barn_PAT_har.AC_ID_förälder%TYPE,
    p_AC_barn IN ties.AC_förälder_AC_barn_PAT_har.AC_ID_barn%TYPE,
    p_PAT_har IN ties.AC_förälder_AC_barn_PAT_har.PAT_ID_har%TYPE,
    p_metadata IN ties.AC_förälder_AC_barn_PAT_har.Metadata_AC_förälder_AC_barn_PAT_har%TYPE
)
IS
    v_metadata ties.AC_förälder_AC_barn_PAT_har.Metadata_AC_förälder_AC_barn_PAT_har%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.AC_förälder_AC_barn_PAT_har x
        WHERE
            x.AC_ID_förälder = p_AC_förälder
        AND
            x.AC_ID_barn = p_AC_barn
        AND
            x.PAT_ID_har = p_PAT_har
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.AC_förälder_AC_barn_PAT_har (
        Metadata_AC_förälder_AC_barn_PAT_har,
        AC_ID_förälder,
        AC_ID_barn,
        PAT_ID_har
    )
    VALUES (
        v_metadata,
        p_AC_förälder,
        p_AC_barn,
        p_PAT_har
    );
END ip_AC_förälder_AC_barn_PAT_har;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_förälder_AC_barn_PAT_har
INSTEAD OF INSERT ON ties.lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
DECLARE
    v_PAT_har number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_PAT_har := :NEW.PAT_ID_har;
    IF v_PAT_har IS NULL AND :NEW.har_PAT_Föräldratyp IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                knots.PAT_Föräldratyp k
            WHERE
                k.PAT_Föräldratyp = :NEW.har_PAT_Föräldratyp
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_har := kv.PAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_förälder_AC_barn_PAT_har(
        p_AC_förälder => :NEW.AC_ID_förälder,
        p_AC_barn => :NEW.AC_ID_barn,
        p_PAT_har => v_PAT_har,
        p_metadata => :NEW.Metadata_AC_förälder_AC_barn_PAT_har
    );
END it_lAC_förälder_AC_barn_PAT_har;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_förälder_AC_barn_PAT_har instead of DELETE trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_förälder_AC_barn_PAT_har
INSTEAD OF DELETE ON ties.lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.AC_förälder_AC_barn_PAT_har x
    WHERE
        x.AC_ID_förälder = :OLD.AC_ID_förälder
    AND
        x.AC_ID_barn = :OLD.AC_ID_barn
    AND
        x.PAT_ID_har = :OLD.PAT_ID_har
    ;
END dt_lAC_förälder_AC_barn_PAT_har;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_innehåll_ST_plats_EV_of states a row of PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_innehåll_ST_plats_EV_of (
    p_PR_innehåll IN ties.PR_innehåll_ST_plats_EV_of.PR_ID_innehåll%TYPE,
    p_ST_plats IN ties.PR_innehåll_ST_plats_EV_of.ST_ID_plats%TYPE,
    p_EV_of IN ties.PR_innehåll_ST_plats_EV_of.EV_ID_of%TYPE,
    p_changing IN ties.PR_innehåll_ST_plats_EV_of.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE,
    p_metadata IN ties.PR_innehåll_ST_plats_EV_of.Metadata_PR_innehåll_ST_plats_EV_of%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ties.PR_innehåll_ST_plats_EV_of.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE;
    v_metadata ties.PR_innehåll_ST_plats_EV_of.Metadata_PR_innehåll_ST_plats_EV_of%TYPE;
BEGIN
    v_metadata := COALESCE(p_metadata, 0);
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ties.PR_innehåll_ST_plats_EV_of x
        WHERE
            x.PR_ID_innehåll = p_PR_innehåll
        AND
            x.ST_ID_plats = p_ST_plats
        AND
            x.EV_ID_of = p_EV_of
        AND
            x.PR_innehåll_ST_plats_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ties.PR_innehåll_ST_plats_EV_of (
        Metadata_PR_innehåll_ST_plats_EV_of,
        PR_innehåll_ST_plats_EV_of_ChangedAt,
        PR_ID_innehåll,
        ST_ID_plats,
        EV_ID_of
    )
    VALUES (
        v_metadata,
        v_changing,
        p_PR_innehåll,
        p_ST_plats,
        p_EV_of
    );
END ip_PR_innehåll_ST_plats_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_innehåll_ST_plats_EV_of
INSTEAD OF INSERT ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :NEW.PR_ID_innehåll,
        p_ST_plats => :NEW.ST_ID_plats,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt,
        p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
    );
END it_lPR_innehåll_ST_plats_EV_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_innehåll_ST_plats_EV_of instead of UPDATE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lPR_innehåll_ST_plats_EV_of
INSTEAD OF UPDATE ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing ties.PR_innehåll_ST_plats_EV_of.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE;
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt <> :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL)
        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt ELSE v_now END;
    -- values that are left as they are state nothing
    IF
        :NEW.PR_ID_innehåll IS NOT NULL
    AND
        :NEW.ST_ID_plats IS NOT NULL
    AND
        :NEW.EV_ID_of IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.PR_ID_innehåll <> :OLD.PR_ID_innehåll
                OR (:NEW.PR_ID_innehåll IS NULL AND :OLD.PR_ID_innehåll IS NOT NULL)
                OR (:NEW.PR_ID_innehåll IS NOT NULL AND :OLD.PR_ID_innehåll IS NULL))
        OR
            (:NEW.ST_ID_plats <> :OLD.ST_ID_plats
                OR (:NEW.ST_ID_plats IS NULL AND :OLD.ST_ID_plats IS NOT NULL)
                OR (:NEW.ST_ID_plats IS NOT NULL AND :OLD.ST_ID_plats IS NULL))
        OR
            (:NEW.EV_ID_of <> :OLD.EV_ID_of
                OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
                OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL))
        )
    THEN
        ties.ip_PR_innehåll_ST_plats_EV_of(
            p_PR_innehåll => :NEW.PR_ID_innehåll,
            p_ST_plats => :NEW.ST_ID_plats,
            p_EV_of => :NEW.EV_ID_of,
            p_changing => v_changing,
            p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
        );
    END IF;
END ut_lPR_innehåll_ST_plats_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_innehåll_ST_plats_EV_of
INSTEAD OF DELETE ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
BEGIN
    DELETE FROM
        ties.PR_innehåll_ST_plats_EV_of x
    WHERE
        x.PR_innehåll_ST_plats_EV_of_ChangedAt = :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
    AND
        x.PR_ID_innehåll = :OLD.PR_ID_innehåll
    AND
        x.ST_ID_plats = :OLD.ST_ID_plats
    AND
        x.EV_ID_of = :OLD.EV_ID_of
    ;
END dt_lPR_innehåll_ST_plats_EV_of;
/
