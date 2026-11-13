-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
CREATE OR REPLACE TRIGGER itAC_partner_AC_with_ONG_currently
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED KNOTTED 
    INSERT INTO AC_partner_AC_with_ONG_currently (
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_current,
        Metadata_AC_partner_AC_with_ON
    ) VALUES (
        :NEW.AC_ID_partner,
        :NEW.AC_ID_with,
        (select a.ONG_ID from ONG_Ongoing a where a.ONG_Ongoing = :NEW.currently_ONG_Ongoing), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_partner_AC_with_ONG_current,l_now),
        :NEW.Metadata_AC_partner_AC_with_ON
    );
END itAC_partner_AC_with_ONG_currently;
/

CREATE OR REPLACE TRIGGER utAC_partner_AC_with_ONG_currently
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
BEGIN

 -- HISTORIZED KNOTTED 
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.AC_ID_partner, :OLD.AC_ID_partner) then
        raise_application_error(-20001, 'Relationskolumnen AC_partner_AC_with_ONG_currently.AC_ID_partner får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.AC_ID_with, :OLD.AC_ID_with) then
        raise_application_error(-20001, 'Relationskolumnen AC_partner_AC_with_ONG_currently.AC_ID_with får ej uppdateras');
    end if;
    INSERT INTO AC_partner_AC_with_ONG_currently (
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_current,
        Metadata_AC_partner_AC_with_ON
    ) VALUES (
        :NEW.AC_ID_partner,
        :NEW.AC_ID_with,
        (select a.ONG_ID from ONG_Ongoing a where a.ONG_Ongoing = :NEW.currently_ONG_Ongoing), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_partner_AC_with_ONG_current,l_now),
        :NEW.Metadata_AC_partner_AC_with_ON
    );
END utAC_partner_AC_with_ONG_currently;
/

CREATE OR REPLACE TRIGGER dtAC_partner_AC_with_ONG_currently
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_partner_AC_with_ONG_currently
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_partner_AC_with_ONG_currently WHERE 1=1
    AND AC_partner_AC_with_ONG_current = :NEW.AC_partner_AC_with_ONG_current
    AND (
            AC_ID_partner = :NEW.AC_ID_partner
        OR
            AC_ID_with = :NEW.AC_ID_with
        OR
            ONG_ID_currently = :NEW.ONG_ID_currently
    );
END dtAC_partner_AC_with_ONG_currently;
/
CREATE OR REPLACE TRIGGER itAC_subset_PN_of
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_subset_PN_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO AC_subset_PN_of (
        AC_ID_subset,
        PN_ID_of,

        Metadata_AC_subset_PN_of
    ) VALUES (
        :NEW.AC_ID_subset,
        :NEW.PN_ID_of,

        :NEW.Metadata_AC_subset_PN_of
    );
END itAC_subset_PN_of;
/

CREATE OR REPLACE TRIGGER dtAC_subset_PN_of
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_subset_PN_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_subset_PN_of WHERE 1=1
    AND (
            AC_ID_subset = :NEW.AC_ID_subset
        OR
            PN_ID_of = :NEW.PN_ID_of
    );
END dtAC_subset_PN_of;
/
CREATE OR REPLACE TRIGGER itEV_in_AC_wasCast
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO EV_in_AC_wasCast (
        EV_ID_in,
        AC_ID_wasCast,

        Metadata_EV_in_AC_wasCast
    ) VALUES (
        :NEW.EV_ID_in,
        :NEW.AC_ID_wasCast,

        :NEW.Metadata_EV_in_AC_wasCast
    );
END itEV_in_AC_wasCast;
/

CREATE OR REPLACE TRIGGER dtEV_in_AC_wasCast
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lEV_in_AC_wasCast
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE EV_in_AC_wasCast WHERE 1=1
    AND EV_ID_in = :NEW.EV_ID_in
    AND AC_ID_wasCast = :NEW.AC_ID_wasCast
    ;
END dtEV_in_AC_wasCast;
/
CREATE OR REPLACE TRIGGER itAC_part_PR_in_RAT_got
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED KNOTTED 
    INSERT INTO AC_part_PR_in_RAT_got (
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedA,
        Metadata_AC_part_PR_in_RAT_got
    ) VALUES (
        :NEW.AC_ID_part,
        :NEW.PR_ID_in,
        (select a.RAT_ID from RAT_Rating a where a.RAT_Rating = :NEW.got_RAT_Rating), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_part_PR_in_RAT_got_ChangedA,l_now),
        :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END itAC_part_PR_in_RAT_got;
/

CREATE OR REPLACE TRIGGER utAC_part_PR_in_RAT_got
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
    -- är kolumnen förändrad, OBS tar hänsyn till NULL
    function is_changed ( in_new varchar2, in_old varchar2) return boolean is
    begin
        -- Denna if är något bakvänt skriven för att ta hand om fallen där NEW eller OLD är NULL.
        -- Svaret på detta är varken true eller false vilket gör att även dessa hamnar i else
        if (in_old = in_new) OR (in_old is null and in_new is null) then
            -- FALSE
            return false;
        else
            -- TRUE
            return true;
        end if;
    end is_changed;
BEGIN

 -- HISTORIZED KNOTTED 
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.AC_ID_part, :OLD.AC_ID_part) then
        raise_application_error(-20001, 'Relationskolumnen AC_part_PR_in_RAT_got.AC_ID_part får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.PR_ID_in, :OLD.PR_ID_in) then
        raise_application_error(-20001, 'Relationskolumnen AC_part_PR_in_RAT_got.PR_ID_in får ej uppdateras');
    end if;
    INSERT INTO AC_part_PR_in_RAT_got (
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedA,
        Metadata_AC_part_PR_in_RAT_got
    ) VALUES (
        :NEW.AC_ID_part,
        :NEW.PR_ID_in,
        (select a.RAT_ID from RAT_Rating a where a.RAT_Rating = :NEW.got_RAT_Rating), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_part_PR_in_RAT_got_ChangedA,l_now),
        :NEW.Metadata_AC_part_PR_in_RAT_got
    );
END utAC_part_PR_in_RAT_got;
/

CREATE OR REPLACE TRIGGER dtAC_part_PR_in_RAT_got
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_part_PR_in_RAT_got
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_part_PR_in_RAT_got WHERE 1=1
    AND AC_part_PR_in_RAT_got_ChangedA = :NEW.AC_part_PR_in_RAT_got_ChangedA
    AND AC_ID_part = :NEW.AC_ID_part
    AND PR_ID_in = :NEW.PR_ID_in
    ;
END dtAC_part_PR_in_RAT_got;
/
CREATE OR REPLACE TRIGGER itST_at_PR_isPlaying
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED NOT KNOTTED 
    INSERT INTO ST_at_PR_isPlaying (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        Metadata_ST_at_PR_isPlaying
    ) VALUES (
        :NEW.ST_ID_at,
        :NEW.PR_ID_isPlaying,
        NVL(:NEW.ST_at_PR_isPlaying_ChangedAt,l_now),
        :NEW.Metadata_ST_at_PR_isPlaying
    );
END itST_at_PR_isPlaying;
/

CREATE OR REPLACE TRIGGER dtST_at_PR_isPlaying
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lST_at_PR_isPlaying
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE ST_at_PR_isPlaying WHERE 1=1
    AND ST_at_PR_isPlaying_ChangedAt = :NEW.ST_at_PR_isPlaying_ChangedAt
    AND ST_ID_at = :NEW.ST_ID_at
    AND PR_ID_isPlaying = :NEW.PR_ID_isPlaying
    ;
END dtST_at_PR_isPlaying;
/
CREATE OR REPLACE TRIGGER itAC_parent_AC_child_PAT_having
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED KNOTTED 
    INSERT INTO AC_parent_AC_child_PAT_having (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having,

        Metadata_AC_parent_AC_child_PA
    ) VALUES (
        :NEW.AC_ID_parent,
        :NEW.AC_ID_child,
        (select a.PAT_ID from PAT_ParentalType a where a.PAT_ParentalType = :NEW.having_PAT_ParentalType), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas

        :NEW.Metadata_AC_parent_AC_child_PA
    );
END itAC_parent_AC_child_PAT_having;
/

CREATE OR REPLACE TRIGGER dtAC_parent_AC_child_PAT_having
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_parent_AC_child_PAT_having
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_parent_AC_child_PAT_having WHERE 1=1
    AND AC_ID_parent = :NEW.AC_ID_parent
    AND AC_ID_child = :NEW.AC_ID_child
    AND PAT_ID_having = :NEW.PAT_ID_having
    ;
END dtAC_parent_AC_child_PAT_having;
/
CREATE OR REPLACE TRIGGER itPR_content_ST_location_EV_of
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO PR_content_ST_location_EV_of (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,

        Metadata_PR_content_ST_locatio
    ) VALUES (
        :NEW.PR_ID_content,
        :NEW.ST_ID_location,
        :NEW.EV_ID_of,

        :NEW.Metadata_PR_content_ST_locatio
    );
END itPR_content_ST_location_EV_of;
/

CREATE OR REPLACE TRIGGER dtPR_content_ST_location_EV_of
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lPR_content_ST_location_EV_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE PR_content_ST_location_EV_of WHERE 1=1
    AND EV_ID_of = :NEW.EV_ID_of
    ;
END dtPR_content_ST_location_EV_of;
/
