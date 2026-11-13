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
CREATE OR REPLACE PROCEDURE ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN AC_partner_AC_with_ONG_currently.AC_ID_partner%TYPE,
    p_AC_with IN AC_partner_AC_with_ONG_currently.AC_ID_with%TYPE,
    p_ONG_currently IN AC_partner_AC_with_ONG_currently.ONG_ID_currently%TYPE,
    p_changing IN AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
BEGIN
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_partner_AC_with_ONG_currently x
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
    INSERT INTO AC_partner_AC_with_ONG_currently (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    VALUES (
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
CREATE OR REPLACE TRIGGER it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.ONG_Ongoing IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.ONG_Ongoing
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
    );
END it_lAC_partner_AC_with_ONG_currently;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_partner_AC_with_ONG_currently
INSTEAD OF UPDATE ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing AC_partner_AC_with_ONG_currently.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_ONG_currently number(3);
BEGIN
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.ONG_Ongoing <> :OLD.ONG_Ongoing
        OR (:NEW.ONG_Ongoing IS NULL AND :OLD.ONG_Ongoing IS NOT NULL)
        OR (:NEW.ONG_Ongoing IS NOT NULL AND :OLD.ONG_Ongoing IS NULL)) THEN
        v_ONG_currently := NULL;
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.ONG_Ongoing
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
        ip_AC_partner_AC_with_ONG_currently(
            p_AC_partner => :NEW.AC_ID_partner,
            p_AC_with => :NEW.AC_ID_with,
            p_ONG_currently => v_ONG_currently,
            p_changing => v_changing
        );
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_partner_AC_with_ONG_currently x
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
CREATE OR REPLACE PROCEDURE ip_AC_subset_PN_of (
    p_AC_subset IN AC_subset_PN_of.AC_ID_subset%TYPE,
    p_PN_of IN AC_subset_PN_of.PN_ID_of%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_subset_PN_of x
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
    INSERT INTO AC_subset_PN_of (
        AC_ID_subset,
        PN_ID_of
    )
    VALUES (
        p_AC_subset,
        p_PN_of
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_subset_PN_of
INSTEAD OF INSERT ON lAC_subset_PN_of
FOR EACH ROW
BEGIN
    ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of
    );
END it_lAC_subset_PN_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_subset_PN_of
INSTEAD OF UPDATE ON lAC_subset_PN_of
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
        ip_AC_subset_PN_of(
            p_AC_subset => :NEW.AC_ID_subset,
            p_PN_of => :NEW.PN_ID_of
        );
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_subset_PN_of
INSTEAD OF DELETE ON lAC_subset_PN_of
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_subset_PN_of x
    WHERE
        x.AC_ID_subset = :OLD.AC_ID_subset
    AND
        x.PN_ID_of = :OLD.PN_ID_of
    ;
END dt_lAC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_wasCast states a row of EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_EV_in_AC_wasCast (
    p_EV_in IN EV_in_AC_wasCast.EV_ID_in%TYPE,
    p_AC_wasCast IN EV_in_AC_wasCast.AC_ID_wasCast%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            EV_in_AC_wasCast x
        WHERE
            x.EV_ID_in = p_EV_in
        AND
            x.AC_ID_wasCast = p_AC_wasCast
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO EV_in_AC_wasCast (
        EV_ID_in,
        AC_ID_wasCast
    )
    VALUES (
        p_EV_in,
        p_AC_wasCast
    );
END ip_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lEV_in_AC_wasCast
INSTEAD OF INSERT ON lEV_in_AC_wasCast
FOR EACH ROW
BEGIN
    ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast
    );
END it_lEV_in_AC_wasCast;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lEV_in_AC_wasCast
INSTEAD OF DELETE ON lEV_in_AC_wasCast
FOR EACH ROW
BEGIN
    DELETE FROM
        EV_in_AC_wasCast x
    WHERE
        x.EV_ID_in = :OLD.EV_ID_in
    AND
        x.AC_ID_wasCast = :OLD.AC_ID_wasCast
    ;
END dt_lEV_in_AC_wasCast;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_part_PR_in_RAT_got states a row of AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_part_PR_in_RAT_got (
    p_AC_part IN AC_part_PR_in_RAT_got.AC_ID_part%TYPE,
    p_PR_in IN AC_part_PR_in_RAT_got.PR_ID_in%TYPE,
    p_RAT_got IN AC_part_PR_in_RAT_got.RAT_ID_got%TYPE,
    p_changing IN AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
BEGIN
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_part_PR_in_RAT_got x
        WHERE
            x.AC_ID_part = p_AC_part
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.RAT_ID_got = p_RAT_got
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_part_PR_in_RAT_got x
        WHERE
            x.AC_ID_part = p_AC_part
        AND
            x.PR_ID_in = p_PR_in
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_part_PR_in_RAT_got for: '
            || p_AC_part
            || ', '
            || p_PR_in
            || ', '
            || v_changing
        );
    END LOOP;
    INSERT INTO AC_part_PR_in_RAT_got (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    VALUES (
        v_changing,
        p_AC_part,
        p_PR_in,
        p_RAT_got
    );
END ip_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_part_PR_in_RAT_got
INSTEAD OF INSERT ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_RAT_got number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF v_RAT_got IS NULL AND :NEW.RAT_Rating IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                RAT_Rating k
            WHERE
                k.RAT_Rating = :NEW.RAT_Rating
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_got := kv.RAT_ID;
        END LOOP;
    END IF;
    ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => v_RAT_got,
        p_changing => :NEW.AC_part_PR_in_RAT_got_ChangedAt
    );
END it_lAC_part_PR_in_RAT_got;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lAC_part_PR_in_RAT_got
INSTEAD OF UPDATE ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changed NUMBER(1);
    v_changing AC_part_PR_in_RAT_got.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
    v_RAT_got number(3);
BEGIN
    IF (:NEW.AC_ID_part <> :OLD.AC_ID_part
        OR (:NEW.AC_ID_part IS NULL AND :OLD.AC_ID_part IS NOT NULL)
        OR (:NEW.AC_ID_part IS NOT NULL AND :OLD.AC_ID_part IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column AC_ID_part is not updatable.');
    END IF;
    IF (:NEW.PR_ID_in <> :OLD.PR_ID_in
        OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
        OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column PR_ID_in is not updatable.');
    END IF;
    -- whether the changing time is given another value (or else it is now)
    v_changed := CASE WHEN (:NEW.AC_part_PR_in_RAT_got_ChangedAt <> :OLD.AC_part_PR_in_RAT_got_ChangedAt
        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL)
        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NULL)) THEN 1 ELSE 0 END;
    v_changing := CASE WHEN v_changed = 1 THEN :NEW.AC_part_PR_in_RAT_got_ChangedAt ELSE v_now END;
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF (:NEW.RAT_Rating <> :OLD.RAT_Rating
        OR (:NEW.RAT_Rating IS NULL AND :OLD.RAT_Rating IS NOT NULL)
        OR (:NEW.RAT_Rating IS NOT NULL AND :OLD.RAT_Rating IS NULL)) THEN
        v_RAT_got := NULL;
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                RAT_Rating k
            WHERE
                k.RAT_Rating = :NEW.RAT_Rating
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_got := kv.RAT_ID;
        END LOOP;
    END IF;
    -- values that are left as they are state nothing
    IF
        v_RAT_got IS NOT NULL
    AND
        (
            v_changed = 1 OR
            (:NEW.AC_ID_part <> :OLD.AC_ID_part
                OR (:NEW.AC_ID_part IS NULL AND :OLD.AC_ID_part IS NOT NULL)
                OR (:NEW.AC_ID_part IS NOT NULL AND :OLD.AC_ID_part IS NULL))
        OR
            (:NEW.PR_ID_in <> :OLD.PR_ID_in
                OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
                OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL))
        OR
            (v_RAT_got <> :OLD.RAT_ID_got
                OR (v_RAT_got IS NULL AND :OLD.RAT_ID_got IS NOT NULL)
                OR (v_RAT_got IS NOT NULL AND :OLD.RAT_ID_got IS NULL))
        )
    THEN
        ip_AC_part_PR_in_RAT_got(
            p_AC_part => :NEW.AC_ID_part,
            p_PR_in => :NEW.PR_ID_in,
            p_RAT_got => v_RAT_got,
            p_changing => v_changing
        );
    END IF;
END ut_lAC_part_PR_in_RAT_got;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_part_PR_in_RAT_got
INSTEAD OF DELETE ON lAC_part_PR_in_RAT_got
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_part_PR_in_RAT_got x
    WHERE
        x.AC_part_PR_in_RAT_got_ChangedAt = :OLD.AC_part_PR_in_RAT_got_ChangedAt
    AND
        x.AC_ID_part = :OLD.AC_ID_part
    AND
        x.PR_ID_in = :OLD.PR_ID_in
    ;
END dt_lAC_part_PR_in_RAT_got;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_isPlaying states a row of ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_ST_at_PR_isPlaying (
    p_ST_at IN ST_at_PR_isPlaying.ST_ID_at%TYPE,
    p_PR_isPlaying IN ST_at_PR_isPlaying.PR_ID_isPlaying%TYPE,
    p_changing IN ST_at_PR_isPlaying.ST_at_PR_isPlaying_ChangedAt%TYPE
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_changing ST_at_PR_isPlaying.ST_at_PR_isPlaying_ChangedAt%TYPE;
BEGIN
    v_changing := COALESCE(p_changing, v_now);
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            ST_at_PR_isPlaying x
        WHERE
            x.ST_ID_at = p_ST_at
        AND
            x.PR_ID_isPlaying = p_PR_isPlaying
        AND
            x.ST_at_PR_isPlaying_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO ST_at_PR_isPlaying (
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    VALUES (
        v_changing,
        p_ST_at,
        p_PR_isPlaying
    );
END ip_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lST_at_PR_isPlaying
INSTEAD OF INSERT ON lST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => :NEW.ST_at_PR_isPlaying_ChangedAt
    );
END it_lST_at_PR_isPlaying;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lST_at_PR_isPlaying
INSTEAD OF DELETE ON lST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    DELETE FROM
        ST_at_PR_isPlaying x
    WHERE
        x.ST_at_PR_isPlaying_ChangedAt = :OLD.ST_at_PR_isPlaying_ChangedAt
    AND
        x.ST_ID_at = :OLD.ST_ID_at
    AND
        x.PR_ID_isPlaying = :OLD.PR_ID_isPlaying
    ;
END dt_lST_at_PR_isPlaying;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_parent_AC_child_PAT_having states a row of AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_AC_parent_AC_child_PAT_having (
    p_AC_parent IN AC_parent_AC_child_PAT_having.AC_ID_parent%TYPE,
    p_AC_child IN AC_parent_AC_child_PAT_having.AC_ID_child%TYPE,
    p_PAT_having IN AC_parent_AC_child_PAT_having.PAT_ID_having%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            AC_parent_AC_child_PAT_having x
        WHERE
            x.AC_ID_parent = p_AC_parent
        AND
            x.AC_ID_child = p_AC_child
        AND
            x.PAT_ID_having = p_PAT_having
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    INSERT INTO AC_parent_AC_child_PAT_having (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    VALUES (
        p_AC_parent,
        p_AC_child,
        p_PAT_having
    );
END ip_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lAC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_PAT_having number(3);
BEGIN
    -- the identity of the knot value of the role, given as it is or looked up from the value
    v_PAT_having := :NEW.PAT_ID_having;
    IF v_PAT_having IS NULL AND :NEW.PAT_ParentalType IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                PAT_ParentalType k
            WHERE
                k.PAT_ParentalType = :NEW.PAT_ParentalType
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_having := kv.PAT_ID;
        END LOOP;
    END IF;
    ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => v_PAT_having
    );
END it_lAC_parent_AC_child_PAT_having;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lAC_parent_AC_child_PAT_having
INSTEAD OF DELETE ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
BEGIN
    DELETE FROM
        AC_parent_AC_child_PAT_having x
    WHERE
        x.AC_ID_parent = :OLD.AC_ID_parent
    AND
        x.AC_ID_child = :OLD.AC_ID_child
    AND
        x.PAT_ID_having = :OLD.PAT_ID_having
    ;
END dt_lAC_parent_AC_child_PAT_having;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_content_ST_location_EV_of states a row of PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ip_PR_content_ST_location_EV_of (
    p_PR_content IN PR_content_ST_location_EV_of.PR_ID_content%TYPE,
    p_ST_location IN PR_content_ST_location_EV_of.ST_ID_location%TYPE,
    p_EV_of IN PR_content_ST_location_EV_of.EV_ID_of%TYPE
)
IS
BEGIN
    -- the identical is not stored again
    FOR r IN (
        SELECT
            1 AS found
        FROM
            PR_content_ST_location_EV_of x
        WHERE
            x.PR_ID_content = p_PR_content
        AND
            x.ST_ID_location = p_ST_location
        AND
            x.EV_ID_of = p_EV_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN;
    END LOOP;
    -- other values for identifiers that already have values (at that time) are a contradiction
    FOR r IN (
        SELECT
            1 AS found
        FROM
            PR_content_ST_location_EV_of x
        WHERE
            x.EV_ID_of = p_EV_of
        AND
            1 = 1
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_content_ST_location_EV_of for: '
            || p_EV_of
        );
    END LOOP;
    INSERT INTO PR_content_ST_location_EV_of (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    VALUES (
        p_PR_content,
        p_ST_location,
        p_EV_of
    );
END ip_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER it_lPR_content_ST_location_EV_of
INSTEAD OF INSERT ON lPR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of
    );
END it_lPR_content_ST_location_EV_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ut_lPR_content_ST_location_EV_of
INSTEAD OF UPDATE ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    IF (:NEW.EV_ID_of <> :OLD.EV_ID_of
        OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
        OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20003, 'The identity column EV_ID_of is not updatable.');
    END IF;
    -- values that are left as they are state nothing
    IF
        :NEW.PR_ID_content IS NOT NULL
    AND
        :NEW.ST_ID_location IS NOT NULL
    AND
        (
            (:NEW.PR_ID_content <> :OLD.PR_ID_content
                OR (:NEW.PR_ID_content IS NULL AND :OLD.PR_ID_content IS NOT NULL)
                OR (:NEW.PR_ID_content IS NOT NULL AND :OLD.PR_ID_content IS NULL))
        OR
            (:NEW.ST_ID_location <> :OLD.ST_ID_location
                OR (:NEW.ST_ID_location IS NULL AND :OLD.ST_ID_location IS NOT NULL)
                OR (:NEW.ST_ID_location IS NOT NULL AND :OLD.ST_ID_location IS NULL))
        OR
            (:NEW.EV_ID_of <> :OLD.EV_ID_of
                OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
                OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL))
        )
    THEN
        ip_PR_content_ST_location_EV_of(
            p_PR_content => :NEW.PR_ID_content,
            p_ST_location => :NEW.ST_ID_location,
            p_EV_of => :NEW.EV_ID_of
        );
    END IF;
END ut_lPR_content_ST_location_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER dt_lPR_content_ST_location_EV_of
INSTEAD OF DELETE ON lPR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    DELETE FROM
        PR_content_ST_location_EV_of x
    WHERE
        x.EV_ID_of = :OLD.EV_ID_of
    ;
END dt_lPR_content_ST_location_EV_of;
/
