-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Posit (
    AC_partner_AC_with_ONG_currently_ID int IDENTITY(1,1) not null, 
    AC_ID_partner int not null, 
    AC_ID_with int not null, 
    ONG_ID_currently tinyint not null,
    AC_partner_AC_with_ONG_currently_ChangedAt datetime not null,
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_partner foreign key (
        AC_ID_partner
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_Posit_fkAC_with foreign key (
        AC_ID_with
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_partner_AC_with_ONG_currently_Posit_fkONG_currently foreign key (
        ONG_ID_currently
    ) references public.ONG_Ongoing(ONG_ID) RELY,
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_partner unique (
        AC_ID_partner,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint AC_partner_AC_with_ONG_currently_Posit_uqAC_with unique (
        AC_ID_with,
        AC_partner_AC_with_ONG_currently_ChangedAt
    ) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Posit primary key (
        AC_partner_AC_with_ONG_currently_ID
    ) RELY,
    constraint uqAC_partner_AC_with_ONG_currently unique (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    ) RELY
) CLUSTER BY (
    AC_partner_AC_with_ONG_currently_ChangedAt
);
CREATE TABLE IF NOT EXISTS public.AC_partner_AC_with_ONG_currently_Annex (
    AC_partner_AC_with_ONG_currently_ID int not null,
    AC_partner_AC_with_ONG_currently_PositedAt datetime not null,
    AC_partner_AC_with_ONG_currently_Positor tinyint not null,
    AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
    AC_partner_AC_with_ONG_currently_Assertion string default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
            when AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when AC_partner_AC_with_ONG_currently_Reliability < then 0
            else 1
        end
    ),
    constraint fkAC_partner_AC_with_ONG_currently_Annex foreign key (
        AC_partner_AC_with_ONG_currently_ID
    ) references public.AC_partner_AC_with_ONG_currently_Posit(AC_partner_AC_with_ONG_currently_ID) RELY,
    constraint pkAC_partner_AC_with_ONG_currently_Annex primary key (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt
    ) RELY
) CLUSTER BY (AC_partner_AC_with_ONG_currently_ID, AC_partner_AC_with_ONG_currently_Positor, AC_partner_AC_with_ONG_currently_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Posit (
    AC_subset_PN_of_ID int IDENTITY(1,1) not null, 
    AC_ID_subset int not null, 
    PN_ID_of int not null, 
    constraint AC_subset_PN_of_Posit_fkAC_subset foreign key (
        AC_ID_subset
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_subset_PN_of_Posit_fkPN_of foreign key (
        PN_ID_of
    ) references public.PN_Person(PN_ID) RELY, 
    constraint AC_subset_PN_of_Posit_uqAC_subset unique (
        AC_ID_subset
    ) RELY,
    constraint AC_subset_PN_of_Posit_uqPN_of unique (
        PN_ID_of
    ) RELY,
    constraint pkAC_subset_PN_of_Posit primary key (
        AC_subset_PN_of_ID
    ) RELY,
    constraint uqAC_subset_PN_of unique (
        AC_ID_subset,
        PN_ID_of
    ) RELY
) CLUSTER BY (
);
CREATE TABLE IF NOT EXISTS public.AC_subset_PN_of_Annex (
    AC_subset_PN_of_ID int not null,
    AC_subset_PN_of_PositedAt datetime not null,
    AC_subset_PN_of_Positor tinyint not null,
    AC_subset_PN_of_Reliability decimal(5,2) not null,
    AC_subset_PN_of_Assertion string default (
        case
            when AC_subset_PN_of_Reliability > 0 then '+'
            when AC_subset_PN_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when AC_subset_PN_of_Reliability < then 0
            else 1
        end
    ),
    constraint fkAC_subset_PN_of_Annex foreign key (
        AC_subset_PN_of_ID
    ) references public.AC_subset_PN_of_Posit(AC_subset_PN_of_ID) RELY,
    constraint pkAC_subset_PN_of_Annex primary key (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt
    ) RELY
) CLUSTER BY (AC_subset_PN_of_ID, AC_subset_PN_of_Positor, AC_subset_PN_of_PositedAt);
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Posit (
    EV_in_AC_wasCast_ID int IDENTITY(1,1) not null, 
    EV_ID_in int not null, 
    AC_ID_wasCast int not null, 
    constraint EV_in_AC_wasCast_Posit_fkEV_in foreign key (
        EV_ID_in
    ) references public.EV_Event(EV_ID) RELY, 
    constraint EV_in_AC_wasCast_Posit_fkAC_wasCast foreign key (
        AC_ID_wasCast
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint pkEV_in_AC_wasCast_Posit primary key (
        EV_in_AC_wasCast_ID
    ) RELY,
    constraint uqEV_in_AC_wasCast unique (
        EV_ID_in,
        AC_ID_wasCast
    ) RELY
) CLUSTER BY (
    EV_ID_in,
    AC_ID_wasCast
);
CREATE TABLE IF NOT EXISTS public.EV_in_AC_wasCast_Annex (
    EV_in_AC_wasCast_ID int not null,
    EV_in_AC_wasCast_PositedAt datetime not null,
    EV_in_AC_wasCast_Positor tinyint not null,
    EV_in_AC_wasCast_Reliability decimal(5,2) not null,
    EV_in_AC_wasCast_Assertion string default (
        case
            when EV_in_AC_wasCast_Reliability > 0 then '+'
            when EV_in_AC_wasCast_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when EV_in_AC_wasCast_Reliability < then 0
            else 1
        end
    ),
    constraint fkEV_in_AC_wasCast_Annex foreign key (
        EV_in_AC_wasCast_ID
    ) references public.EV_in_AC_wasCast_Posit(EV_in_AC_wasCast_ID) RELY,
    constraint pkEV_in_AC_wasCast_Annex primary key (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt
    ) RELY
) CLUSTER BY (EV_in_AC_wasCast_ID, EV_in_AC_wasCast_Positor, EV_in_AC_wasCast_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Posit (
    AC_part_PR_in_RAT_got_ID int IDENTITY(1,1) not null, 
    AC_ID_part int not null, 
    PR_ID_in int not null, 
    RAT_ID_got tinyint not null,
    AC_part_PR_in_RAT_got_ChangedAt datetime not null,
    constraint AC_part_PR_in_RAT_got_Posit_fkAC_part foreign key (
        AC_ID_part
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_Posit_fkPR_in foreign key (
        PR_ID_in
    ) references public.PR_Program(PR_ID) RELY, 
    constraint AC_part_PR_in_RAT_got_Posit_fkRAT_got foreign key (
        RAT_ID_got
    ) references public.RAT_Rating(RAT_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Posit primary key (
        AC_part_PR_in_RAT_got_ID
    ) RELY,
    constraint uqAC_part_PR_in_RAT_got unique (
        AC_ID_part,
        PR_ID_in,
        AC_part_PR_in_RAT_got_ChangedAt,
        RAT_ID_got
    ) RELY
) CLUSTER BY (
    AC_ID_part,
    PR_ID_in,
    AC_part_PR_in_RAT_got_ChangedAt
);
CREATE TABLE IF NOT EXISTS public.AC_part_PR_in_RAT_got_Annex (
    AC_part_PR_in_RAT_got_ID int not null,
    AC_part_PR_in_RAT_got_PositedAt datetime not null,
    AC_part_PR_in_RAT_got_Positor tinyint not null,
    AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
    AC_part_PR_in_RAT_got_Assertion string default (
        case
            when AC_part_PR_in_RAT_got_Reliability > 0 then '+'
            when AC_part_PR_in_RAT_got_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when AC_part_PR_in_RAT_got_Reliability < then 0
            else 1
        end
    ),
    constraint fkAC_part_PR_in_RAT_got_Annex foreign key (
        AC_part_PR_in_RAT_got_ID
    ) references public.AC_part_PR_in_RAT_got_Posit(AC_part_PR_in_RAT_got_ID) RELY,
    constraint pkAC_part_PR_in_RAT_got_Annex primary key (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt
    ) RELY
) CLUSTER BY (AC_part_PR_in_RAT_got_ID, AC_part_PR_in_RAT_got_Positor, AC_part_PR_in_RAT_got_PositedAt);
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Posit (
    ST_at_PR_isPlaying_ID int IDENTITY(1,1) not null, 
    ST_ID_at int not null, 
    PR_ID_isPlaying int not null, 
    ST_at_PR_isPlaying_ChangedAt datetime not null,
    constraint ST_at_PR_isPlaying_Posit_fkST_at foreign key (
        ST_ID_at
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint ST_at_PR_isPlaying_Posit_fkPR_isPlaying foreign key (
        PR_ID_isPlaying
    ) references public.PR_Program(PR_ID) RELY, 
    constraint pkST_at_PR_isPlaying_Posit primary key (
        ST_at_PR_isPlaying_ID
    ) RELY,
    constraint uqST_at_PR_isPlaying unique (
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    ) RELY
) CLUSTER BY (
    ST_ID_at,
    PR_ID_isPlaying,
    ST_at_PR_isPlaying_ChangedAt
);
CREATE TABLE IF NOT EXISTS public.ST_at_PR_isPlaying_Annex (
    ST_at_PR_isPlaying_ID int not null,
    ST_at_PR_isPlaying_PositedAt datetime not null,
    ST_at_PR_isPlaying_Positor tinyint not null,
    ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
    ST_at_PR_isPlaying_Assertion string default (
        case
            when ST_at_PR_isPlaying_Reliability > 0 then '+'
            when ST_at_PR_isPlaying_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when ST_at_PR_isPlaying_Reliability < then 0
            else 1
        end
    ),
    constraint fkST_at_PR_isPlaying_Annex foreign key (
        ST_at_PR_isPlaying_ID
    ) references public.ST_at_PR_isPlaying_Posit(ST_at_PR_isPlaying_ID) RELY,
    constraint pkST_at_PR_isPlaying_Annex primary key (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt
    ) RELY
) CLUSTER BY (ST_at_PR_isPlaying_ID, ST_at_PR_isPlaying_Positor, ST_at_PR_isPlaying_PositedAt);
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Posit (
    AC_parent_AC_child_PAT_having_ID int IDENTITY(1,1) not null, 
    AC_ID_parent int not null, 
    AC_ID_child int not null, 
    PAT_ID_having tinyint not null,
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_parent foreign key (
        AC_ID_parent
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_Posit_fkAC_child foreign key (
        AC_ID_child
    ) references public.AC_Actor(AC_ID) RELY, 
    constraint AC_parent_AC_child_PAT_having_Posit_fkPAT_having foreign key (
        PAT_ID_having
    ) references public.PAT_ParentalType(PAT_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Posit primary key (
        AC_parent_AC_child_PAT_having_ID
    ) RELY,
    constraint uqAC_parent_AC_child_PAT_having unique (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    ) RELY
) CLUSTER BY (
    AC_ID_parent,
    AC_ID_child,
    PAT_ID_having
);
CREATE TABLE IF NOT EXISTS public.AC_parent_AC_child_PAT_having_Annex (
    AC_parent_AC_child_PAT_having_ID int not null,
    AC_parent_AC_child_PAT_having_PositedAt datetime not null,
    AC_parent_AC_child_PAT_having_Positor tinyint not null,
    AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
    AC_parent_AC_child_PAT_having_Assertion string default (
        case
            when AC_parent_AC_child_PAT_having_Reliability > 0 then '+'
            when AC_parent_AC_child_PAT_having_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when AC_parent_AC_child_PAT_having_Reliability < then 0
            else 1
        end
    ),
    constraint fkAC_parent_AC_child_PAT_having_Annex foreign key (
        AC_parent_AC_child_PAT_having_ID
    ) references public.AC_parent_AC_child_PAT_having_Posit(AC_parent_AC_child_PAT_having_ID) RELY,
    constraint pkAC_parent_AC_child_PAT_having_Annex primary key (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt
    ) RELY
) CLUSTER BY (AC_parent_AC_child_PAT_having_ID, AC_parent_AC_child_PAT_having_Positor, AC_parent_AC_child_PAT_having_PositedAt);
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Posit (
    PR_content_ST_location_EV_of_ID int IDENTITY(1,1) not null, 
    PR_ID_content int not null, 
    ST_ID_location int not null, 
    EV_ID_of int not null, 
    constraint PR_content_ST_location_EV_of_Posit_fkPR_content foreign key (
        PR_ID_content
    ) references public.PR_Program(PR_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Posit_fkST_location foreign key (
        ST_ID_location
    ) references public.ST_Stage(ST_ID) RELY, 
    constraint PR_content_ST_location_EV_of_Posit_fkEV_of foreign key (
        EV_ID_of
    ) references public.EV_Event(EV_ID) RELY, 
    constraint pkPR_content_ST_location_EV_of_Posit primary key (
        PR_content_ST_location_EV_of_ID
    ) RELY,
    constraint uqPR_content_ST_location_EV_of unique (
        EV_ID_of,
        PR_ID_content,
        ST_ID_location
    ) RELY
) CLUSTER BY (
    EV_ID_of
);
CREATE TABLE IF NOT EXISTS public.PR_content_ST_location_EV_of_Annex (
    PR_content_ST_location_EV_of_ID int not null,
    PR_content_ST_location_EV_of_PositedAt datetime not null,
    PR_content_ST_location_EV_of_Positor tinyint not null,
    PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
    PR_content_ST_location_EV_of_Assertion string default (
        case
            when PR_content_ST_location_EV_of_Reliability > 0 then '+'
            when PR_content_ST_location_EV_of_Reliability = 0 then '?'
            else '-'
        end
    ),
     int default (
        case
            when PR_content_ST_location_EV_of_Reliability < then 0
            else 1
        end
    ),
    constraint fkPR_content_ST_location_EV_of_Annex foreign key (
        PR_content_ST_location_EV_of_ID
    ) references public.PR_content_ST_location_EV_of_Posit(PR_content_ST_location_EV_of_ID) RELY,
    constraint pkPR_content_ST_location_EV_of_Annex primary key (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt
    ) RELY
) CLUSTER BY (PR_content_ST_location_EV_of_ID, PR_content_ST_location_EV_of_Positor, PR_content_ST_location_EV_of_PositedAt);
