-- <Author Dracodoc - github link https://github.com/dracodoc/Geocode/blob/master/geocode_batch.sql> --
-- Edited by Zachary Diemer --

-- prepare tables --
DROP TABLE IF EXISTS address_table;
CREATE TABLE address_table(
	addid serial NOT NULL PRIMARY KEY, 
	name varchar(255),
	address varchar(255),
	phone varchar(255),
	reviews varchar(255),
	rating integer,
	lon numeric,
	lat numeric,
	output_address text, 
	geomout geometry,
	tabblock_id varchar(20),
	state text,
	county text,
	tractid text);

INSERT INTO address_table(name, address, phone, reviews)
SELECT biz_name, biz_address, biz_phone, num_of_reviews FROM geocodeaddr.test	

--<< geocode function --
CREATE OR REPLACE FUNCTION geocode_sample(sample_size integer) 
	RETURNS void AS $$
DECLARE OUTPUT address_table%ROWTYPE;
BEGIN
UPDATE address_table
  SET (rating, output_address, lon, lat, geomout)
	= (COALESCE((g.geo).rating,-1), 
	   pprint_addy((g.geo).addy),
	   ST_X((g.geo).geomout)::numeric(8,5), 
	   ST_Y((g.geo).geomout)::numeric(8,5),
	   (g.geo).geomout
	  )
FROM (SELECT addid
	FROM address_table
	WHERE rating IS NULL
	ORDER BY addid LIMIT sample_size) AS a LEFT JOIN (
		SELECT sample.addid, geocode(sample.input_address,1) AS geo
		FROM (SELECT addid, input_address
			FROM address_table WHERE rating IS NULL
			ORDER BY addid LIMIT sample_size) AS sample) AS g ON a.addid = g.addid
WHERE a.addid = address_table.addid;

EXCEPTION
	WHEN OTHERS THEN
		SELECT * INTO OUTPUT 
			FROM address_table 
			WHERE rating IS NULL ORDER BY addid LIMIT 1;
		RAISE NOTICE '<address error> in samples started from: %', OUTPUT;
		RAISE notice '-- !!! % % !!!--', SQLERRM, SQLSTATE;
		UPDATE address_table
			SET rating = -2
		FROM (SELECT addid
			FROM address_table 
			WHERE rating IS NULL ORDER BY addid LIMIT sample_size) AS sample
		WHERE sample.addid = address_table.addid;
END;
$$ LANGUAGE plpgsql;
-- geocode function >>--


--<< census block function --
CREATE OR REPLACE FUNCTION mapblock_sample(block_sample_size integer) 
	RETURNS void AS $$
DECLARE OUTPUT address_table%ROWTYPE;
BEGIN
UPDATE address_table
	SET (tabblock_id, STATE, county, tractid)
	  = (COALESCE(ab.tabblock_id,'FFFF'), 
		 substring(ab.tabblock_id FROM 1 FOR 2),
		 substring(ab.tabblock_id FROM 3 FOR 3),
		 substring(ab.tabblock_id FROM 1 FOR 11)
		)
FROM
	(SELECT addid
		FROM address_table
		WHERE (geomout IS NOT NULL) AND (tabblock_id IS NULL)
		ORDER BY addid LIMIT block_sample_size
	) AS a
	LEFT JOIN (
		SELECT a.addid, b.tabblock_id
			FROM address_table AS a, tabblock AS b
			WHERE (geomout IS NOT NULL) AND (a.tabblock_id IS NULL) 
				AND ST_Contains(b.the_geom, ST_SetSRID(ST_Point(a.lon, a.lat), 4269))
			ORDER BY addid LIMIT block_sample_size
			  ) AS ab ON a.addid = ab.addid
WHERE a.addid = address_table.addid; 
-- no exception really happened, but still keep it here.
EXCEPTION
	WHEN OTHERS THEN
		SELECT * INTO OUTPUT 
			FROM address_table 
			WHERE (geomout IS NOT NULL) AND (tabblock_id IS NULL) 
			ORDER BY addid LIMIT 1; 
		RAISE NOTICE '<census block> error in samples started from: %', OUTPUT;
		RAISE notice '-- !!! % % !!!--', SQLERRM, SQLSTATE;
		UPDATE address_table
			SET tabblock_id = 'EEEE'
		FROM (SELECT addid
				FROM address_table
				WHERE (geomout IS NOT NULL) AND (tabblock_id IS NULL)
				ORDER BY addid LIMIT block_sample_size
			 ) AS a
		WHERE a.addid = address_table.addid;
END;
$$ LANGUAGE plpgsql;
-- census block function >>--


--<< main control --
-- cannot replace function return type, need to drop first
DROP FUNCTION IF EXISTS geocode_table(); -- only need to provide IN arg
CREATE OR REPLACE FUNCTION geocode_table(
	OUT table_size integer, 
	OUT remaining_rows integer,
	OUT total_time interval(0), 
	OUT time_per_row interval(3)
	) AS $func$
DECLARE sample_size integer;
DECLARE block_sample_size integer;
DECLARE report_address_runs integer;-- sample size * runs, 100 * 1 = 100
DECLARE report_block_runs integer;-- block size * runs, 100 * 10 = 1000
DECLARE starting_time timestamp(0) WITH time ZONE;
DECLARE time_stamp timestamp(0) WITH time ZONE;
DECLARE time_passed interval(1);

BEGIN
	SELECT reltuples::bigint INTO table_size
					FROM  pg_class
					WHERE oid = 'public.address_table'::regclass;
	starting_time := clock_timestamp();	
	time_stamp := clock_timestamp(); 
	RAISE notice '> % : Start on table of %', starting_time, table_size;
	RAISE notice '> time passed | address processed <<<< address left';
	sample_size := 1;
	block_sample_size := 10;
	report_address_runs := 100; -- modify this in debugging with small sample
	report_block_runs := 100; -- modify this in debug with small sample
	FOR i IN 1..(SELECT table_size / sample_size + 1) LOOP
		PERFORM geocode_sample(sample_size);
		-- s taken for 100 rows x 10 = ms/row.
		IF i % report_address_runs = 0  THEN
			SELECT count(*) INTO remaining_rows 
				FROM address_table WHERE rating IS NULL;
			time_passed := clock_timestamp() - time_stamp;
			RAISE notice E'> %  |\t%\t<<<<\t%', 
				time_passed, i * sample_size, remaining_rows;
			time_stamp := clock_timestamp();
		END IF;
	END LOOP;
	time_stamp := clock_timestamp();
	RAISE notice '==== start mapping census block ====';
	RAISE notice '# time passed | address to block <<<< address left';
	FOR i IN 1..(SELECT table_size / block_sample_size + 1) LOOP
		PERFORM mapblock_sample(block_sample_size);
		IF i % report_block_runs = 0 THEN
			SELECT count(*) INTO remaining_rows 
				FROM address_table WHERE tabblock_id IS NULL;
			time_passed := clock_timestamp() - time_stamp;
			RAISE notice E'# %  |\t%\t<<<<\t%', 
				time_passed, i * block_sample_size, remaining_rows;
			time_stamp := clock_timestamp();
		END IF;
	END LOOP;
	SELECT count(*) INTO remaining_rows 
		FROM address_table WHERE rating IS NULL;
	total_time := to_char(clock_timestamp() - starting_time, 'HH24:MI:SS'); 
	time_per_row := to_char(total_time / table_size, 'HH24:MI:SS.MS'); 
END
$func$ LANGUAGE plpgsql;
-- main control >>--

SELECT * FROM geocode_table();

