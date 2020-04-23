
IF OBJECT_ID('stats._GatherStatistics') IS NOT NULL
DROP PROC stats._GatherStatistics;
GO

/*
	RUNNING: 
	EXEC stats._GatherStatistics DEFAULT;

	RESULTS:
	SELECT * FROM stats.lGC_GatheredConstruct;

*/
CREATE PROC stats._GatherStatistics (
	@Metadata_Id int = 0
)
AS
BEGIN
	declare @gatheringTime datetime = getdate();

	if OBJECT_ID('tempdb..#schemas') is not null
	drop table #schemas;

	select s.[name]
	into #schemas
	from sys.tables t 
	join sys.schemas s
		on s.[schema_id] = t.[schema_id]
	where t.[name] = '_Schema'
		and s.[name] <> 'stats'; -- do not gather statistics from stats

	if OBJECT_ID('tempdb..#constructs') is not null
	drop table #constructs;

	create table #constructs (
		[GC_ID] int null,
		[capsule] nvarchar(128) not null,
		[name] nvarchar(128) not null,
		[type] char(1) not null,
		primary key (
			[capsule],
			[name]
		)
	)
	
	declare @schema nvarchar(128);
	declare schemaNames cursor for (
		select [name] from #schemas
	);
	open schemaNames;
	fetch next from schemaNames into @schema;

	declare @sql varchar(max);
	while(@@FETCH_STATUS = 0)
	begin
		set @sql = '
		insert into #constructs (
			[name],
			[capsule],
			[type]
		)
		select distinct [name], [capsule], ''A'' as [type] from ' + @schema + '._Anchor 
		union all
		select distinct [name], [capsule], ''B'' as [type] from ' + @schema + '._Attribute 
		union all
		select distinct [name], [capsule], ''K'' as [type] from ' + @schema + '._Knot 
		union all
		select distinct [name], [capsule], ''T'' as [type] from ' + @schema + '._Tie;
		';

		EXEC(@sql);

		fetch next from schemaNames into @schema;
	end

	close schemaNames;
	deallocate schemaNames;

	if OBJECT_ID('tempdb..#types') is not null
	drop table #types;

	create table #types (
		[type] char(1) not null primary key,
		[name] varchar(42) not null
	);

	insert into #types 
	([type], [name])
	values 
	('A', 'Anchor'),
	('B', 'Attribute'),
	('K', 'Knot'),
	('T', 'Tie');

	merge stats.TYP_Type [TYP]
	using #types t
	   on t.[type] = [TYP].[TYP_ID]
	when not matched then insert (
		[TYP_ID],
		[TYP_Type],
		[Metadata_TYP]
	)
	values (
		t.[type],
		t.[name],
		@Metadata_Id
	);

	update c 
	set
		c.GC_ID = nk.GC_ID
	from #constructs c
	join stats.key_GC_ConstructName nk
	  on nk.GC_CAP_GatheredConstruct_Capsule = c.[capsule]
	 and nk.GC_NAM_GatheredConstruct_Name = c.[name];		

	insert into stats.lGC_GatheredConstruct (
		 [GC_LGT_ChangedAt], 
		 [GC_LGT_GatheredConstruct_LatestGatheringTime],
		 [GC_ID], 
		 [Metadata_GC], 
		 [GC_NAM_GatheredConstruct_Name], 
		 [GC_CAP_GatheredConstruct_Capsule], 
		 [GC_TYP_TYP_ID], 
		 [GC_ROC_ChangedAt], 
		 [GC_ROC_GatheredConstruct_RowCount], 
		 [GC_UMB_ChangedAt], 
		 [GC_UMB_GatheredConstruct_UsedMegabytes], 
		 [GC_AMB_ChangedAt], 
		 [GC_AMB_GatheredConstruct_AllocatedMegabytes]
	)
	select
		 @gatheringTime,
		 @gatheringTime,
		 c.GC_ID,
		 @Metadata_Id,
		 c.[name],
		 c.[capsule],
		 c.[type],
		 @gatheringTime,	
		 MAX(p.[rows]),
		 @gatheringTime,	
		 CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS decimal(19,2)),
		 @gatheringTime,	
		 CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS decimal(19,2))
	from #constructs c
	join sys.tables t
	  on t.[name] = c.[name]
	JOIN sys.schemas s 
	  ON s.[schema_id] = t.[schema_id]
	 AND s.[name] = c.[capsule]
	JOIN sys.indexes i 
	  ON i.[object_id] = t.[object_id] 
	JOIN sys.partitions p 
	  ON p.[object_id] = t.[object_id] 
	 AND p.[index_id] = i.[index_id] 
	JOIN sys.allocation_units a 
	  ON a.[container_id] = p.[partition_id]
	GROUP BY
		 c.GC_ID,
		 c.[capsule],
		 c.[name],
		 c.[type];

	declare @n int = 4; -- current and 3 previous

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_RGR_ChangedAt,
		GC_RGR_GatheredConstruct_RowGrowth,
		GC_RGN_ChangedAt,
		GC_RGN_GatheredConstruct_RowGrowthNormal, 
		GC_RGI_ChangedAt,
		GC_RGI_GatheredConstruct_RowGrowthInterval
	)
	SELECT
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		MAX(Growth),
		@gatheringTime,
		MAX(MedianGrowth), 
		@gatheringTime, 
		AVG(Interval)
	FROM (
		SELECT
			ROC.GC_ROC_GC_ID as GC_ID,
			CASE WHEN ROC.GC_ROC_ChangedAt = window.GC_ROC_ChangedAt THEN ROC.GC_ROC_GatheredConstruct_RowCount - window.PreviousValue END as Growth,
			PERCENTILE_CONT(0.5) WITHIN GROUP (
				ORDER BY CASE 
					WHEN window.GC_ROC_ChangedAt < ROC.GC_ROC_ChangedAt 
					THEN window.GC_ROC_GatheredConstruct_RowCount - window.PreviousValue
				END) OVER (
					PARTITION BY window.GC_ROC_GC_ID
			) AS MedianGrowth, 
			DATEDIFF(s, window.PreviousChangedAt, window.GC_ROC_ChangedAt) as Interval
		FROM stats.GC_ROC_GatheredConstruct_RowCount ROC
		OUTER APPLY (
			SELECT 
				*, 
				LAG(ROC_n.GC_ROC_GatheredConstruct_RowCount) OVER (
					PARTITION BY ROC_n.GC_ROC_GC_ID 
					ORDER BY ROC_n.GC_ROC_ChangedAt
				) as PreviousValue,
				LAG(ROC_n.GC_ROC_ChangedAt) OVER (
					PARTITION BY ROC_n.GC_ROC_GC_ID 
					ORDER BY ROC_n.GC_ROC_ChangedAt
				) as PreviousChangedAt
			FROM stats.GC_ROC_GatheredConstruct_RowCount ROC_n
			WHERE ROC_n.GC_ROC_GC_ID = ROC.GC_ROC_GC_ID
			  AND ROC_n.GC_ROC_ChangedAt <= ROC.GC_ROC_ChangedAt
			ORDER BY ROC_n.GC_ROC_ChangedAt DESC
			OFFSET 0 ROWS
			FETCH FIRST (@n) ROWS ONLY 
		) window
		WHERE ROC.GC_ROC_ChangedAt = @gatheringTime
	) calc
	GROUP BY
		GC_ID;

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_UGR_ChangedAt,
		GC_UGR_GatheredConstruct_UsedGrowth,
		GC_UGN_ChangedAt,
		GC_UGN_GatheredConstruct_UsedGrowthNormal,
		GC_UGI_ChangedAt,
		GC_UGI_GatheredConstruct_UsedGrowthInterval
	)
	SELECT
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		MAX(Growth),
		@gatheringTime,
		MAX(MedianGrowth), 
		@gatheringTime, 
		AVG(Interval)
	FROM (
		SELECT
			UMB.GC_UMB_GC_ID as GC_ID,
			CASE WHEN UMB.GC_UMB_ChangedAt = window.GC_UMB_ChangedAt THEN UMB.GC_UMB_GatheredConstruct_UsedMegabytes - window.PreviousValue END as Growth,
			PERCENTILE_CONT(0.5) WITHIN GROUP (
				ORDER BY CASE 
					WHEN window.GC_UMB_ChangedAt < UMB.GC_UMB_ChangedAt 
					THEN window.GC_UMB_GatheredConstruct_UsedMegabytes - window.PreviousValue
				END) OVER (
					PARTITION BY window.GC_UMB_GC_ID
			) AS MedianGrowth, 
			DATEDIFF(s, window.PreviousChangedAt, window.GC_UMB_ChangedAt) as Interval
		FROM stats.GC_UMB_GatheredConstruct_UsedMegabytes UMB
		OUTER APPLY (
			SELECT 
				*, 
				LAG(UMB_n.GC_UMB_GatheredConstruct_UsedMegabytes) OVER (
					PARTITION BY UMB_n.GC_UMB_GC_ID 
					ORDER BY UMB_n.GC_UMB_ChangedAt
				) as PreviousValue,
				LAG(UMB_n.GC_UMB_ChangedAt) OVER (
					PARTITION BY UMB_n.GC_UMB_GC_ID 
					ORDER BY UMB_n.GC_UMB_ChangedAt
				) as PreviousChangedAt
			FROM stats.GC_UMB_GatheredConstruct_UsedMegabytes UMB_n
			WHERE UMB_n.GC_UMB_GC_ID = UMB.GC_UMB_GC_ID
			  AND UMB_n.GC_UMB_ChangedAt <= UMB.GC_UMB_ChangedAt
			ORDER BY UMB_n.GC_UMB_ChangedAt DESC
			OFFSET 0 ROWS
			FETCH FIRST (@n) ROWS ONLY 
		) window
		WHERE UMB.GC_UMB_ChangedAt = @gatheringTime
	) calc
	GROUP BY
		GC_ID;

	insert into stats.lGC_GatheredConstruct (
		GC_ID,
		[Metadata_GC], 
		GC_AGR_ChangedAt,
		GC_AGR_GatheredConstruct_AllocatedGrowth,
		GC_AGN_ChangedAt,
		GC_AGN_GatheredConstruct_AllocatedGrowthNormal,
		GC_AGI_ChangedAt,
		GC_AGI_GatheredConstruct_AllocatedGrowthInterval
	)
	SELECT
		GC_ID,
		@Metadata_Id,
		@gatheringTime,
		MAX(Growth),
		@gatheringTime,
		MAX(MedianGrowth), 
		@gatheringTime, 
		AVG(Interval)
	FROM (
		SELECT
			AMB.GC_AMB_GC_ID as GC_ID,
			CASE WHEN AMB.GC_AMB_ChangedAt = window.GC_AMB_ChangedAt THEN AMB.GC_AMB_GatheredConstruct_AllocatedMegabytes - window.PreviousValue END as Growth,
			PERCENTILE_CONT(0.5) WITHIN GROUP (
				ORDER BY CASE 
					WHEN window.GC_AMB_ChangedAt < AMB.GC_AMB_ChangedAt 
					THEN window.GC_AMB_GatheredConstruct_AllocatedMegabytes - window.PreviousValue
				END) OVER (
					PARTITION BY window.GC_AMB_GC_ID
			) AS MedianGrowth, 
			DATEDIFF(s, window.PreviousChangedAt, window.GC_AMB_ChangedAt) as Interval
		FROM stats.GC_AMB_GatheredConstruct_AllocatedMegabytes AMB
		OUTER APPLY (
			SELECT 
				*, 
				LAG(AMB_n.GC_AMB_GatheredConstruct_AllocatedMegabytes) OVER (
					PARTITION BY AMB_n.GC_AMB_GC_ID 
					ORDER BY AMB_n.GC_AMB_ChangedAt
				) as PreviousValue,
				LAG(AMB_n.GC_AMB_ChangedAt) OVER (
					PARTITION BY AMB_n.GC_AMB_GC_ID 
					ORDER BY AMB_n.GC_AMB_ChangedAt
				) as PreviousChangedAt
			FROM stats.GC_AMB_GatheredConstruct_AllocatedMegabytes AMB_n
			WHERE AMB_n.GC_AMB_GC_ID = AMB.GC_AMB_GC_ID
			  AND AMB_n.GC_AMB_ChangedAt <= AMB.GC_AMB_ChangedAt
			ORDER BY AMB_n.GC_AMB_ChangedAt DESC
			OFFSET 0 ROWS
			FETCH FIRST (@n) ROWS ONLY 
		) window
		WHERE AMB.GC_AMB_ChangedAt = @gatheringTime
	) calc
	GROUP BY
		GC_ID;

END
