-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers. Views get their comments when they are
-- created, since Snowflake does not allow comments on view columns to be added afterwards.
--
COMMENT ON SCHEMA public IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE public.PAT_ParentalType_ID IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE public.GEN_Gender_ID IS 'Gender of an actor.';
COMMENT ON TABLE public.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN public.PLV_ProfessionalLevel.PLV_ProfessionalLevel IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE public.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN public.UTL_Utilization.UTL_Utilization IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE public.ONG_Ongoing_ID IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE public.RAT_Rating_ID IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON TABLE public.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public.ETY_EventType.ETY_EventType IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public.EV_DAT_Event_Date.EV_DAT_Event_Date IS 'Date and time when the event took place.';
COMMENT ON COLUMN public.EV_AUD_Event_Audience.EV_AUD_Event_Audience IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public.EV_REV_Event_Revenue.EV_REV_Event_Revenue IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public.ST_NAM_Stage_Name.ST_NAM_Stage_Name IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public.ST_LOC_Stage_Location.ST_LOC_Stage_Location IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public.ST_AVG_Stage_Average.ST_AVG_UTL_ID IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public.ST_MIN_Stage_Minimum.ST_MIN_UTL_ID IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public.AC_NAM_Actor_Name.AC_NAM_Actor_Name IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public.AC_GEN_Actor_Gender.AC_GEN_GEN_ID IS 'Gender of the actor.';
COMMENT ON COLUMN public.AC_PLV_Actor_ProfessionalLevel.AC_PLV_PLV_ID IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN public.PR_NAM_Program_Name.PR_NAM_Program_Name IS 'Name or title of the program.';
COMMENT ON COLUMN public.PR_LEN_Program_Length.PR_LEN_Program_Length IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE public.PN_Person IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE public.ST_Stage IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE public.AC_Actor IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE public.PR_Program IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE public.EV_Event IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN public.EV_Event.ST_ID_wasHeldAt IS 'The stage at which the event was held.';
COMMENT ON COLUMN public.EV_Event.PR_ID_wasPlayed IS 'The program that was played at the event.';
COMMENT ON COLUMN public.EV_Event.ETY_ID_of IS 'The type of the event.';
COMMENT ON TABLE public.AC_partner_AC_with_ONG_currently IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently.AC_ID_partner IS 'One of the actors in the partnership.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently.AC_ID_with IS 'The other actor in the partnership.';
COMMENT ON COLUMN public.AC_partner_AC_with_ONG_currently.ONG_ID_currently IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE public.AC_subset_PN_of IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN public.AC_subset_PN_of.AC_ID_subset IS 'The actor.';
COMMENT ON COLUMN public.AC_subset_PN_of.PN_ID_of IS 'The person who is the actor.';
COMMENT ON TABLE public.EV_in_AC_wasCast IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN public.EV_in_AC_wasCast.EV_ID_in IS 'The event the actor was cast in.';
COMMENT ON COLUMN public.EV_in_AC_wasCast.AC_ID_wasCast IS 'An actor cast in the event.';
COMMENT ON TABLE public.AC_part_PR_in_RAT_got IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got.AC_ID_part IS 'The actor having a part in the program.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got.PR_ID_in IS 'The program the actor has a part in.';
COMMENT ON COLUMN public.AC_part_PR_in_RAT_got.RAT_ID_got IS 'The rating the actor got for the part.';
COMMENT ON TABLE public.ST_at_PR_isPlaying IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN public.ST_at_PR_isPlaying.ST_ID_at IS 'The stage where the program is playing.';
COMMENT ON COLUMN public.ST_at_PR_isPlaying.PR_ID_isPlaying IS 'The program playing at the stage.';
COMMENT ON TABLE public.AC_parent_AC_child_PAT_having IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having.AC_ID_parent IS 'The actor who is the parent.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having.AC_ID_child IS 'The actor who is the child.';
COMMENT ON COLUMN public.AC_parent_AC_child_PAT_having.PAT_ID_having IS 'The type of parental relationship.';
COMMENT ON TABLE public.PR_content_ST_location_EV_of IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of.PR_ID_content IS 'The program that made up the content of the event.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of.ST_ID_location IS 'The stage where the event was located.';
COMMENT ON COLUMN public.PR_content_ST_location_EV_of.EV_ID_of IS 'The event.';
