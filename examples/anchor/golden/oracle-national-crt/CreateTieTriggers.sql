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
    IF (:NEW.currently_ONG_Pågående <> :OLD.currently_ONG_Pågående
        OR (:NEW.currently_ONG_Pågående IS NULL AND :OLD.currently_ONG_Pågående IS NOT NULL)
        OR (:NEW.currently_ONG_Pågående IS NOT NULL AND :OLD.currently_ONG_Pågående IS NULL))
    AND (:NEW.ONG_ID_currently = :OLD.ONG_ID_currently
        OR (:NEW.ONG_ID_currently IS NULL AND :OLD.ONG_ID_currently IS NULL)) THEN
        v_ONG_currently := NULL;
        IF :NEW.currently_ONG_Pågående IS NOT NULL THEN
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
-- he_EV_in_AC_rollsattes is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_EV_in_AC_rollsattes (
    p_id IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_ID%TYPE,
    p_positor IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE,
    p_positing IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE
) RETURN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.EV_in_AC_rollsattes_Reliability
        FROM
            ties.EV_in_AC_rollsattes_Annex a
        WHERE
            a.EV_in_AC_rollsattes_ID = p_id
        AND
            a.EV_in_AC_rollsattes_Positor = p_positor
        AND
            a.EV_in_AC_rollsattes_PositedAt <= p_positing
        ORDER BY
            a.EV_in_AC_rollsattes_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.EV_in_AC_rollsattes_Reliability;
    END LOOP;
    RETURN NULL;
END he_EV_in_AC_rollsattes;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_rollsattes tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_EV_in_AC_rollsattes (
    p_id IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_ID%TYPE,
    p_positor IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE,
    p_positing IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_EV_in_AC_rollsattes(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_EV_in_AC_rollsattes;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_EV_in_AC_rollsattes states a posit of EV_in_AC_rollsattes, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_EV_in_AC_rollsattes (
    p_EV_in IN ties.EV_in_AC_rollsattes_Posit.EV_ID_in%TYPE,
    p_AC_rollsattes IN ties.EV_in_AC_rollsattes_Posit.AC_ID_rollsattes%TYPE,
    p_positor IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.EV_in_AC_rollsattes_Annex.Metadata_EV_in_AC_rollsattes%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Positor%TYPE;
    v_positing ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_PositedAt%TYPE;
    v_reliability ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE;
    v_held ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_Reliability%TYPE;
    v_posit ties.EV_in_AC_rollsattes_Posit.EV_in_AC_rollsattes_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.EV_in_AC_rollsattes_Annex.EV_in_AC_rollsattes_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.EV_in_AC_rollsattes_Annex (
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Reliability
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
                    ties.EV_in_AC_rollsattes_Annex a
                WHERE
                    a.EV_in_AC_rollsattes_ID = p_id
                AND
                    a.EV_in_AC_rollsattes_Positor = v_positor
                AND
                    a.EV_in_AC_rollsattes_PositedAt = v_positing
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
            p.EV_in_AC_rollsattes_ID
        FROM
            ties.EV_in_AC_rollsattes_Posit p
        WHERE
            p.EV_ID_in = p_EV_in
        AND
            p.AC_ID_rollsattes = p_AC_rollsattes
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.EV_in_AC_rollsattes_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.EV_in_AC_rollsattes_Annex a
                WHERE
                    a.EV_in_AC_rollsattes_ID = v_posit
                AND
                    a.EV_in_AC_rollsattes_Positor = v_positor
                AND
                    a.EV_in_AC_rollsattes_PositedAt = v_positing
                AND
                    a.EV_in_AC_rollsattes_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in EV_in_AC_rollsattes for: ' ||
                p_EV_in || ', ' ||
                p_AC_rollsattes || ', ' ||
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
                    ties.EV_in_AC_rollsattes_Annex a
                WHERE
                    a.EV_in_AC_rollsattes_ID = v_posit
                AND
                    a.EV_in_AC_rollsattes_Positor = v_positor
                AND
                    a.EV_in_AC_rollsattes_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_EV_in_AC_rollsattes(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.EV_in_AC_rollsattes_Annex (
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Reliability
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
        INSERT INTO ties.EV_in_AC_rollsattes_Posit (
            EV_ID_in,
            AC_ID_rollsattes
        )
        VALUES (
            p_EV_in,
            p_AC_rollsattes
        )
        RETURNING EV_in_AC_rollsattes_ID INTO v_posit;
    END IF;
    INSERT INTO ties.EV_in_AC_rollsattes_Annex (
        Metadata_EV_in_AC_rollsattes,
        EV_in_AC_rollsattes_ID,
        EV_in_AC_rollsattes_Positor,
        EV_in_AC_rollsattes_PositedAt,
        EV_in_AC_rollsattes_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_EV_in_AC_rollsattes;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_rollsattes instead of INSERT trigger on EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_EV_in_AC_rollsattes
INSTEAD OF INSERT ON ties.EV_in_AC_rollsattes
FOR EACH ROW
BEGIN
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_rollsattes => :NEW.AC_ID_rollsattes,
        p_positor => :NEW.EV_in_AC_rollsattes_Positor,
        p_positing => :NEW.EV_in_AC_rollsattes_PositedAt,
        p_reliability => :NEW.EV_in_AC_rollsattes_Reliability,
        p_metadata => :NEW.Metadata_EV_in_AC_rollsattes
    );
END it_EV_in_AC_rollsattes;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lEV_in_AC_rollsattes
INSTEAD OF INSERT ON ties.lEV_in_AC_rollsattes
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :NEW.EV_ID_in,
        p_AC_rollsattes => :NEW.AC_ID_rollsattes,
        p_positor => COALESCE(:NEW.EV_in_AC_rollsattes_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.EV_in_AC_rollsattes_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.EV_in_AC_rollsattes_Reliability, 1),
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_EV_in_AC_rollsattes(
        p_EV_in => :OLD.EV_ID_in,
        p_AC_rollsattes => :OLD.AC_ID_rollsattes,
        p_positor => COALESCE(:OLD.EV_in_AC_rollsattes_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_EV_in_AC_rollsattes
    );
END dt_lEV_in_AC_rollsattes;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_deltar_PR_in_RAT_fick is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_deltar_PR_in_RAT_fick (
    p_id IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_ID%TYPE,
    p_positor IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE,
    p_positing IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE
) RETURN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_deltar_PR_in_RAT_fick_Reliability
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Annex a
        WHERE
            a.AC_deltar_PR_in_RAT_fick_ID = p_id
        AND
            a.AC_deltar_PR_in_RAT_fick_Positor = p_positor
        AND
            a.AC_deltar_PR_in_RAT_fick_PositedAt <= p_positing
        ORDER BY
            a.AC_deltar_PR_in_RAT_fick_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_deltar_PR_in_RAT_fick_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_deltar_PR_in_RAT_fick;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_deltar_PR_in_RAT_fick tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_deltar_PR_in_RAT_fick (
    p_id IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_ID%TYPE,
    p_positor IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE,
    p_positing IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_deltar_PR_in_RAT_fick(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_deltar_PR_in_RAT_fick;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_deltar_PR_in_RAT_fick states a posit of AC_deltar_PR_in_RAT_fick, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_deltar_PR_in_RAT_fick (
    p_AC_deltar IN ties.AC_deltar_PR_in_RAT_fick_Posit.AC_ID_deltar%TYPE,
    p_PR_in IN ties.AC_deltar_PR_in_RAT_fick_Posit.PR_ID_in%TYPE,
    p_RAT_fick IN ties.AC_deltar_PR_in_RAT_fick_Posit.RAT_ID_fick%TYPE,
    p_changing IN ties.AC_deltar_PR_in_RAT_fick_Posit.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_deltar_PR_in_RAT_fick_Annex.Metadata_AC_deltar_PR_in_RAT_fick%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Positor%TYPE;
    v_positing ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_PositedAt%TYPE;
    v_reliability ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE;
    v_held ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_Reliability%TYPE;
    v_changing ties.AC_deltar_PR_in_RAT_fick_Posit.AC_deltar_PR_in_RAT_fick_ChangedAt%TYPE;
    v_posit ties.AC_deltar_PR_in_RAT_fick_Posit.AC_deltar_PR_in_RAT_fick_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_deltar_PR_in_RAT_fick_Annex.AC_deltar_PR_in_RAT_fick_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Annex (
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Reliability
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
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                WHERE
                    a.AC_deltar_PR_in_RAT_fick_ID = p_id
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
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
            p.AC_deltar_PR_in_RAT_fick_ID
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit p
        WHERE
            p.AC_ID_deltar = p_AC_deltar
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.RAT_ID_fick = p_RAT_fick
        AND
            p.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_deltar_PR_in_RAT_fick_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                WHERE
                    a.AC_deltar_PR_in_RAT_fick_ID = v_posit
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
                AND
                    a.AC_deltar_PR_in_RAT_fick_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_deltar_PR_in_RAT_fick for: ' ||
                p_AC_deltar || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_fick || ', ' ||
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
                    ties.AC_deltar_PR_in_RAT_fick_Posit p
                JOIN
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                ON
                    a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
                WHERE
                    p.AC_ID_deltar = p_AC_deltar
                AND
                    p.PR_ID_in = p_PR_in
                AND
                    p.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
                AND
                    NOT (
                        p.RAT_ID_fick = p_RAT_fick
                    )
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
                AND
                    a.AC_deltar_PR_in_RAT_fick_Reliability <> 0
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_deltar_PR_in_RAT_fick for: ' ||
                p_AC_deltar || ', ' ||
                p_PR_in || ', ' ||
                p_RAT_fick || ', ' ||
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
                    ties.AC_deltar_PR_in_RAT_fick_Annex a
                WHERE
                    a.AC_deltar_PR_in_RAT_fick_ID = v_posit
                AND
                    a.AC_deltar_PR_in_RAT_fick_Positor = v_positor
                AND
                    a.AC_deltar_PR_in_RAT_fick_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_deltar_PR_in_RAT_fick(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Annex (
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Reliability
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
            p.AC_deltar_PR_in_RAT_fick_ID
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit p
        WHERE
            p.AC_ID_deltar = p_AC_deltar
        AND
            p.PR_ID_in = p_PR_in
        AND
            p.AC_deltar_PR_in_RAT_fick_ChangedAt = v_changing
        AND
            NOT (
                p.RAT_ID_fick = p_RAT_fick
            )
        AND
            ties.ie_AC_deltar_PR_in_RAT_fick(p.AC_deltar_PR_in_RAT_fick_ID, v_positor, v_positing) = 1
    ) LOOP
        retract(r.AC_deltar_PR_in_RAT_fick_ID);
    END LOOP;
    -- the posit, which is new when it was not found
    IF v_posit IS NULL THEN
        INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Posit (
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt
        )
        VALUES (
            p_AC_deltar,
            p_PR_in,
            p_RAT_fick,
            v_changing
        )
        RETURNING AC_deltar_PR_in_RAT_fick_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_deltar_PR_in_RAT_fick_Annex (
        Metadata_AC_deltar_PR_in_RAT_fick,
        AC_deltar_PR_in_RAT_fick_ID,
        AC_deltar_PR_in_RAT_fick_Positor,
        AC_deltar_PR_in_RAT_fick_PositedAt,
        AC_deltar_PR_in_RAT_fick_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_deltar_PR_in_RAT_fick;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_deltar_PR_in_RAT_fick instead of INSERT trigger on AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_deltar_PR_in_RAT_fick
INSTEAD OF INSERT ON ties.AC_deltar_PR_in_RAT_fick
FOR EACH ROW
BEGIN
    ties.ip_AC_deltar_PR_in_RAT_fick(
        p_AC_deltar => :NEW.AC_ID_deltar,
        p_PR_in => :NEW.PR_ID_in,
        p_RAT_fick => :NEW.RAT_ID_fick,
        p_changing => :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt,
        p_positor => :NEW.AC_deltar_PR_in_RAT_fick_Positor,
        p_positing => :NEW.AC_deltar_PR_in_RAT_fick_PositedAt,
        p_reliability => :NEW.AC_deltar_PR_in_RAT_fick_Reliability,
        p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
    );
END it_AC_deltar_PR_in_RAT_fick;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_deltar_PR_in_RAT_fick
INSTEAD OF INSERT ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_RAT_fick number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
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
        p_changing => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
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
    -- the identity of the knot value, given as it is or looked up from the value
    v_RAT_fick := :NEW.RAT_ID_fick;
    IF (:NEW.fick_RAT_Betyg <> :OLD.fick_RAT_Betyg
        OR (:NEW.fick_RAT_Betyg IS NULL AND :OLD.fick_RAT_Betyg IS NOT NULL)
        OR (:NEW.fick_RAT_Betyg IS NOT NULL AND :OLD.fick_RAT_Betyg IS NULL))
    AND (:NEW.RAT_ID_fick = :OLD.RAT_ID_fick
        OR (:NEW.RAT_ID_fick IS NULL AND :OLD.RAT_ID_fick IS NULL)) THEN
        v_RAT_fick := NULL;
        IF :NEW.fick_RAT_Betyg IS NOT NULL THEN
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
    END IF;
    v_positor := COALESCE(CASE
        WHEN (:NEW.AC_deltar_PR_in_RAT_fick_Positor <> :OLD.AC_deltar_PR_in_RAT_fick_Positor
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Positor IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Positor IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Positor IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Positor IS NULL))
        THEN :NEW.AC_deltar_PR_in_RAT_fick_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt <> :OLD.AC_deltar_PR_in_RAT_fick_PositedAt
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL))
        THEN :NEW.AC_deltar_PR_in_RAT_fick_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.AC_ID_deltar <> :OLD.AC_ID_deltar
            OR (:NEW.AC_ID_deltar IS NULL AND :OLD.AC_ID_deltar IS NOT NULL)
            OR (:NEW.AC_ID_deltar IS NOT NULL AND :OLD.AC_ID_deltar IS NULL)) OR
        (:NEW.PR_ID_in <> :OLD.PR_ID_in
            OR (:NEW.PR_ID_in IS NULL AND :OLD.PR_ID_in IS NOT NULL)
            OR (:NEW.PR_ID_in IS NOT NULL AND :OLD.PR_ID_in IS NULL)) OR
        (v_RAT_fick <> :OLD.RAT_ID_fick
            OR (v_RAT_fick IS NULL AND :OLD.RAT_ID_fick IS NOT NULL)
            OR (v_RAT_fick IS NOT NULL AND :OLD.RAT_ID_fick IS NULL)) OR
        (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt <> :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
            OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL)) OR
        (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt <> :OLD.AC_deltar_PR_in_RAT_fick_PositedAt
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_PositedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_PositedAt IS NULL)) OR
        (:NEW.AC_deltar_PR_in_RAT_fick_Reliability <> :OLD.AC_deltar_PR_in_RAT_fick_Reliability
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Reliability IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Reliability IS NOT NULL)
            OR (:NEW.AC_deltar_PR_in_RAT_fick_Reliability IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_Reliability IS NULL))
    THEN
        IF
            :NEW.AC_ID_deltar IS NOT NULL
        AND
            :NEW.PR_ID_in IS NOT NULL
        AND
            v_RAT_fick IS NOT NULL
        THEN
            ties.ip_AC_deltar_PR_in_RAT_fick(
                p_AC_deltar => :NEW.AC_ID_deltar,
                p_PR_in => :NEW.PR_ID_in,
                p_RAT_fick => v_RAT_fick,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt <> :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt
                        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL)
                        OR (:NEW.AC_deltar_PR_in_RAT_fick_ChangedAt IS NOT NULL AND :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL))
                    THEN :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt
                    WHEN
                        :NEW.AC_ID_deltar = :OLD.AC_ID_deltar
                    AND
                        :NEW.PR_ID_in = :OLD.PR_ID_in
                    AND
                        v_RAT_fick = :OLD.RAT_ID_fick
                    THEN :NEW.AC_deltar_PR_in_RAT_fick_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.AC_deltar_PR_in_RAT_fick_Reliability, 1),
                p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_AC_deltar_PR_in_RAT_fick(
                p_AC_deltar => :OLD.AC_ID_deltar,
                p_PR_in => :OLD.PR_ID_in,
                p_RAT_fick => :OLD.RAT_ID_fick,
                p_changing => :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_AC_deltar_PR_in_RAT_fick
            );
        END IF;
    END IF;
END ut_lAC_deltar_PR_in_RAT_fick;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lAC_deltar_PR_in_RAT_fick
INSTEAD OF DELETE ON ties.lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_deltar_PR_in_RAT_fick(
        p_AC_deltar => :OLD.AC_ID_deltar,
        p_PR_in => :OLD.PR_ID_in,
        p_RAT_fick => :OLD.RAT_ID_fick,
        p_changing => :OLD.AC_deltar_PR_in_RAT_fick_ChangedAt,
        p_positor => COALESCE(:OLD.AC_deltar_PR_in_RAT_fick_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_deltar_PR_in_RAT_fick
    );
END dt_lAC_deltar_PR_in_RAT_fick;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_ST_at_PR_spelas is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_ST_at_PR_spelas (
    p_id IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_ID%TYPE,
    p_positor IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE,
    p_positing IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE
) RETURN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.ST_at_PR_spelas_Reliability
        FROM
            ties.ST_at_PR_spelas_Annex a
        WHERE
            a.ST_at_PR_spelas_ID = p_id
        AND
            a.ST_at_PR_spelas_Positor = p_positor
        AND
            a.ST_at_PR_spelas_PositedAt <= p_positing
        ORDER BY
            a.ST_at_PR_spelas_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.ST_at_PR_spelas_Reliability;
    END LOOP;
    RETURN NULL;
END he_ST_at_PR_spelas;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_spelas tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_ST_at_PR_spelas (
    p_id IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_ID%TYPE,
    p_positor IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE,
    p_positing IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_ST_at_PR_spelas(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_ST_at_PR_spelas;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_ST_at_PR_spelas states a posit of ST_at_PR_spelas, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_ST_at_PR_spelas (
    p_ST_at IN ties.ST_at_PR_spelas_Posit.ST_ID_at%TYPE,
    p_PR_spelas IN ties.ST_at_PR_spelas_Posit.PR_ID_spelas%TYPE,
    p_changing IN ties.ST_at_PR_spelas_Posit.ST_at_PR_spelas_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.ST_at_PR_spelas_Annex.Metadata_ST_at_PR_spelas%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Positor%TYPE;
    v_positing ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_PositedAt%TYPE;
    v_reliability ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE;
    v_held ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_Reliability%TYPE;
    v_changing ties.ST_at_PR_spelas_Posit.ST_at_PR_spelas_ChangedAt%TYPE;
    v_posit ties.ST_at_PR_spelas_Posit.ST_at_PR_spelas_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.ST_at_PR_spelas_Annex.ST_at_PR_spelas_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.ST_at_PR_spelas_Annex (
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Reliability
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
                    ties.ST_at_PR_spelas_Annex a
                WHERE
                    a.ST_at_PR_spelas_ID = p_id
                AND
                    a.ST_at_PR_spelas_Positor = v_positor
                AND
                    a.ST_at_PR_spelas_PositedAt = v_positing
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
            p.ST_at_PR_spelas_ID
        FROM
            ties.ST_at_PR_spelas_Posit p
        WHERE
            p.ST_ID_at = p_ST_at
        AND
            p.PR_ID_spelas = p_PR_spelas
        AND
            p.ST_at_PR_spelas_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.ST_at_PR_spelas_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.ST_at_PR_spelas_Annex a
                WHERE
                    a.ST_at_PR_spelas_ID = v_posit
                AND
                    a.ST_at_PR_spelas_Positor = v_positor
                AND
                    a.ST_at_PR_spelas_PositedAt = v_positing
                AND
                    a.ST_at_PR_spelas_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in ST_at_PR_spelas for: ' ||
                p_ST_at || ', ' ||
                p_PR_spelas || ', ' ||
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
                    ties.ST_at_PR_spelas_Annex a
                WHERE
                    a.ST_at_PR_spelas_ID = v_posit
                AND
                    a.ST_at_PR_spelas_Positor = v_positor
                AND
                    a.ST_at_PR_spelas_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_ST_at_PR_spelas(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.ST_at_PR_spelas_Annex (
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Reliability
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
        INSERT INTO ties.ST_at_PR_spelas_Posit (
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt
        )
        VALUES (
            p_ST_at,
            p_PR_spelas,
            v_changing
        )
        RETURNING ST_at_PR_spelas_ID INTO v_posit;
    END IF;
    INSERT INTO ties.ST_at_PR_spelas_Annex (
        Metadata_ST_at_PR_spelas,
        ST_at_PR_spelas_ID,
        ST_at_PR_spelas_Positor,
        ST_at_PR_spelas_PositedAt,
        ST_at_PR_spelas_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_ST_at_PR_spelas;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_spelas instead of INSERT trigger on ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_ST_at_PR_spelas
INSTEAD OF INSERT ON ties.ST_at_PR_spelas
FOR EACH ROW
BEGIN
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_spelas => :NEW.PR_ID_spelas,
        p_changing => :NEW.ST_at_PR_spelas_ChangedAt,
        p_positor => :NEW.ST_at_PR_spelas_Positor,
        p_positing => :NEW.ST_at_PR_spelas_PositedAt,
        p_reliability => :NEW.ST_at_PR_spelas_Reliability,
        p_metadata => :NEW.Metadata_ST_at_PR_spelas
    );
END it_ST_at_PR_spelas;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lST_at_PR_spelas
INSTEAD OF INSERT ON ties.lST_at_PR_spelas
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :NEW.ST_ID_at,
        p_PR_spelas => :NEW.PR_ID_spelas,
        p_changing => COALESCE(:NEW.ST_at_PR_spelas_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.ST_at_PR_spelas_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.ST_at_PR_spelas_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.ST_at_PR_spelas_Reliability, 1),
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_ST_at_PR_spelas(
        p_ST_at => :OLD.ST_ID_at,
        p_PR_spelas => :OLD.PR_ID_spelas,
        p_changing => :OLD.ST_at_PR_spelas_ChangedAt,
        p_positor => COALESCE(:OLD.ST_at_PR_spelas_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_ST_at_PR_spelas
    );
END dt_lST_at_PR_spelas;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_AC_förälder_AC_barn_PAT_har is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_AC_förälder_AC_barn_PAT_har (
    p_id IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_ID%TYPE,
    p_positor IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE,
    p_positing IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE
) RETURN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.AC_förälder_AC_barn_PAT_har_Reliability
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Annex a
        WHERE
            a.AC_förälder_AC_barn_PAT_har_ID = p_id
        AND
            a.AC_förälder_AC_barn_PAT_har_Positor = p_positor
        AND
            a.AC_förälder_AC_barn_PAT_har_PositedAt <= p_positing
        ORDER BY
            a.AC_förälder_AC_barn_PAT_har_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.AC_förälder_AC_barn_PAT_har_Reliability;
    END LOOP;
    RETURN NULL;
END he_AC_förälder_AC_barn_PAT_har;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_förälder_AC_barn_PAT_har tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_AC_förälder_AC_barn_PAT_har (
    p_id IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_ID%TYPE,
    p_positor IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE,
    p_positing IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_AC_förälder_AC_barn_PAT_har(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_AC_förälder_AC_barn_PAT_har;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_AC_förälder_AC_barn_PAT_har states a posit of AC_förälder_AC_barn_PAT_har, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_AC_förälder_AC_barn_PAT_har (
    p_AC_förälder IN ties.AC_förälder_AC_barn_PAT_har_Posit.AC_ID_förälder%TYPE,
    p_AC_barn IN ties.AC_förälder_AC_barn_PAT_har_Posit.AC_ID_barn%TYPE,
    p_PAT_har IN ties.AC_förälder_AC_barn_PAT_har_Posit.PAT_ID_har%TYPE,
    p_positor IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.AC_förälder_AC_barn_PAT_har_Annex.Metadata_AC_förälder_AC_barn_PAT_har%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Positor%TYPE;
    v_positing ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_PositedAt%TYPE;
    v_reliability ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE;
    v_held ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_Reliability%TYPE;
    v_posit ties.AC_förälder_AC_barn_PAT_har_Posit.AC_förälder_AC_barn_PAT_har_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.AC_förälder_AC_barn_PAT_har_Annex.AC_förälder_AC_barn_PAT_har_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Annex (
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Reliability
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
                    ties.AC_förälder_AC_barn_PAT_har_Annex a
                WHERE
                    a.AC_förälder_AC_barn_PAT_har_ID = p_id
                AND
                    a.AC_förälder_AC_barn_PAT_har_Positor = v_positor
                AND
                    a.AC_förälder_AC_barn_PAT_har_PositedAt = v_positing
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
            p.AC_förälder_AC_barn_PAT_har_ID
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Posit p
        WHERE
            p.AC_ID_förälder = p_AC_förälder
        AND
            p.AC_ID_barn = p_AC_barn
        AND
            p.PAT_ID_har = p_PAT_har
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.AC_förälder_AC_barn_PAT_har_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.AC_förälder_AC_barn_PAT_har_Annex a
                WHERE
                    a.AC_förälder_AC_barn_PAT_har_ID = v_posit
                AND
                    a.AC_förälder_AC_barn_PAT_har_Positor = v_positor
                AND
                    a.AC_förälder_AC_barn_PAT_har_PositedAt = v_positing
                AND
                    a.AC_förälder_AC_barn_PAT_har_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in AC_förälder_AC_barn_PAT_har for: ' ||
                p_AC_förälder || ', ' ||
                p_AC_barn || ', ' ||
                p_PAT_har || ', ' ||
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
                    ties.AC_förälder_AC_barn_PAT_har_Annex a
                WHERE
                    a.AC_förälder_AC_barn_PAT_har_ID = v_posit
                AND
                    a.AC_förälder_AC_barn_PAT_har_Positor = v_positor
                AND
                    a.AC_förälder_AC_barn_PAT_har_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_AC_förälder_AC_barn_PAT_har(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Annex (
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Reliability
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
        INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Posit (
            AC_ID_förälder,
            AC_ID_barn,
            PAT_ID_har
        )
        VALUES (
            p_AC_förälder,
            p_AC_barn,
            p_PAT_har
        )
        RETURNING AC_förälder_AC_barn_PAT_har_ID INTO v_posit;
    END IF;
    INSERT INTO ties.AC_förälder_AC_barn_PAT_har_Annex (
        Metadata_AC_förälder_AC_barn_PAT_har,
        AC_förälder_AC_barn_PAT_har_ID,
        AC_förälder_AC_barn_PAT_har_Positor,
        AC_förälder_AC_barn_PAT_har_PositedAt,
        AC_förälder_AC_barn_PAT_har_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_AC_förälder_AC_barn_PAT_har;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_förälder_AC_barn_PAT_har instead of INSERT trigger on AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_AC_förälder_AC_barn_PAT_har
INSTEAD OF INSERT ON ties.AC_förälder_AC_barn_PAT_har
FOR EACH ROW
BEGIN
    ties.ip_AC_förälder_AC_barn_PAT_har(
        p_AC_förälder => :NEW.AC_ID_förälder,
        p_AC_barn => :NEW.AC_ID_barn,
        p_PAT_har => :NEW.PAT_ID_har,
        p_positor => :NEW.AC_förälder_AC_barn_PAT_har_Positor,
        p_positing => :NEW.AC_förälder_AC_barn_PAT_har_PositedAt,
        p_reliability => :NEW.AC_förälder_AC_barn_PAT_har_Reliability,
        p_metadata => :NEW.Metadata_AC_förälder_AC_barn_PAT_har
    );
END it_AC_förälder_AC_barn_PAT_har;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lAC_förälder_AC_barn_PAT_har
INSTEAD OF INSERT ON ties.lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_PAT_har number(3);
BEGIN
    -- the identity of the knot value, given as it is or looked up from the value
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
        p_positor => COALESCE(:NEW.AC_förälder_AC_barn_PAT_har_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.AC_förälder_AC_barn_PAT_har_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.AC_förälder_AC_barn_PAT_har_Reliability, 1),
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
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_AC_förälder_AC_barn_PAT_har(
        p_AC_förälder => :OLD.AC_ID_förälder,
        p_AC_barn => :OLD.AC_ID_barn,
        p_PAT_har => :OLD.PAT_ID_har,
        p_positor => COALESCE(:OLD.AC_förälder_AC_barn_PAT_har_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_AC_förälder_AC_barn_PAT_har
    );
END dt_lAC_förälder_AC_barn_PAT_har;
/
-- Held -----------------------------------------------------------------------------------------------------------------
-- he_PR_innehåll_ST_plats_EV_of is the reliability that a positor holds for a posit at a positing time (null if it holds nothing): that of its
-- latest annex row up to then
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.he_PR_innehåll_ST_plats_EV_of (
    p_id IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_ID%TYPE,
    p_positor IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE,
    p_positing IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE
) RETURN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE
IS
BEGIN
    FOR r IN (
        SELECT
            a.PR_innehåll_ST_plats_EV_of_Reliability
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Annex a
        WHERE
            a.PR_innehåll_ST_plats_EV_of_ID = p_id
        AND
            a.PR_innehåll_ST_plats_EV_of_Positor = p_positor
        AND
            a.PR_innehåll_ST_plats_EV_of_PositedAt <= p_positing
        ORDER BY
            a.PR_innehåll_ST_plats_EV_of_PositedAt DESC
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        RETURN r.PR_innehåll_ST_plats_EV_of_Reliability;
    END LOOP;
    RETURN NULL;
END he_PR_innehåll_ST_plats_EV_of;
/
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_innehåll_ST_plats_EV_of tells (1 or 0) whether a posit is in effect for a positor at a positing time: it holds an assertion of it,
-- positive or negative
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.ie_PR_innehåll_ST_plats_EV_of (
    p_id IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_ID%TYPE,
    p_positor IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE,
    p_positing IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE
) RETURN NUMBER
IS
BEGIN
    IF COALESCE(ties.he_PR_innehåll_ST_plats_EV_of(p_id, p_positor, p_positing), 0) <> 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END ie_PR_innehåll_ST_plats_EV_of;
/
-- Insert procedure ---------------------------------------------------------------------------------------------------
-- ip_PR_innehåll_ST_plats_EV_of states a posit of PR_innehåll_ST_plats_EV_of, and what a positor holds of it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ties.ip_PR_innehåll_ST_plats_EV_of (
    p_PR_innehåll IN ties.PR_innehåll_ST_plats_EV_of_Posit.PR_ID_innehåll%TYPE,
    p_ST_plats IN ties.PR_innehåll_ST_plats_EV_of_Posit.ST_ID_plats%TYPE,
    p_EV_of IN ties.PR_innehåll_ST_plats_EV_of_Posit.EV_ID_of%TYPE,
    p_changing IN ties.PR_innehåll_ST_plats_EV_of_Posit.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE DEFAULT NULL,
    p_positor IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE DEFAULT NULL,
    p_positing IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE DEFAULT NULL,
    p_reliability IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE DEFAULT NULL,
    p_metadata IN ties.PR_innehåll_ST_plats_EV_of_Annex.Metadata_PR_innehåll_ST_plats_EV_of%TYPE DEFAULT NULL
)
IS
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
    v_positor ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Positor%TYPE;
    v_positing ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_PositedAt%TYPE;
    v_reliability ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE;
    v_held ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_Reliability%TYPE;
    v_changing ties.PR_innehåll_ST_plats_EV_of_Posit.PR_innehåll_ST_plats_EV_of_ChangedAt%TYPE;
    v_posit ties.PR_innehåll_ST_plats_EV_of_Posit.PR_innehåll_ST_plats_EV_of_ID%TYPE;
    v_exists NUMBER;
    v_sign NUMBER;
    v_total NUMBER;
    -- retracts a posit for the positor at the positing time, unless that is stated there already
    PROCEDURE retract (
        p_id IN ties.PR_innehåll_ST_plats_EV_of_Annex.PR_innehåll_ST_plats_EV_of_ID%TYPE
    )
    IS
    BEGIN
        INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Annex (
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Reliability
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
                    ties.PR_innehåll_ST_plats_EV_of_Annex a
                WHERE
                    a.PR_innehåll_ST_plats_EV_of_ID = p_id
                AND
                    a.PR_innehåll_ST_plats_EV_of_Positor = v_positor
                AND
                    a.PR_innehåll_ST_plats_EV_of_PositedAt = v_positing
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
            p.PR_innehåll_ST_plats_EV_of_ID
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Posit p
        WHERE
            p.PR_ID_innehåll = p_PR_innehåll
        AND
            p.ST_ID_plats = p_ST_plats
        AND
            p.EV_ID_of = p_EV_of
        AND
            p.PR_innehåll_ST_plats_EV_of_ChangedAt = v_changing
        FETCH FIRST 1 ROW ONLY
    ) LOOP
        v_posit := r.PR_innehåll_ST_plats_EV_of_ID;
    END LOOP;
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    IF v_posit IS NOT NULL THEN
        SELECT
            CASE WHEN EXISTS (
                SELECT
                    1
                FROM
                    ties.PR_innehåll_ST_plats_EV_of_Annex a
                WHERE
                    a.PR_innehåll_ST_plats_EV_of_ID = v_posit
                AND
                    a.PR_innehåll_ST_plats_EV_of_Positor = v_positor
                AND
                    a.PR_innehåll_ST_plats_EV_of_PositedAt = v_positing
                AND
                    a.PR_innehåll_ST_plats_EV_of_Reliability <> v_reliability
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Contradiction in PR_innehåll_ST_plats_EV_of for: ' ||
                p_PR_innehåll || ', ' ||
                p_ST_plats || ', ' ||
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
                    ties.PR_innehåll_ST_plats_EV_of_Annex a
                WHERE
                    a.PR_innehåll_ST_plats_EV_of_ID = v_posit
                AND
                    a.PR_innehåll_ST_plats_EV_of_Positor = v_positor
                AND
                    a.PR_innehåll_ST_plats_EV_of_PositedAt = v_positing
            ) THEN 1 ELSE 0 END
        INTO
            v_exists
        FROM
            dual;
        IF v_exists = 1 THEN
            RETURN;
        END IF;
        -- what the positor holds of the posit
        v_held := ties.he_PR_innehåll_ST_plats_EV_of(v_posit, v_positor, v_positing);
    END IF;
    IF v_reliability = 0 THEN
        -- a retraction of what the positor does not hold states nothing
        IF COALESCE(v_held, 0) = 0 THEN
            RETURN;
        END IF;
        INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Annex (
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Reliability
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
        INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Posit (
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt
        )
        VALUES (
            p_PR_innehåll,
            p_ST_plats,
            p_EV_of,
            v_changing
        )
        RETURNING PR_innehåll_ST_plats_EV_of_ID INTO v_posit;
    END IF;
    INSERT INTO ties.PR_innehåll_ST_plats_EV_of_Annex (
        Metadata_PR_innehåll_ST_plats_EV_of,
        PR_innehåll_ST_plats_EV_of_ID,
        PR_innehåll_ST_plats_EV_of_Positor,
        PR_innehåll_ST_plats_EV_of_PositedAt,
        PR_innehåll_ST_plats_EV_of_Reliability
    )
    VALUES (
        COALESCE(p_metadata, 0),
        v_posit,
        v_positor,
        v_positing,
        v_reliability
    );
END ip_PR_innehåll_ST_plats_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_innehåll_ST_plats_EV_of instead of INSERT trigger on PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_PR_innehåll_ST_plats_EV_of
INSTEAD OF INSERT ON ties.PR_innehåll_ST_plats_EV_of
FOR EACH ROW
BEGIN
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :NEW.PR_ID_innehåll,
        p_ST_plats => :NEW.ST_ID_plats,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt,
        p_positor => :NEW.PR_innehåll_ST_plats_EV_of_Positor,
        p_positing => :NEW.PR_innehåll_ST_plats_EV_of_PositedAt,
        p_reliability => :NEW.PR_innehåll_ST_plats_EV_of_Reliability,
        p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
    );
END it_PR_innehåll_ST_plats_EV_of;
/
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.it_lPR_innehåll_ST_plats_EV_of
INSTEAD OF INSERT ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :NEW.PR_ID_innehåll,
        p_ST_plats => :NEW.ST_ID_plats,
        p_EV_of => :NEW.EV_ID_of,
        p_changing => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt, v_now),
        p_positor => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_Positor, :NEW.Positor, 0),
        p_positing => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_PositedAt, v_now),
        p_reliability => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_Reliability, 1),
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
    v_positing timestamp;
    v_positor number(3);
BEGIN
    v_positor := COALESCE(CASE
        WHEN (:NEW.PR_innehåll_ST_plats_EV_of_Positor <> :OLD.PR_innehåll_ST_plats_EV_of_Positor
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Positor IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Positor IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Positor IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Positor IS NULL))
        THEN :NEW.PR_innehåll_ST_plats_EV_of_Positor
        ELSE :NEW.Positor
    END, 0);
    v_positing := CASE
        WHEN (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt <> :OLD.PR_innehåll_ST_plats_EV_of_PositedAt
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL))
        THEN :NEW.PR_innehåll_ST_plats_EV_of_PositedAt
        ELSE v_now
    END;
    IF
        (:NEW.PR_ID_innehåll <> :OLD.PR_ID_innehåll
            OR (:NEW.PR_ID_innehåll IS NULL AND :OLD.PR_ID_innehåll IS NOT NULL)
            OR (:NEW.PR_ID_innehåll IS NOT NULL AND :OLD.PR_ID_innehåll IS NULL)) OR
        (:NEW.ST_ID_plats <> :OLD.ST_ID_plats
            OR (:NEW.ST_ID_plats IS NULL AND :OLD.ST_ID_plats IS NOT NULL)
            OR (:NEW.ST_ID_plats IS NOT NULL AND :OLD.ST_ID_plats IS NULL)) OR
        (:NEW.EV_ID_of <> :OLD.EV_ID_of
            OR (:NEW.EV_ID_of IS NULL AND :OLD.EV_ID_of IS NOT NULL)
            OR (:NEW.EV_ID_of IS NOT NULL AND :OLD.EV_ID_of IS NULL)) OR
        (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt <> :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
            OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL)) OR
        (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt <> :OLD.PR_innehåll_ST_plats_EV_of_PositedAt
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_PositedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_PositedAt IS NULL)) OR
        (:NEW.PR_innehåll_ST_plats_EV_of_Reliability <> :OLD.PR_innehåll_ST_plats_EV_of_Reliability
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Reliability IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Reliability IS NOT NULL)
            OR (:NEW.PR_innehåll_ST_plats_EV_of_Reliability IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_Reliability IS NULL))
    THEN
        IF
            :NEW.PR_ID_innehåll IS NOT NULL
        AND
            :NEW.ST_ID_plats IS NOT NULL
        AND
            :NEW.EV_ID_of IS NOT NULL
        THEN
            ties.ip_PR_innehåll_ST_plats_EV_of(
                p_PR_innehåll => :NEW.PR_ID_innehåll,
                p_ST_plats => :NEW.ST_ID_plats,
                p_EV_of => :NEW.EV_ID_of,
                -- the shown version asserted again keeps its changing time, as does one that is given
                p_changing => CASE
                    WHEN (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt <> :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt
                        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL)
                        OR (:NEW.PR_innehåll_ST_plats_EV_of_ChangedAt IS NOT NULL AND :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL))
                    THEN :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt
                    WHEN
                        :NEW.PR_ID_innehåll = :OLD.PR_ID_innehåll
                    AND
                        :NEW.ST_ID_plats = :OLD.ST_ID_plats
                    AND
                        :NEW.EV_ID_of = :OLD.EV_ID_of
                    THEN :NEW.PR_innehåll_ST_plats_EV_of_ChangedAt
                    ELSE v_now
                END,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => COALESCE(:NEW.PR_innehåll_ST_plats_EV_of_Reliability, 1),
                p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            ties.ip_PR_innehåll_ST_plats_EV_of(
                p_PR_innehåll => :OLD.PR_ID_innehåll,
                p_ST_plats => :OLD.ST_ID_plats,
                p_EV_of => :OLD.EV_ID_of,
                p_changing => :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt,
                p_positor => v_positor,
                p_positing => v_positing,
                p_reliability => 0,
                p_metadata => :NEW.Metadata_PR_innehåll_ST_plats_EV_of
            );
        END IF;
    END IF;
END ut_lPR_innehåll_ST_plats_EV_of;
/
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER ties.dt_lPR_innehåll_ST_plats_EV_of
INSTEAD OF DELETE ON ties.lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    v_now timestamp(9) := CAST(current_timestamp AS timestamp(9));
BEGIN
    -- what is shown is retracted
    ties.ip_PR_innehåll_ST_plats_EV_of(
        p_PR_innehåll => :OLD.PR_ID_innehåll,
        p_ST_plats => :OLD.ST_ID_plats,
        p_EV_of => :OLD.EV_ID_of,
        p_changing => :OLD.PR_innehåll_ST_plats_EV_of_ChangedAt,
        p_positor => COALESCE(:OLD.PR_innehåll_ST_plats_EV_of_Positor, :OLD.Positor, 0),
        p_positing => v_now,
        p_reliability => 0,
        p_metadata => :OLD.Metadata_PR_innehåll_ST_plats_EV_of
    );
END dt_lPR_innehåll_ST_plats_EV_of;
/
