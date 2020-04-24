
declare @Metadata_Id int = 0;

insert into stats.TYP_Type (
	[TYP_ID],
	[TYP_Type],
	[Metadata_TYP]
)
values 
('A', 'Anchor',		@Metadata_Id),
('B', 'Attribute',	@Metadata_Id),
('K', 'Knot',		@Metadata_Id),
('T', 'Tie',		@Metadata_Id);

insert into stats.TRE_Trend (
	[TRE_ID], 
	[TRE_Trend], 
	[Metadata_TRE]
)
values 
(0, '0', @Metadata_Id),
(1, '+', @Metadata_Id),
(2, '-', @Metadata_Id),
(3, '++', @Metadata_Id),
(4, '--', @Metadata_Id);

insert into stats.SYN_Sync (
	[SYN_ID], 
	[SYN_Sync], 
	[Metadata_SYN]
)
values 
(0, 'Arrived', @Metadata_Id),
(1, 'Delayed', @Metadata_Id),
(2, 'Overdue', @Metadata_Id);
