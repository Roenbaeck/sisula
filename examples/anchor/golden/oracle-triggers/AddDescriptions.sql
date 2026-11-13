-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the tables and the columns holding values and references, making
-- them available to catalogs and semantic layers. A comment in Oracle is replaced by running the statement again.
-- Oracle has no comment on a schema, so the description of the model itself is not added.
--
COMMENT ON TABLE GRD_Grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN GRD_Grade.GRD_Grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN EV_QTY_Event_Quantity.EV_QTY_Event_Quantity IS 'Static.';
COMMENT ON COLUMN EV_PLC_Event_Place.EV_PLC_Event_Place IS 'Historized and not restatable, as an attribute of an anchor may be.';
COMMENT ON COLUMN SU_NAM_Subject_Name.SU_NAM_Subject_Name IS 'Static.';
COMMENT ON COLUMN SU_COD_Subject_Code.SU_COD_Subject_Code IS 'Static and idempotent.';
COMMENT ON COLUMN SU_GRD_Subject_Grade.SU_GRD_GRD_ID IS 'Static and knotted.';
COMMENT ON COLUMN SU_NOT_Subject_Note.SU_NOT_Subject_Note IS 'Static, with a checksum.';
COMMENT ON COLUMN SU_TTL_Subject_Title.SU_TTL_Subject_Title IS 'Historized, restatable.';
COMMENT ON COLUMN SU_STA_Subject_State.SU_STA_Subject_State IS 'Historized, not restatable: a restatement is an error.';
COMMENT ON COLUMN SU_LBL_Subject_Label.SU_LBL_Subject_Label IS 'Historized, not restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN SU_TAG_Subject_Tag.SU_TAG_Subject_Tag IS 'Historized, restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN SU_LVL_Subject_Level.SU_LVL_GRD_ID IS 'Historized and knotted.';
COMMENT ON COLUMN SU_TXT_Subject_Text.SU_TXT_Subject_Text IS 'Historized, with a checksum.';
COMMENT ON COLUMN SU_ASR_Subject_Assessment.SU_ASR_Subject_Assessment IS 'Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).';
COMMENT ON COLUMN SU_ERS_Subject_Erasable.SU_ERS_Subject_Erasable IS 'Historized and deletable (uni-temporal).';
COMMENT ON COLUMN OB_NAM_Object_Name.OB_NAM_Object_Name IS 'Static.';
COMMENT ON TABLE SU_Subject IS 'The subject of the tests.';
COMMENT ON TABLE OB_Object IS 'Something the subject has or keeps.';
COMMENT ON TABLE EV_Event IS 'An event, with attributes of its own, a static one and a historized one.';
COMMENT ON COLUMN EV_Event.SU_ID_for IS 'The subject the event is for.';
COMMENT ON TABLE SU_holder_OB_item_GRD_grade IS 'Historized, with identifiers and a knotted value role, restatable.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade.SU_ID_holder IS 'The subject of the tests.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade.OB_ID_item IS 'Something the subject has or keeps.';
COMMENT ON COLUMN SU_holder_OB_item_GRD_grade.GRD_ID_grade IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE SU_keeper_OB_thing_GRD_rank IS 'Historized, with identifiers and a knotted value role, idempotent and not assertive.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank.SU_ID_keeper IS 'The subject of the tests.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank.OB_ID_thing IS 'Something the subject has or keeps.';
COMMENT ON COLUMN SU_keeper_OB_thing_GRD_rank.GRD_ID_rank IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE OB_part_SU_owner IS 'Static, with an identifier and a value role: each object has one owner.';
COMMENT ON COLUMN OB_part_SU_owner.OB_ID_part IS 'Something the subject has or keeps.';
COMMENT ON COLUMN OB_part_SU_owner.SU_ID_owner IS 'The subject of the tests.';
COMMENT ON TABLE SU_partner_SU_with IS 'Historized, without identifiers.';
COMMENT ON COLUMN SU_partner_SU_with.SU_ID_partner IS 'The subject of the tests.';
COMMENT ON COLUMN SU_partner_SU_with.SU_ID_with IS 'The subject of the tests.';
