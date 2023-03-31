	
	/************************** Выполнять в контексте конкретной базы данных **************************/
			
	set
		@search = 'test'; -- что ищем
		
	set
		@data_types_regex = '(char|binary|blob|text)'; -- паттерн для вычленения только строковых атрибутов, по которым будет производиться поиск
		
	
	
	/************************** Дальше ничего не меняем **************************/
		
	create temporary table queries (
		id		int primary key auto_increment
		, query		text
	);
	
	set
		@sql = '';
	
	
	insert into queries (query)
	select
		@sql := concat(
			if(length(@sql), concat(@sql, ' union '), '')
			, 'select '
			, concat('\'', t.table_name, '\'', ' table_name ', ', ')
			, concat('\'', c.column_name, '\'', ' column_name ', ', ')
			, concat('`', t.table_name, '`.`', c.column_name, '` column_value ')
			, 'from '
			, concat('`', t.table_schema, '`.`', t.table_name, '` ')
			, 'where '
			, concat('`', t.table_name, '`.`', c.column_name, '` like \'%', @search, '%\'')
		)
	from
		information_schema.tables t
	inner join information_schema.columns c
		on c.table_name = t.table_name
	where
		t.table_schema = database()
		and lower(c.data_type) regexp @data_types_regex;
		
	
	set
		@sql = (
		
			select
				query
			from
				queries
			order by id desc
			limit 0, 1
			
		);
	
	
	drop temporary table queries;
		
		
	prepare stmt from @sql;
	
	execute stmt;
	
	deallocate prepare stmt;
	
