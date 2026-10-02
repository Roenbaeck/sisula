-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.EV_Event (
    EV_ID int IDENTITY(1,1) not null, 
    ST_ID_wasHeldAt int not null, 
    PR_ID_wasPlayed int not null, 
    ETY_ID_of tinyint not null,
    constraint EV_Event_fkST_wasHeldAt foreign key (
        ST_ID_wasHeldAt
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint EV_Event_fkPR_wasPlayed foreign key (
        PR_ID_wasPlayed
    ) references public.PR_Program(PR_ID) RELY, 
    constraint EV_Event_fkETY_of foreign key (
        ETY_ID_of
    ) references public.ETY_EventType(ETY_ID) RELY,
    EV_Dummy boolean null,
    constraint pkEV_Event primary key (
        EV_ID
    ) RELY
) CLUSTER BY (EV_ID);
