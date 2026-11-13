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
        (select a.ONG_ID from ONG_Pågående a where a.ONG_Pågående = :NEW.currently_ONG_Pågående), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
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
        (select a.ONG_ID from ONG_Pågående a where a.ONG_Pågående = :NEW.currently_ONG_Pågående), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
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
CREATE OR REPLACE TRIGGER itEV_in_AC_rollsattes
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lEV_in_AC_rollsattes
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED NOT KNOTTED 
    INSERT INTO EV_in_AC_rollsattes (
        EV_ID_in,
        AC_ID_rollsattes,

        Metadata_EV_in_AC_rollsattes
    ) VALUES (
        :NEW.EV_ID_in,
        :NEW.AC_ID_rollsattes,

        :NEW.Metadata_EV_in_AC_rollsattes
    );
END itEV_in_AC_rollsattes;
/

CREATE OR REPLACE TRIGGER dtEV_in_AC_rollsattes
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtEV_in_AC_rollsattes instead of DELETE trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lEV_in_AC_rollsattes
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE EV_in_AC_rollsattes WHERE 1=1
    AND EV_ID_in = :NEW.EV_ID_in
    AND AC_ID_rollsattes = :NEW.AC_ID_rollsattes
    ;
END dtEV_in_AC_rollsattes;
/
CREATE OR REPLACE TRIGGER itAC_deltar_PR_in_RAT_fick
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED KNOTTED 
    INSERT INTO AC_deltar_PR_in_RAT_fick (
        AC_ID_deltar,
        PR_ID_in,
        RAT_ID_fick,
        AC_deltar_PR_in_RAT_fick_Chang,
        Metadata_AC_deltar_PR_in_RAT_f
    ) VALUES (
        :NEW.AC_ID_deltar,
        :NEW.PR_ID_in,
        (select a.RAT_ID from RAT_Betyg a where a.RAT_Betyg = :NEW.fick_RAT_Betyg), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_deltar_PR_in_RAT_fick_Chang,l_now),
        :NEW.Metadata_AC_deltar_PR_in_RAT_f
    );
END itAC_deltar_PR_in_RAT_fick;
/

CREATE OR REPLACE TRIGGER utAC_deltar_PR_in_RAT_fick
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utAC_deltar_PR_in_RAT_fick instead of UPDATE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lAC_deltar_PR_in_RAT_fick
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
    if is_changed(:NEW.AC_ID_deltar, :OLD.AC_ID_deltar) then
        raise_application_error(-20001, 'Relationskolumnen AC_deltar_PR_in_RAT_fick.AC_ID_deltar får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.PR_ID_in, :OLD.PR_ID_in) then
        raise_application_error(-20001, 'Relationskolumnen AC_deltar_PR_in_RAT_fick.PR_ID_in får ej uppdateras');
    end if;
    INSERT INTO AC_deltar_PR_in_RAT_fick (
        AC_ID_deltar,
        PR_ID_in,
        RAT_ID_fick,
        AC_deltar_PR_in_RAT_fick_Chang,
        Metadata_AC_deltar_PR_in_RAT_f
    ) VALUES (
        :NEW.AC_ID_deltar,
        :NEW.PR_ID_in,
        (select a.RAT_ID from RAT_Betyg a where a.RAT_Betyg = :NEW.fick_RAT_Betyg), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas
        NVL(:NEW.AC_deltar_PR_in_RAT_fick_Chang,l_now),
        :NEW.Metadata_AC_deltar_PR_in_RAT_f
    );
END utAC_deltar_PR_in_RAT_fick;
/

CREATE OR REPLACE TRIGGER dtAC_deltar_PR_in_RAT_fick
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_deltar_PR_in_RAT_fick
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_deltar_PR_in_RAT_fick WHERE 1=1
    AND AC_deltar_PR_in_RAT_fick_Chang = :NEW.AC_deltar_PR_in_RAT_fick_Chang
    AND AC_ID_deltar = :NEW.AC_ID_deltar
    AND PR_ID_in = :NEW.PR_ID_in
    ;
END dtAC_deltar_PR_in_RAT_fick;
/
CREATE OR REPLACE TRIGGER itST_at_PR_spelas
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lST_at_PR_spelas
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED NOT KNOTTED 
    INSERT INTO ST_at_PR_spelas (
        ST_ID_at,
        PR_ID_spelas,
        ST_at_PR_spelas_ChangedAt,
        Metadata_ST_at_PR_spelas
    ) VALUES (
        :NEW.ST_ID_at,
        :NEW.PR_ID_spelas,
        NVL(:NEW.ST_at_PR_spelas_ChangedAt,l_now),
        :NEW.Metadata_ST_at_PR_spelas
    );
END itST_at_PR_spelas;
/

CREATE OR REPLACE TRIGGER dtST_at_PR_spelas
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtST_at_PR_spelas instead of DELETE trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lST_at_PR_spelas
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE ST_at_PR_spelas WHERE 1=1
    AND ST_at_PR_spelas_ChangedAt = :NEW.ST_at_PR_spelas_ChangedAt
    AND ST_ID_at = :NEW.ST_ID_at
    AND PR_ID_spelas = :NEW.PR_ID_spelas
    ;
END dtST_at_PR_spelas;
/
CREATE OR REPLACE TRIGGER itAC_förälder_AC_barn_PAT_har
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- NOT HISTORIZED KNOTTED 
    INSERT INTO AC_förälder_AC_barn_PAT_har (
        AC_ID_förälder,
        AC_ID_barn,
        PAT_ID_har,

        Metadata_AC_förälder_AC_barn_P
    ) VALUES (
        :NEW.AC_ID_förälder,
        :NEW.AC_ID_barn,
        (select a.PAT_ID from PAT_Föräldratyp a where a.PAT_Föräldratyp = :NEW.har_PAT_Föräldratyp), -- Denna kolumn har också ett konstraint till en KNOT och måste därför särbehandlas

        :NEW.Metadata_AC_förälder_AC_barn_P
    );
END itAC_förälder_AC_barn_PAT_har;
/

CREATE OR REPLACE TRIGGER dtAC_förälder_AC_barn_PAT_har
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtAC_förälder_AC_barn_PAT_har instead of DELETE trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lAC_förälder_AC_barn_PAT_har
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE AC_förälder_AC_barn_PAT_har WHERE 1=1
    AND AC_ID_förälder = :NEW.AC_ID_förälder
    AND AC_ID_barn = :NEW.AC_ID_barn
    AND PAT_ID_har = :NEW.PAT_ID_har
    ;
END dtAC_förälder_AC_barn_PAT_har;
/
CREATE OR REPLACE TRIGGER itPR_innehåll_ST_plats_EV_of
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF INSERT
ON lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
 -- HISTORIZED NOT KNOTTED 
    INSERT INTO PR_innehåll_ST_plats_EV_of (
        PR_ID_innehåll,
        ST_ID_plats,
        EV_ID_of,
        PR_innehåll_ST_plats_EV_of_Cha,
        Metadata_PR_innehåll_ST_plats_
    ) VALUES (
        :NEW.PR_ID_innehåll,
        :NEW.ST_ID_plats,
        :NEW.EV_ID_of,
        NVL(:NEW.PR_innehåll_ST_plats_EV_of_Cha,l_now),
        :NEW.Metadata_PR_innehåll_ST_plats_
    );
END itPR_innehåll_ST_plats_EV_of;
/

CREATE OR REPLACE TRIGGER utPR_innehåll_ST_plats_EV_of
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- utPR_innehåll_ST_plats_EV_of instead of UPDATE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF UPDATE
ON lPR_innehåll_ST_plats_EV_of
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

 -- HISTORIZED NOT KNOTTED 
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.PR_ID_innehåll, :OLD.PR_ID_innehåll) then
        raise_application_error(-20001, 'Relationskolumnen PR_innehåll_ST_plats_EV_of.PR_ID_innehåll får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.ST_ID_plats, :OLD.ST_ID_plats) then
        raise_application_error(-20001, 'Relationskolumnen PR_innehåll_ST_plats_EV_of.ST_ID_plats får ej uppdateras');
    end if;
    -- Relationskolumner får ej uppdateras
    if is_changed(:NEW.EV_ID_of, :OLD.EV_ID_of) then
        raise_application_error(-20001, 'Relationskolumnen PR_innehåll_ST_plats_EV_of.EV_ID_of får ej uppdateras');
    end if;
    INSERT INTO PR_innehåll_ST_plats_EV_of (
        PR_ID_innehåll,
        ST_ID_plats,
        EV_ID_of,
        PR_innehåll_ST_plats_EV_of_Cha,
        Metadata_PR_innehåll_ST_plats_
    ) VALUES (
        :NEW.PR_ID_innehåll,
        :NEW.ST_ID_plats,
        :NEW.EV_ID_of,
        NVL(:NEW.PR_innehåll_ST_plats_EV_of_Cha,l_now),
        :NEW.Metadata_PR_innehåll_ST_plats_
    );
END utPR_innehåll_ST_plats_EV_of;
/

CREATE OR REPLACE TRIGGER dtPR_innehåll_ST_plats_EV_of
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dtPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
INSTEAD OF DELETE
ON lPR_innehåll_ST_plats_EV_of
FOR EACH ROW
DECLARE
    x INTEGER;
    l_now   date := sysdate;
BEGIN
    DELETE PR_innehåll_ST_plats_EV_of WHERE 1=1
    AND PR_innehåll_ST_plats_EV_of_Cha = :NEW.PR_innehåll_ST_plats_EV_of_Cha
    AND (
            PR_ID_innehåll = :NEW.PR_ID_innehåll
        OR
            ST_ID_plats = :NEW.ST_ID_plats
        OR
            EV_ID_of = :NEW.EV_ID_of
    );
END dtPR_innehåll_ST_plats_EV_of;
/
