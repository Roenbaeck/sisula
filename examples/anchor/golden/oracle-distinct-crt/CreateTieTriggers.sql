-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the positor is 0, the changing and
-- positing times are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is about the values of the identifiers (at a changing time):
-- a decisive positor holds one assertion at a time for them, so an assertion of other values retracts, at its own positing
-- time, the posit that the positor holds, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- The rules are in procedures, ip_<tie>, and not in triggers on the posit and annex tables, since Oracle does not let a
-- row trigger read the table it is on (ORA-04091), which these rules do. The triggers on the views call them, and so can
-- a load, with the roles and what else is to be stated (what is left out gets its default: the positor is 0, the changing
-- and positing times are now, the reliability is 1):
--
--     BEGIN
--         ip_<tie>(
--             p_<role> => ...,                  one for each role, the identity of the entity or knot
--             p_changing => ...,                a historized tie
--             p_positor => ..., p_positing => ..., p_reliability => ...,
--             p_metadata => ...                 when the model has metadata
--         );
--     END;
--
-- A row put straight into a posit or annex table by an INSERT is not looked at.
--
-- Oracle runs a trigger of this kind for each row, so the rows of an insert are taken in the order they have. Whether a
-- column is set in an UPDATE is told from whether it has another value than the row had.
--
-- Two values are different when one is not null and the other is, or when they are not equal; PL/SQL has no IS DISTINCT FROM.
--
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_partner_AC_with_ONG_currently is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_partner_AC_with_ONG_currently (
    p_id IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_partner_AC_with_ONG_currently_Reliability
        FROM
            ties.AC_partner_AC_with_ONG_currently_Annex a
        WHERE
            a.AC_partner_AC_with_ONG_currently_ID = p_id
        AND
            a.AC_partner_AC_with_ONG_currently_Positor = p_positor
        AND
            a.AC_partner_AC_with_ONG_currently_PositedAt <= p_positing
        ORDER BY
            a.AC_partner_AC_with_ONG_currently_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_partner_AC_with_ONG_currently_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_partner_AC_with_ONG_currently;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_partner_AC_with_ONG_currently tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_partner_AC_with_ONG_currently (
    p_id IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_partner_AC_with_ONG_currently(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_partner_AC_with_ONG_currently;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_partner_AC_with_ONG_currently states a posit of AC_partner_AC_with_ONG_currently, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_partner_AC_with_ONG_currently (
    p_AC_partner IN ties.AC_partner_AC_with_ONG_currently_Posit.AC_ID_partner%TYPE,
    p_AC_with IN ties.AC_partner_AC_with_ONG_currently_Posit.AC_ID_with%TYPE,
    p_ONG_currently IN ties.AC_partner_AC_with_ONG_currently_Posit.ONG_ID_currently%TYPE,
    p_changing IN ties.AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_partner_AC_with_ONG_currently_Annex.Metadata_AC_partner_AC_with_ONG_currently%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Positor%TYPE;
    v_positing ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_PositedAt%TYPE;
    v_reliability ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE;
    v_held ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_Reliability%TYPE;
    v_changing ties.AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ChangedAt%TYPE;
    v_posit ties.AC_partner_AC_with_ONG_currently_Posit.AC_partner_AC_with_ONG_currently_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_partner_AC_with_ONG_currently_Annex.AC_partner_AC_with_ONG_currently_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Annex (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = p_id
                AND
                    a.AC_partner_AC_with_ONG_currently_Positor = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_partner_AC_with_ONG_currently_ID
        FROM
            ties.AC_partner_AC_with_ONG_currently_Posit p
        WHERE
            p.AC_ID_partner = p_AC_partner
        AND
            p.AC_ID_with = p_AC_with
        AND
            p.ONG_ID_currently = p_ONG_currently
        AND
            p.AC_partner_AC_with_ONG_currently_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_partner_AC_with_ONG_currently_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_Positor = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
                AND
                    a.AC_partner_AC_with_ONG_currently_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_partner_AC_with_ONG_currently for: ' ||
                p_AC_partner || ', ' ||
                p_AC_with || ', ' ||
                p_ONG_currently || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_partner_AC_with_ONG_currently_Annex a
                WHERE
                    a.AC_partner_AC_with_ONG_currently_ID = v_posit
                AND
                    a.AC_partner_AC_with_ONG_currently_Positor = v_positor
                AND
                    a.AC_partner_AC_with_ONG_currently_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_partner_AC_with_ONG_currently(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Annex (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_partner_AC_with_ONG_currently_Posit (
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        )
        VALUES (
            p_AC_partner,
            p_AC_with,
            p_ONG_currently,
            v_changing
        )
        RETURNING AC_partner_AC_with_ONG_currently_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_partner_AC_with_ONG_currently_Annex (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.AC_partner_AC_with_ONG_currently
FOR EACH ROW
BEGIN
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => :NEW.ONG_ID_currently,
        p_changing => :NEW.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positor => :NEW.AC_partner_AC_with_ONG_currently_Positor,
        p_positing => :NEW.AC_partner_AC_with_ONG_currently_PositedAt,
        p_reliability => :NEW.AC_partner_AC_with_ONG_currently_Reliability,
        p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
    );
END it_AC_partner_AC_with_ONG_currently;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_partner_AC_with_ONG_currently
INSTEAD OF INSERT ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF v_ONG_currently IS NULL AND :NEW.currently_ONG_Ongoing IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.ONG_ID
            FROM
                knots.ONG_Ongoing k
            WHERE
                k.ONG_Ongoing = :NEW.currently_ONG_Ongoing
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_ONG_currently := kv.ONG_ID;
        END LOOP;
    END IF;
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :NEW.AC_ID_partner,
        p_AC_with => :NEW.AC_ID_with,
        p_ONG_currently => v_ONG_currently,
        p_changing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
    v_ONG_currently number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_ONG_currently := :NEW.ONG_ID_currently;
    IF (:NEW.currently_ONG_Ongoing <> :OLD.currently_ONG_Ongoing
        OR (:NEW.currently_ONG_Ongoing IS NULL AND :OLD.currently_ONG_Ongoing IS NOT NULL)
        OR (:NEW.currently_ONG_Ongoing IS NOT NULL AND :OLD.currently_ONG_Ongoing IS NULL))
    AND (:NEW.ONG_ID_currently = :OLD.ONG_ID_currently
        OR (:NEW.ONG_ID_currently IS NULL AND :OLD.ONG_ID_currently IS NULL)) THEN
        v_ONG_currently := NULL;
        IF :NEW.currently_ONG_Ongoing IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.ONG_ID
                FROM
                    knots.ONG_Ongoing k
                WHERE
                    k.ONG_Ongoing = :NEW.currently_ONG_Ongoing
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_ONG_currently := kv.ONG_ID;
            END LOOP;
        END IF;
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_partner_AC_with_ONG_currently_Positor <> :OLD.AC_partner_AC_with_ONG_currently_Positor
            OR (:NEW.AC_partner_AC_with_ONG_currently_Positor IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Positor IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Positor IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Positor IS NULL))
        THEN :NEW.AC_partner_AC_with_ONG_currently_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_partner_AC_with_ONG_currently_PositedAt <> :OLD.AC_partner_AC_with_ONG_currently_PositedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NULL))
        THEN :NEW.AC_partner_AC_with_ONG_currently_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_partner <> :OLD.AC_ID_partner
            OR (:NEW.AC_ID_partner IS NULL AND :OLD.AC_ID_partner IS NOT NULL)
            OR (:NEW.AC_ID_partner IS NOT NULL AND :OLD.AC_ID_partner IS NULL)) OR
        (:NEW.AC_ID_with <> :OLD.AC_ID_with
            OR (:NEW.AC_ID_with IS NULL AND :OLD.AC_ID_with IS NOT NULL)
            OR (:NEW.AC_ID_with IS NOT NULL AND :OLD.AC_ID_with IS NULL)) OR
        (v_ONG_currently <> :OLD.ONG_ID_currently
            OR (v_ONG_currently IS NULL AND :OLD.ONG_ID_currently IS NOT NULL)
            OR (v_ONG_currently IS NOT NULL AND :OLD.ONG_ID_currently IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_PositedAt <> :OLD.AC_partner_AC_with_ONG_currently_PositedAt
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_PositedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_PositedAt IS NULL)) OR
        (:NEW.AC_partner_AC_with_ONG_currently_Reliability <> :OLD.AC_partner_AC_with_ONG_currently_Reliability
            OR (:NEW.AC_partner_AC_with_ONG_currently_Reliability IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_Reliability IS NOT NULL)
            OR (:NEW.AC_partner_AC_with_ONG_currently_Reliability IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_partner IS NOT NULL
        AND
            :NEW.AC_ID_with IS NOT NULL
        AND
            v_ONG_currently IS NOT NULL
        THEN
            ties.ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :NEW.AC_ID_partner,
                p_AC_with => :NEW.AC_ID_with,
                p_ONG_currently => v_ONG_currently,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt <> :OLD.AC_partner_AC_with_ONG_currently_ChangedAt
                        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_partner_AC_with_ONG_currently_ChangedAt IS NOT NULL AND :OLD.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL))
                    THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
                    WHEN
                        :NEW.AC_ID_partner = :OLD.AC_ID_partner
                    AND
                        :NEW.AC_ID_with = :OLD.AC_ID_with
                    AND
                        v_ONG_currently = :OLD.ONG_ID_currently
                    THEN :NEW.AC_partner_AC_with_ONG_currently_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_partner_AC_with_ONG_currently_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_partner_AC_with_ONG_currently(
                p_AC_partner => :OLD.AC_ID_partner,
                p_AC_with => :OLD.AC_ID_with,
                p_ONG_currently => :OLD.ONG_ID_currently,
                p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_partner_AC_with_ONG_currently
            );
        END IF;
    END IF;
END ut_lAC_partner_AC_with_ONG_currently;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_partner_AC_with_ONG_currently
INSTEAD OF DELETE ON ties.lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_partner_AC_with_ONG_currently(
        p_AC_partner => :OLD.AC_ID_partner,
        p_AC_with => :OLD.AC_ID_with,
        p_ONG_currently => :OLD.ONG_ID_currently,
        p_changing => :OLD.AC_partner_AC_with_ONG_currently_ChangedAt,
        p_positor => COALESCE(:OLD.AC_partner_AC_with_ONG_currently_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_partner_AC_with_ONG_currently
    );
END dt_lAC_partner_AC_with_ONG_currently;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_subset_PN_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_subset_PN_of (
    p_id IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE,
    p_positor IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE,
    p_positing IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE
) RETURN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_subset_PN_of_Reliability
        FROM
            ties.AC_subset_PN_of_Annex a
        WHERE
            a.AC_subset_PN_of_ID = p_id
        AND
            a.AC_subset_PN_of_Positor = p_positor
        AND
            a.AC_subset_PN_of_PositedAt <= p_positing
        ORDER BY
            a.AC_subset_PN_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_subset_PN_of_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_subset_PN_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_subset_PN_of (
    p_id IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE,
    p_positor IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE,
    p_positing IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_subset_PN_of(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_subset_PN_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_subset_PN_of states a posit of AC_subset_PN_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_subset_PN_of (
    p_AC_subset IN ties.AC_subset_PN_of_Posit.AC_ID_subset%TYPE,
    p_PN_of IN ties.AC_subset_PN_of_Posit.PN_ID_of%TYPE,
    p_positor IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_subset_PN_of_Annex.Metadata_AC_subset_PN_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Positor%TYPE;
    v_positing ties.AC_subset_PN_of_Annex.AC_subset_PN_of_PositedAt%TYPE;
    v_reliability ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE;
    v_held ties.AC_subset_PN_of_Annex.AC_subset_PN_of_Reliability%TYPE;
    v_posit ties.AC_subset_PN_of_Posit.AC_subset_PN_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_subset_PN_of_Annex.AC_subset_PN_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_subset_PN_of_Annex (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = p_id
                AND
                    a.AC_subset_PN_of_Positor = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_subset_PN_of_ID
        FROM
            ties.AC_subset_PN_of_Posit p
        WHERE
            p.AC_ID_subset = p_AC_subset
        AND
            p.PN_ID_of = p_PN_of
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_subset_PN_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_Positor = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
                AND
                    a.AC_subset_PN_of_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_subset_PN_of for: ' ||
                p_AC_subset || ', ' ||
                p_PN_of || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_subset_PN_of_Annex a
                WHERE
                    a.AC_subset_PN_of_ID = v_posit
                AND
                    a.AC_subset_PN_of_Positor = v_positor
                AND
                    a.AC_subset_PN_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_subset_PN_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_subset_PN_of_Annex (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_subset_PN_of_Posit (
            AC_ID_subset,
            PN_ID_of
        )
        VALUES (
            p_AC_subset,
            p_PN_of
        )
        RETURNING AC_subset_PN_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_subset_PN_of_Annex (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_subset_PN_of
INSTEAD OF INSERT ON ties.AC_subset_PN_of
FOR EACH ROW
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positor => :NEW.AC_subset_PN_of_Positor,
        p_positing => :NEW.AC_subset_PN_of_PositedAt,
        p_reliability => :NEW.AC_subset_PN_of_Reliability,
        p_metadata => :NEW.Metadata_AC_subset_PN_of
    );
END it_AC_subset_PN_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_subset_PN_of
INSTEAD OF INSERT ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :NEW.AC_ID_subset,
        p_PN_of => :NEW.PN_ID_of,
        p_positor => COALESCE(:NEW.AC_subset_PN_of_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_subset_PN_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_subset_PN_of_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_subset_PN_of_Positor <> :OLD.AC_subset_PN_of_Positor
            OR (:NEW.AC_subset_PN_of_Positor IS NULL AND :OLD.AC_subset_PN_of_Positor IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Positor IS NOT NULL AND :OLD.AC_subset_PN_of_Positor IS NULL))
        THEN :NEW.AC_subset_PN_of_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_subset_PN_of_PositedAt <> :OLD.AC_subset_PN_of_PositedAt
            OR (:NEW.AC_subset_PN_of_PositedAt IS NULL AND :OLD.AC_subset_PN_of_PositedAt IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_PositedAt IS NOT NULL AND :OLD.AC_subset_PN_of_PositedAt IS NULL))
        THEN :NEW.AC_subset_PN_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_subset <> :OLD.AC_ID_subset
            OR (:NEW.AC_ID_subset IS NULL AND :OLD.AC_ID_subset IS NOT NULL)
            OR (:NEW.AC_ID_subset IS NOT NULL AND :OLD.AC_ID_subset IS NULL)) OR
        (:NEW.PN_ID_of <> :OLD.PN_ID_of
            OR (:NEW.PN_ID_of IS NULL AND :OLD.PN_ID_of IS NOT NULL)
            OR (:NEW.PN_ID_of IS NOT NULL AND :OLD.PN_ID_of IS NULL)) OR
        (:NEW.AC_subset_PN_of_PositedAt <> :OLD.AC_subset_PN_of_PositedAt
            OR (:NEW.AC_subset_PN_of_PositedAt IS NULL AND :OLD.AC_subset_PN_of_PositedAt IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_PositedAt IS NOT NULL AND :OLD.AC_subset_PN_of_PositedAt IS NULL)) OR
        (:NEW.AC_subset_PN_of_Reliability <> :OLD.AC_subset_PN_of_Reliability
            OR (:NEW.AC_subset_PN_of_Reliability IS NULL AND :OLD.AC_subset_PN_of_Reliability IS NOT NULL)
            OR (:NEW.AC_subset_PN_of_Reliability IS NOT NULL AND :OLD.AC_subset_PN_of_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_subset IS NOT NULL
        AND
            :NEW.PN_ID_of IS NOT NULL
        THEN
            ties.ip_AC_subset_PN_of(
                p_AC_subset => :NEW.AC_ID_subset,
                p_PN_of => :NEW.PN_ID_of,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_subset_PN_of_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_subset_PN_of(
                p_AC_subset => :OLD.AC_ID_subset,
                p_PN_of => :OLD.PN_ID_of,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_subset_PN_of
            );
        END IF;
    END IF;
END ut_lAC_subset_PN_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_subset_PN_of
INSTEAD OF DELETE ON ties.lAC_subset_PN_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_subset_PN_of(
        p_AC_subset => :OLD.AC_ID_subset,
        p_PN_of => :OLD.PN_ID_of,
        p_positor => COALESCE(:OLD.AC_subset_PN_of_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_subset_PN_of
    );
END dt_lAC_subset_PN_of;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_EV_in_AC_wasCast is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_EV_in_AC_wasCast (
    p_id IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_ID%TYPE,
    p_positor IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Positor%TYPE,
    p_positing IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE
) RETURN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_in_AC_wasCast_Reliability
        FROM
            ties.EV_in_AC_wasCast_Annex a
        WHERE
            a.EV_in_AC_wasCast_ID = p_id
        AND
            a.EV_in_AC_wasCast_Positor = p_positor
        AND
            a.EV_in_AC_wasCast_PositedAt <= p_positing
        ORDER BY
            a.EV_in_AC_wasCast_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_in_AC_wasCast_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_in_AC_wasCast;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_wasCast tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_EV_in_AC_wasCast (
    p_id IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_ID%TYPE,
    p_positor IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Positor%TYPE,
    p_positing IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_EV_in_AC_wasCast(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_EV_in_AC_wasCast;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_wasCast states a posit of EV_in_AC_wasCast, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_wasCast (
    p_EV_in IN ties.EV_in_AC_wasCast_Posit.EV_ID_in%TYPE,
    p_AC_wasCast IN ties.EV_in_AC_wasCast_Posit.AC_ID_wasCast%TYPE,
    p_positor IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.EV_in_AC_wasCast_Annex.Metadata_EV_in_AC_wasCast%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Positor%TYPE;
    v_positing ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_PositedAt%TYPE;
    v_reliability ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Reliability%TYPE;
    v_held ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_Reliability%TYPE;
    v_posit ties.EV_in_AC_wasCast_Posit.EV_in_AC_wasCast_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.EV_in_AC_wasCast_Annex.EV_in_AC_wasCast_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.EV_in_AC_wasCast_Annex (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_Positor,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_wasCast_Annex a
                WHERE
                    a.EV_in_AC_wasCast_ID = p_id
                AND
                    a.EV_in_AC_wasCast_Positor = v_positor
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.EV_in_AC_wasCast_ID
        FROM
            ties.EV_in_AC_wasCast_Posit p
        WHERE
            p.EV_ID_in = p_EV_in
        AND
            p.AC_ID_wasCast = p_AC_wasCast
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_in_AC_wasCast_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_wasCast_Annex a
                WHERE
                    a.EV_in_AC_wasCast_ID = v_posit
                AND
                    a.EV_in_AC_wasCast_Positor = v_positor
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
                AND
                    a.EV_in_AC_wasCast_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_in_AC_wasCast for: ' ||
                p_EV_in || ', ' ||
                p_AC_wasCast || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_wasCast_Annex a
                WHERE
                    a.EV_in_AC_wasCast_ID = v_posit
                AND
                    a.EV_in_AC_wasCast_Positor = v_positor
                AND
                    a.EV_in_AC_wasCast_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_EV_in_AC_wasCast(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.EV_in_AC_wasCast_Annex (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_Positor,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.EV_in_AC_wasCast_Posit (
            EV_ID_in,
            AC_ID_wasCast
        )
        VALUES (
            p_EV_in,
            p_AC_wasCast
        )
        RETURNING EV_in_AC_wasCast_ID INTO v_posit;
    END IF;
    INSERT INTO ties.EV_in_AC_wasCast_Annex (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_EV_in_AC_wasCast
INSTEAD OF INSERT ON ties.EV_in_AC_wasCast
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
        p_positor => :NEW.EV_in_AC_wasCast_Positor,
        p_positing => :NEW.EV_in_AC_wasCast_PositedAt,
        p_reliability => :NEW.EV_in_AC_wasCast_Reliability,
        p_metadata => :NEW.Metadata_EV_in_AC_wasCast
    );
END it_EV_in_AC_wasCast;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_wasCast
INSTEAD OF INSERT ON ties.lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_wasCast => :NEW.AC_ID_wasCast,
        p_positor => COALESCE(:NEW.EV_in_AC_wasCast_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.EV_in_AC_wasCast_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.EV_in_AC_wasCast_Reliability, 1),
        p_metadata => :NEW.Metadata_EV_in_AC_wasCast
    );
END it_lEV_in_AC_wasCast;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lEV_in_AC_wasCast
INSTEAD OF DELETE ON ties.lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_EV_in_AC_wasCast(
        p_EV_in => :OLD.EV_ID_in,
        p_AC_wasCast => :OLD.AC_ID_wasCast,
        p_positor => COALESCE(:OLD.EV_in_AC_wasCast_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_EV_in_AC_wasCast
    );
END dt_lEV_in_AC_wasCast;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_part_PR_in_RAT_got is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_part_PR_in_RAT_got (
    p_id IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_ID%TYPE,
    p_positor IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Positor%TYPE,
    p_positing IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE
) RETURN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_part_PR_in_RAT_got_Reliability
        FROM
            ties.AC_part_PR_in_RAT_got_Annex a
        WHERE
            a.AC_part_PR_in_RAT_got_ID = p_id
        AND
            a.AC_part_PR_in_RAT_got_Positor = p_positor
        AND
            a.AC_part_PR_in_RAT_got_PositedAt <= p_positing
        ORDER BY
            a.AC_part_PR_in_RAT_got_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_part_PR_in_RAT_got_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_part_PR_in_RAT_got;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_part_PR_in_RAT_got tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_part_PR_in_RAT_got (
    p_id IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_ID%TYPE,
    p_positor IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Positor%TYPE,
    p_positing IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_part_PR_in_RAT_got(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_part_PR_in_RAT_got;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_part_PR_in_RAT_got states a posit of AC_part_PR_in_RAT_got, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_part_PR_in_RAT_got (
    p_AC_part IN ties.AC_part_PR_in_RAT_got_Posit.AC_ID_part%TYPE,
    p_PR_in IN ties.AC_part_PR_in_RAT_got_Posit.PR_ID_in%TYPE,
    p_RAT_got IN ties.AC_part_PR_in_RAT_got_Posit.RAT_ID_got%TYPE,
    p_changing IN ties.AC_part_PR_in_RAT_got_Posit.AC_part_PR_in_RAT_got_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_part_PR_in_RAT_got_Annex.Metadata_AC_part_PR_in_RAT_got%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Positor%TYPE;
    v_positing ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_PositedAt%TYPE;
    v_reliability ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Reliability%TYPE;
    v_held ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_Reliability%TYPE;
    v_changing ties.AC_part_PR_in_RAT_got_Posit.AC_part_PR_in_RAT_got_ChangedAt%TYPE;
    v_posit ties.AC_part_PR_in_RAT_got_Posit.AC_part_PR_in_RAT_got_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_part_PR_in_RAT_got_Annex.AC_part_PR_in_RAT_got_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_part_PR_in_RAT_got_Annex (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Annex a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = p_id
                AND
                    a.AC_part_PR_in_RAT_got_Positor = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_part_PR_in_RAT_got_ID
        FROM
            ties.AC_part_PR_in_RAT_got_Posit p
        WHERE
            p.AC_ID_part = p_AC_part
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.RAT_ID_got = p_RAT_got
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_part_PR_in_RAT_got_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Annex a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = v_posit
                AND
                    a.AC_part_PR_in_RAT_got_Positor = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
                AND
                    a.AC_part_PR_in_RAT_got_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_part_PR_in_RAT_got for: ' ||
                p_AC_part || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_got || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- and so, since a decisive positor holds one assertion at a time, are other values for identifiers that already have
    -- values (at that time), asserted by the positor at the positing time
    IF v_reliability <> 0 THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Posit p
                JOIN
                    ties.AC_part_PR_in_RAT_got_Annex a
                ON
                    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                WHERE
                    p.AC_ID_part = p_AC_part
                AND
                    p.PR_ID_in = p_PR_in
                AND
                    p.AC_part_PR_in_RAT_got_ChangedAt = v_changing
                AND
                    NOT (
                        p.RAT_ID_got = p_RAT_got
                    )
                AND
                    a.AC_part_PR_in_RAT_got_Positor = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
                AND
                    a.AC_part_PR_in_RAT_got_Reliability <> 0
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_part_PR_in_RAT_got for: ' ||
                p_AC_part || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_got || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_part_PR_in_RAT_got_Annex a
                WHERE
                    a.AC_part_PR_in_RAT_got_ID = v_posit
                AND
                    a.AC_part_PR_in_RAT_got_Positor = v_positor
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_part_PR_in_RAT_got(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_part_PR_in_RAT_got_Annex (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- an assertion corrects what the positor holds for the same identifiers (and changing time), when that has other values: it
    -- is retracted at the positing time of the assertion, so that the positor holds one posit at a time
    FOR r IN (
        SELECT
            p.AC_part_PR_in_RAT_got_ID
        FROM
            ties.AC_part_PR_in_RAT_got_Posit p
        WHERE
            p.AC_ID_part = p_AC_part
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v_changing
        AND
            NOT (
                p.RAT_ID_got = p_RAT_got
            )
        AND
            ties.ie_AC_part_PR_in_RAT_got(p.AC_part_PR_in_RAT_got_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.AC_part_PR_in_RAT_got_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_part_PR_in_RAT_got_Posit (
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt
        )
        VALUES (
            p_AC_part,
            p_PR_in,
            p_RAT_got,
            v_changing
        )
        RETURNING AC_part_PR_in_RAT_got_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_part_PR_in_RAT_got_Annex (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_part_PR_in_RAT_got
INSTEAD OF INSERT ON ties.AC_part_PR_in_RAT_got
FOR EACH ROW
BEGIN
    ties.ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => :NEW.RAT_ID_got,
        p_changing => :NEW.AC_part_PR_in_RAT_got_ChangedAt,
        p_positor => :NEW.AC_part_PR_in_RAT_got_Positor,
        p_positing => :NEW.AC_part_PR_in_RAT_got_PositedAt,
        p_reliability => :NEW.AC_part_PR_in_RAT_got_Reliability,
        p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END it_AC_part_PR_in_RAT_got;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_part_PR_in_RAT_got
INSTEAD OF INSERT ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_RAT_got number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF v_RAT_got IS NULL AND :NEW.got_RAT_Rating IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.RAT_ID
            FROM
                knots.RAT_Rating k
            WHERE
                k.RAT_Checksum = STANDARD_HASH(:NEW.got_RAT_Rating, 'MD5')
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_RAT_got := kv.RAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_part_PR_in_RAT_got(
        p_AC_part => :NEW.AC_ID_part,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_got => v_RAT_got,
        p_changing => COALESCE(:NEW.AC_part_PR_in_RAT_got_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_part_PR_in_RAT_got_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_part_PR_in_RAT_got_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_part_PR_in_RAT_got_Reliability, 1),
        p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END it_lAC_part_PR_in_RAT_got;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lAC_part_PR_in_RAT_got
INSTEAD OF UPDATE ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp;
    v_positor number(3);
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
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_got := :NEW.RAT_ID_got;
    IF (:NEW.got_RAT_Rating <> :OLD.got_RAT_Rating
        OR (:NEW.got_RAT_Rating IS NULL AND :OLD.got_RAT_Rating IS NOT NULL)
        OR (:NEW.got_RAT_Rating IS NOT NULL AND :OLD.got_RAT_Rating IS NULL))
    AND (:NEW.RAT_ID_got = :OLD.RAT_ID_got
        OR (:NEW.RAT_ID_got IS NULL AND :OLD.RAT_ID_got IS NULL)) THEN
        v_RAT_got := NULL;
        IF :NEW.got_RAT_Rating IS NOT NULL THEN
            FOR kv IN (
                SELECT
                    k.RAT_ID
                FROM
                    knots.RAT_Rating k
                WHERE
                    k.RAT_Checksum = STANDARD_HASH(:NEW.got_RAT_Rating, 'MD5')
                FETCH FIRST 1 ROW ONLY
            ) LOOP
                v_RAT_got := kv.RAT_ID;
            END LOOP;
        END IF;
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_part_PR_in_RAT_got_Positor <> :OLD.AC_part_PR_in_RAT_got_Positor
            OR (:NEW.AC_part_PR_in_RAT_got_Positor IS NULL AND :OLD.AC_part_PR_in_RAT_got_Positor IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_Positor IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_Positor IS NULL))
        THEN :NEW.AC_part_PR_in_RAT_got_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_part_PR_in_RAT_got_PositedAt <> :OLD.AC_part_PR_in_RAT_got_PositedAt
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NULL))
        THEN :NEW.AC_part_PR_in_RAT_got_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_part <> :OLD.AC_ID_part
            OR (:NEW.AC_ID_part IS NULL AND :OLD.AC_ID_part IS NOT NULL)
            OR (:NEW.AC_ID_part IS NOT NULL AND :OLD.AC_ID_part IS NULL)) OR
        (:NEW.PR_ID_in <> :OLD.PR_ID_in
            OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
            OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) OR
        (v_RAT_got <> :OLD.RAT_ID_got
            OR (v_RAT_got IS NULL AND :OLD.RAT_ID_got IS NOT NULL)
            OR (v_RAT_got IS NOT NULL AND :OLD.RAT_ID_got IS NULL)) OR
        (:NEW.AC_part_PR_in_RAT_got_ChangedAt <> :OLD.AC_part_PR_in_RAT_got_ChangedAt
            OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NULL)) OR
        (:NEW.AC_part_PR_in_RAT_got_PositedAt <> :OLD.AC_part_PR_in_RAT_got_PositedAt
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_PositedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_PositedAt IS NULL)) OR
        (:NEW.AC_part_PR_in_RAT_got_Reliability <> :OLD.AC_part_PR_in_RAT_got_Reliability
            OR (:NEW.AC_part_PR_in_RAT_got_Reliability IS NULL AND :OLD.AC_part_PR_in_RAT_got_Reliability IS NOT NULL)
            OR (:NEW.AC_part_PR_in_RAT_got_Reliability IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_part IS NOT NULL
        AND
            :NEW.PR_ID_in IS NOT NULL
        AND
            v_RAT_got IS NOT NULL
        THEN
            ties.ip_AC_part_PR_in_RAT_got(
                p_AC_part => :NEW.AC_ID_part,
                p_PR_in => :NEW.PR_ID_in,
                p_RAT_got => v_RAT_got,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_part_PR_in_RAT_got_ChangedAt <> :OLD.AC_part_PR_in_RAT_got_ChangedAt
                        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_part_PR_in_RAT_got_ChangedAt IS NOT NULL AND :OLD.AC_part_PR_in_RAT_got_ChangedAt IS NULL))
                    THEN :NEW.AC_part_PR_in_RAT_got_ChangedAt
                    WHEN
                        :NEW.AC_ID_part = :OLD.AC_ID_part
                    AND
                        :NEW.PR_ID_in = :OLD.PR_ID_in
                    AND
                        v_RAT_got = :OLD.RAT_ID_got
                    THEN :NEW.AC_part_PR_in_RAT_got_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_part_PR_in_RAT_got_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_part_PR_in_RAT_got(
                p_AC_part => :OLD.AC_ID_part,
                p_PR_in => :OLD.PR_ID_in,
                p_RAT_got => :OLD.RAT_ID_got,
                p_changing => :OLD.AC_part_PR_in_RAT_got_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_part_PR_in_RAT_got
            );
        END IF;
    END IF;
END ut_lAC_part_PR_in_RAT_got;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_part_PR_in_RAT_got
INSTEAD OF DELETE ON ties.lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_part_PR_in_RAT_got(
        p_AC_part => :OLD.AC_ID_part,
        p_PR_in => :OLD.PR_ID_in,
        p_RAT_got => :OLD.RAT_ID_got,
        p_changing => :OLD.AC_part_PR_in_RAT_got_ChangedAt,
        p_positor => COALESCE(:OLD.AC_part_PR_in_RAT_got_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_part_PR_in_RAT_got
    );
END dt_lAC_part_PR_in_RAT_got;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_at_PR_isPlaying is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_ST_at_PR_isPlaying (
    p_id IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_ID%TYPE,
    p_positor IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Positor%TYPE,
    p_positing IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE
) RETURN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_at_PR_isPlaying_Reliability
        FROM
            ties.ST_at_PR_isPlaying_Annex a
        WHERE
            a.ST_at_PR_isPlaying_ID = p_id
        AND
            a.ST_at_PR_isPlaying_Positor = p_positor
        AND
            a.ST_at_PR_isPlaying_PositedAt <= p_positing
        ORDER BY
            a.ST_at_PR_isPlaying_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_at_PR_isPlaying_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_at_PR_isPlaying;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_isPlaying tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_ST_at_PR_isPlaying (
    p_id IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_ID%TYPE,
    p_positor IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Positor%TYPE,
    p_positing IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_ST_at_PR_isPlaying(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_ST_at_PR_isPlaying;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_isPlaying states a posit of ST_at_PR_isPlaying, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_isPlaying (
    p_ST_at IN ties.ST_at_PR_isPlaying_Posit.ST_ID_at%TYPE,
    p_PR_isPlaying IN ties.ST_at_PR_isPlaying_Posit.PR_ID_isPlaying%TYPE,
    p_changing IN ties.ST_at_PR_isPlaying_Posit.ST_at_PR_isPlaying_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.ST_at_PR_isPlaying_Annex.Metadata_ST_at_PR_isPlaying%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Positor%TYPE;
    v_positing ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_PositedAt%TYPE;
    v_reliability ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Reliability%TYPE;
    v_held ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_Reliability%TYPE;
    v_changing ties.ST_at_PR_isPlaying_Posit.ST_at_PR_isPlaying_ChangedAt%TYPE;
    v_posit ties.ST_at_PR_isPlaying_Posit.ST_at_PR_isPlaying_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.ST_at_PR_isPlaying_Annex.ST_at_PR_isPlaying_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.ST_at_PR_isPlaying_Annex (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_Positor,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_isPlaying_Annex a
                WHERE
                    a.ST_at_PR_isPlaying_ID = p_id
                AND
                    a.ST_at_PR_isPlaying_Positor = v_positor
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.ST_at_PR_isPlaying_ID
        FROM
            ties.ST_at_PR_isPlaying_Posit p
        WHERE
            p.ST_ID_at = p_ST_at
        AND
            p.PR_ID_isPlaying = p_PR_isPlaying
        AND
            p.ST_at_PR_isPlaying_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_at_PR_isPlaying_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_isPlaying_Annex a
                WHERE
                    a.ST_at_PR_isPlaying_ID = v_posit
                AND
                    a.ST_at_PR_isPlaying_Positor = v_positor
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
                AND
                    a.ST_at_PR_isPlaying_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_at_PR_isPlaying for: ' ||
                p_ST_at || ', ' ||
                p_PR_isPlaying || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_isPlaying_Annex a
                WHERE
                    a.ST_at_PR_isPlaying_ID = v_posit
                AND
                    a.ST_at_PR_isPlaying_Positor = v_positor
                AND
                    a.ST_at_PR_isPlaying_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_ST_at_PR_isPlaying(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.ST_at_PR_isPlaying_Annex (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_Positor,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.ST_at_PR_isPlaying_Posit (
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt
        )
        VALUES (
            p_ST_at,
            p_PR_isPlaying,
            v_changing
        )
        RETURNING ST_at_PR_isPlaying_ID INTO v_posit;
    END IF;
    INSERT INTO ties.ST_at_PR_isPlaying_Annex (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_ST_at_PR_isPlaying
INSTEAD OF INSERT ON ties.ST_at_PR_isPlaying
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => :NEW.ST_at_PR_isPlaying_ChangedAt,
        p_positor => :NEW.ST_at_PR_isPlaying_Positor,
        p_positing => :NEW.ST_at_PR_isPlaying_PositedAt,
        p_reliability => :NEW.ST_at_PR_isPlaying_Reliability,
        p_metadata => :NEW.Metadata_ST_at_PR_isPlaying
    );
END it_ST_at_PR_isPlaying;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_isPlaying
INSTEAD OF INSERT ON ties.lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_isPlaying => :NEW.PR_ID_isPlaying,
        p_changing => COALESCE(:NEW.ST_at_PR_isPlaying_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.ST_at_PR_isPlaying_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.ST_at_PR_isPlaying_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.ST_at_PR_isPlaying_Reliability, 1),
        p_metadata => :NEW.Metadata_ST_at_PR_isPlaying
    );
END it_lST_at_PR_isPlaying;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lST_at_PR_isPlaying
INSTEAD OF DELETE ON ties.lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_ST_at_PR_isPlaying(
        p_ST_at => :OLD.ST_ID_at,
        p_PR_isPlaying => :OLD.PR_ID_isPlaying,
        p_changing => :OLD.ST_at_PR_isPlaying_ChangedAt,
        p_positor => COALESCE(:OLD.ST_at_PR_isPlaying_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_ST_at_PR_isPlaying
    );
END dt_lST_at_PR_isPlaying;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_parent_AC_child_PAT_having is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_parent_AC_child_PAT_having (
    p_id IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_ID%TYPE,
    p_positor IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Positor%TYPE,
    p_positing IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE
) RETURN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_parent_AC_child_PAT_having_Reliability
        FROM
            ties.AC_parent_AC_child_PAT_having_Annex a
        WHERE
            a.AC_parent_AC_child_PAT_having_ID = p_id
        AND
            a.AC_parent_AC_child_PAT_having_Positor = p_positor
        AND
            a.AC_parent_AC_child_PAT_having_PositedAt <= p_positing
        ORDER BY
            a.AC_parent_AC_child_PAT_having_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_parent_AC_child_PAT_having_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_parent_AC_child_PAT_having;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_parent_AC_child_PAT_having tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_parent_AC_child_PAT_having (
    p_id IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_ID%TYPE,
    p_positor IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Positor%TYPE,
    p_positing IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_parent_AC_child_PAT_having(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_parent_AC_child_PAT_having;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_parent_AC_child_PAT_having states a posit of AC_parent_AC_child_PAT_having, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_parent_AC_child_PAT_having (
    p_AC_parent IN ties.AC_parent_AC_child_PAT_having_Posit.AC_ID_parent%TYPE,
    p_AC_child IN ties.AC_parent_AC_child_PAT_having_Posit.AC_ID_child%TYPE,
    p_PAT_having IN ties.AC_parent_AC_child_PAT_having_Posit.PAT_ID_having%TYPE,
    p_positor IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_parent_AC_child_PAT_having_Annex.Metadata_AC_parent_AC_child_PAT_having%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Positor%TYPE;
    v_positing ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_PositedAt%TYPE;
    v_reliability ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Reliability%TYPE;
    v_held ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_Reliability%TYPE;
    v_posit ties.AC_parent_AC_child_PAT_having_Posit.AC_parent_AC_child_PAT_having_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_parent_AC_child_PAT_having_Annex.AC_parent_AC_child_PAT_having_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_parent_AC_child_PAT_having_Annex (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_Positor,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_parent_AC_child_PAT_having_Annex a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = p_id
                AND
                    a.AC_parent_AC_child_PAT_having_Positor = v_positor
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.AC_parent_AC_child_PAT_having_ID
        FROM
            ties.AC_parent_AC_child_PAT_having_Posit p
        WHERE
            p.AC_ID_parent = p_AC_parent
        AND
            p.AC_ID_child = p_AC_child
        AND
            p.PAT_ID_having = p_PAT_having
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_parent_AC_child_PAT_having_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_parent_AC_child_PAT_having_Annex a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = v_posit
                AND
                    a.AC_parent_AC_child_PAT_having_Positor = v_positor
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
                AND
                    a.AC_parent_AC_child_PAT_having_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_parent_AC_child_PAT_having for: ' ||
                p_AC_parent || ', ' ||
                p_AC_child || ', ' ||
                p_PAT_having || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_parent_AC_child_PAT_having_Annex a
                WHERE
                    a.AC_parent_AC_child_PAT_having_ID = v_posit
                AND
                    a.AC_parent_AC_child_PAT_having_Positor = v_positor
                AND
                    a.AC_parent_AC_child_PAT_having_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_parent_AC_child_PAT_having(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_parent_AC_child_PAT_having_Annex (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_Positor,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_parent_AC_child_PAT_having_Posit (
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        )
        VALUES (
            p_AC_parent,
            p_AC_child,
            p_PAT_having
        )
        RETURNING AC_parent_AC_child_PAT_having_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_parent_AC_child_PAT_having_Annex (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON ties.AC_parent_AC_child_PAT_having
FOR EACH ROW
BEGIN
    ties.ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => :NEW.PAT_ID_having,
        p_positor => :NEW.AC_parent_AC_child_PAT_having_Positor,
        p_positing => :NEW.AC_parent_AC_child_PAT_having_PositedAt,
        p_reliability => :NEW.AC_parent_AC_child_PAT_having_Reliability,
        p_metadata => :NEW.Metadata_AC_parent_AC_child_PAT_having
    );
END it_AC_parent_AC_child_PAT_having;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_parent_AC_child_PAT_having
INSTEAD OF INSERT ON ties.lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_PAT_having number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
    v_PAT_having := :NEW.PAT_ID_having;
    IF v_PAT_having IS NULL AND :NEW.having_PAT_ParentalType IS NOT NULL THEN
        FOR kv IN (
            SELECT
                k.PAT_ID
            FROM
                knots.PAT_ParentalType k
            WHERE
                k.PAT_ParentalType = :NEW.having_PAT_ParentalType
            FETCH FIRST 1 ROW ONLY
        ) LOOP
            v_PAT_having := kv.PAT_ID;
        END LOOP;
    END IF;
    ties.ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :NEW.AC_ID_parent,
        p_AC_child => :NEW.AC_ID_child,
        p_PAT_having => v_PAT_having,
        p_positor => COALESCE(:NEW.AC_parent_AC_child_PAT_having_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_parent_AC_child_PAT_having_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_parent_AC_child_PAT_having_Reliability, 1),
        p_metadata => :NEW.Metadata_AC_parent_AC_child_PAT_having
    );
END it_lAC_parent_AC_child_PAT_having;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_parent_AC_child_PAT_having
INSTEAD OF DELETE ON ties.lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_parent_AC_child_PAT_having(
        p_AC_parent => :OLD.AC_ID_parent,
        p_AC_child => :OLD.AC_ID_child,
        p_PAT_having => :OLD.PAT_ID_having,
        p_positor => COALESCE(:OLD.AC_parent_AC_child_PAT_having_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_parent_AC_child_PAT_having
    );
END dt_lAC_parent_AC_child_PAT_having;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_content_ST_location_EV_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_PR_content_ST_location_EV_of (
    p_id IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_ID%TYPE,
    p_positor IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Positor%TYPE,
    p_positing IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE
) RETURN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_content_ST_location_EV_of_Reliability
        FROM
            ties.PR_content_ST_location_EV_of_Annex a
        WHERE
            a.PR_content_ST_location_EV_of_ID = p_id
        AND
            a.PR_content_ST_location_EV_of_Positor = p_positor
        AND
            a.PR_content_ST_location_EV_of_PositedAt <= p_positing
        ORDER BY
            a.PR_content_ST_location_EV_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_content_ST_location_EV_of_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_content_ST_location_EV_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_content_ST_location_EV_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_PR_content_ST_location_EV_of (
    p_id IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_ID%TYPE,
    p_positor IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Positor%TYPE,
    p_positing IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_PR_content_ST_location_EV_of(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_PR_content_ST_location_EV_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_content_ST_location_EV_of states a posit of PR_content_ST_location_EV_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_content_ST_location_EV_of (
    p_PR_content IN ties.PR_content_ST_location_EV_of_Posit.PR_ID_content%TYPE,
    p_ST_location IN ties.PR_content_ST_location_EV_of_Posit.ST_ID_location%TYPE,
    p_EV_of IN ties.PR_content_ST_location_EV_of_Posit.EV_ID_of%TYPE,
    p_changing IN ties.PR_content_ST_location_EV_of_Posit.PR_content_ST_location_EV_of_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.PR_content_ST_location_EV_of_Annex.Metadata_PR_content_ST_location_EV_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Positor%TYPE;
    v_positing ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_PositedAt%TYPE;
    v_reliability ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Reliability%TYPE;
    v_held ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_Reliability%TYPE;
    v_changing ties.PR_content_ST_location_EV_of_Posit.PR_content_ST_location_EV_of_ChangedAt%TYPE;
    v_posit ties.PR_content_ST_location_EV_of_Posit.PR_content_ST_location_EV_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.PR_content_ST_location_EV_of_Annex.PR_content_ST_location_EV_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.PR_content_ST_location_EV_of_Annex (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        )
        SELECT
            COALESCE(p_metadata, 0),
            p_id,
            v_positor,
            v_positing,
            0
        FROM
            dual
        WHERE
            NOT EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_content_ST_location_EV_of_Annex a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = p_id
                AND
                    a.PR_content_ST_location_EV_of_Positor = v_positor
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
            );
    END retract;
BEGIN
    v_positor := COALESCE(p_positor, 0);
    v_positing := COALESCE(p_positing, v_now);
    v_reliability := COALESCE(p_reliability, 1);
    v_changing := COALESCE(p_changing, v_now);
    IF v_reliability > 0 THEN
        v_sign := 1;
    ELSE
        v_sign := 0;
    END IF;
    -- the posit, if there is one
    FOR r IN (
        SELECT
            p.PR_content_ST_location_EV_of_ID
        FROM
            ties.PR_content_ST_location_EV_of_Posit p
        WHERE
            p.PR_ID_content = p_PR_content
        AND
            p.ST_ID_location = p_ST_location
        AND
            p.EV_ID_of = p_EV_of
        AND
            p.PR_content_ST_location_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_content_ST_location_EV_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_content_ST_location_EV_of_Annex a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = v_posit
                AND
                    a.PR_content_ST_location_EV_of_Positor = v_positor
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
                AND
                    a.PR_content_ST_location_EV_of_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_content_ST_location_EV_of for: ' ||
                p_PR_content || ', ' ||
                p_ST_location || ', ' ||
                p_EV_of || ', ' ||
                v_changing || ', ' ||
                v_positor || ', ' || v_positing);
        END IF;
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_content_ST_location_EV_of_Annex a
                WHERE
                    a.PR_content_ST_location_EV_of_ID = v_posit
                AND
                    a.PR_content_ST_location_EV_of_Positor = v_positor
                AND
                    a.PR_content_ST_location_EV_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_PR_content_ST_location_EV_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.PR_content_ST_location_EV_of_Annex (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        )
        VALUES (
            COALESCE(p_metadata, 0),
            v_posit,
            v_positor,
            v_positing,
            v_reliability
        );
        RETURN;
    END IF;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.PR_content_ST_location_EV_of_Posit (
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt
        )
        VALUES (
            p_PR_content,
            p_ST_location,
            p_EV_of,
            v_changing
        )
        RETURNING PR_content_ST_location_EV_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.PR_content_ST_location_EV_of_Annex (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_PR_content_ST_location_EV_of
INSTEAD OF INSERT ON ties.PR_content_ST_location_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_content_ST_location_EV_of_ChangedAt,
        p_positor => :NEW.PR_content_ST_location_EV_of_Positor,
        p_positing => :NEW.PR_content_ST_location_EV_of_PositedAt,
        p_reliability => :NEW.PR_content_ST_location_EV_of_Reliability,
        p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
    );
END it_PR_content_ST_location_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_content_ST_location_EV_of
INSTEAD OF INSERT ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :NEW.PR_ID_content,
        p_ST_location => :NEW.ST_ID_location,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => COALESCE(:NEW.PR_content_ST_location_EV_of_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.PR_content_ST_location_EV_of_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.PR_content_ST_location_EV_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.PR_content_ST_location_EV_of_Reliability, 1),
        p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
    );
END it_lPR_content_ST_location_EV_of;
/
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.ut_lPR_content_ST_location_EV_of
INSTEAD OF UPDATE ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positing timestamp;
    v_positor number(3);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.PR_content_ST_location_EV_of_Positor <> :OLD.PR_content_ST_location_EV_of_Positor
            OR (:NEW.PR_content_ST_location_EV_of_Positor IS NULL AND :OLD.PR_content_ST_location_EV_of_Positor IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_Positor IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_Positor IS NULL))
        THEN :NEW.PR_content_ST_location_EV_of_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.PR_content_ST_location_EV_of_PositedAt <> :OLD.PR_content_ST_location_EV_of_PositedAt
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NULL))
        THEN :NEW.PR_content_ST_location_EV_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.PR_ID_content <> :OLD.PR_ID_content
            OR (:NEW.PR_ID_content IS NULL AND :OLD.PR_ID_content IS NOT NULL)
            OR (:NEW.PR_ID_content IS NOT NULL AND :OLD.PR_ID_content IS NULL)) OR
        (:NEW.ST_ID_location <> :OLD.ST_ID_location
            OR (:NEW.ST_ID_location IS NULL AND :OLD.ST_ID_location IS NOT NULL)
            OR (:NEW.ST_ID_location IS NOT NULL AND :OLD.ST_ID_location IS NULL)) OR
        (:NEW.EV_ID_of <> :OLD.EV_ID_of
            OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
            OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_ChangedAt <> :OLD.PR_content_ST_location_EV_of_ChangedAt
            OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_PositedAt <> :OLD.PR_content_ST_location_EV_of_PositedAt
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_PositedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_PositedAt IS NULL)) OR
        (:NEW.PR_content_ST_location_EV_of_Reliability <> :OLD.PR_content_ST_location_EV_of_Reliability
            OR (:NEW.PR_content_ST_location_EV_of_Reliability IS NULL AND :OLD.PR_content_ST_location_EV_of_Reliability IS NOT NULL)
            OR (:NEW.PR_content_ST_location_EV_of_Reliability IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_Reliability IS NULL))
    THEN
        IF
            :NEW.PR_ID_content IS NOT NULL
        AND
            :NEW.ST_ID_location IS NOT NULL
        AND
            :NEW.EV_ID_of IS NOT NULL
        THEN
            ties.ip_PR_content_ST_location_EV_of(
                p_PR_content => :NEW.PR_ID_content,
                p_ST_location => :NEW.ST_ID_location,
                p_EV_of => :NEW.EV_ID_of,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.PR_content_ST_location_EV_of_ChangedAt <> :OLD.PR_content_ST_location_EV_of_ChangedAt
                        OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_content_ST_location_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_content_ST_location_EV_of_ChangedAt IS NULL))
                    THEN :NEW.PR_content_ST_location_EV_of_ChangedAt
                    WHEN
                        :NEW.PR_ID_content = :OLD.PR_ID_content
                    AND
                        :NEW.ST_ID_location = :OLD.ST_ID_location
                    AND
                        :NEW.EV_ID_of = :OLD.EV_ID_of
                    THEN :NEW.PR_content_ST_location_EV_of_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.PR_content_ST_location_EV_of_Reliability, 1),
                p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_PR_content_ST_location_EV_of(
                p_PR_content => :OLD.PR_ID_content,
                p_ST_location => :OLD.ST_ID_location,
                p_EV_of => :OLD.EV_ID_of,
                p_changing => :OLD.PR_content_ST_location_EV_of_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_PR_content_ST_location_EV_of
            );
        END IF;
    END IF;
END ut_lPR_content_ST_location_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_content_ST_location_EV_of
INSTEAD OF DELETE ON ties.lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_PR_content_ST_location_EV_of(
        p_PR_content => :OLD.PR_ID_content,
        p_ST_location => :OLD.ST_ID_location,
        p_EV_of => :OLD.EV_ID_of,
        p_changing => :OLD.PR_content_ST_location_EV_of_ChangedAt,
        p_positor => COALESCE(:OLD.PR_content_ST_location_EV_of_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_PR_content_ST_location_EV_of
    );
END dt_lPR_content_ST_location_EV_of;
/
