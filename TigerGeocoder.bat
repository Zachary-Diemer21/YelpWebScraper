set TMPDIR=\Users\zdiem\gisdata\temp\
set UNZIPTOOL="C:\Program Files\7-Zip\7z.exe"
set WGETTOOL="C:\Program Files\wget\wget.exe"
set PGBIN="C:\Program Files\PostgreSQL\9.5\bin\
set PGPORT=5432
set PGHOST=localhost
set PGUSER=postgres
set PGPASSWORD=postgres
set PGDATABASE=testgis
set PSQL=%PGBIN%psql"
set SHP2PGSQL=%PGBIN%shp2pgsql"
set STLOWER=al
set STUPPER=AL

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\PLACE
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.AL_place(CONSTRAINT pk_AL_place PRIMARY KEY (plcidfp) ) INHERITS(tiger.place);"
%SHP2PGSQL% -D -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_place.dbf tiger_staging.al_place | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.AL_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('AL_place'), lower('AL_place')); ALTER TABLE tiger_data.AL_place ADD CONSTRAINT uidx_AL_place_gid UNIQUE (gid);"
%PSQL% -c "CREATE INDEX idx_AL_place_soundex_name ON tiger_data.AL_place USING btree (soundex(name));"
%PSQL% -c "CREATE INDEX tiger_data_AL_place_the_geom_gist ON tiger_data.AL_place USING gist(the_geom);"
%PSQL% -c "ALTER TABLE tiger_data.AL_place ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\COUSUB
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_cousub.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_cousub(CONSTRAINT pk_%STUPPER%_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_%STUPPER%_cousub_gid UNIQUE (gid)) INHERITS(tiger.cousub);"
%SHP2PGSQL% -D -c -s 4269 -g the_geom -W "latin1" tl_2013_01_cousub.dbf tiger_staging.%STLOWER%_cousub | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.%STUPPER%_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('%STUPPER%_cousub'), lower('%STUPPER%_cousub')); ALTER TABLE tiger_data.%STUPPER%_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_cousub_the_geom_gist ON tiger_data.%STUPPER%_cousub USING gist(the_geom);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_cousub_countyfp ON tiger_data.%STUPPER%_cousub USING btree(countyfp);"


cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\TRACT
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_tract.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_tract(CONSTRAINT pk_%STUPPER%_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); "
%SHP2PGSQL% -D -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_tract.dbf tiger_staging.%STLOWER%_tract | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.%STUPPER%_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('%STUPPER%_tract'), lower('%STUPPER%_tract')); "
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_tract_the_geom_gist ON tiger_data.%STUPPER%_tract USING gist(the_geom);"
%PSQL% -c "VACUUM ANALYZE tiger_data.%STUPPER%_tract;"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\BG
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_bg.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_bg(CONSTRAINT pk_%STUPPER%_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);"
%SHP2PGSQL% -D -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_bg.dbf tiger_staging.%STLOWER%_bg | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.%STUPPER%_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('%STUPPER%_bg'), lower('%STUPPER%_bg')); "
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_bg_the_geom_gist ON tiger_data.%STUPPER%_bg USING gist(the_geom);"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_bg;"

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/tl_*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2010\ZCTA5\2010
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_zcta510*.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_zcta5(CONSTRAINT pk_%STUPPER%_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_%STUPPER%_zcta5_gid UNIQUE (gid)) INHERITS(tiger.zcta5);"
for /r %%z in (*zcta510*.dbf) do (%SHP2PGSQL% -D -D -s 4269 -g the_geom -W "latin1" %%z tiger_staging._zcta510 | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('%STUPPER%_zcta510'), lower('%STUPPER%_zcta5'));")
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_zcta5_the_geom_gist ON tiger_data.%STUPPER%_zcta5 USING gist(the_geom);"

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/tl_*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\FACES
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_faces*.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_faces(CONSTRAINT pk_%STUPPER%_faces PRIMARY KEY (gid)) INHERITS(tiger.faces);"
for /r %%z in (*faces*.dbf) do (%SHP2PGSQL% -D -D -s 4269 -g the_geom -W "latin1" %%z tiger_staging.%STUPPER%_faces | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('%STUPPER%_faces'), lower('%STUPPER%_faces'));")

%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_faces_the_geom_gist ON tiger_data.%STUPPER%_faces USING gist(the_geom);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_faces_tfid ON tiger_data.%STUPPER%_faces USING btree (tfid);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_faces_countyfp ON tiger_data.%STUPPER%_faces USING btree (countyfp);"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_faces;"

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/tl_*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\FEATNAMES
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_featnames*.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_featnames(CONSTRAINT pk_%STUPPER%_featnames PRIMARY KEY (gid)) INHERITS(tiger.featnames);ALTER TABLE tiger_data.%STUPPER%_featnames ALTER COLUMN statefp SET DEFAULT '01';"
for /r %%z in (*featnames*.dbf) do (%SHP2PGSQL% -D -D -s 4269 -g the_geom -W "latin1" %%z tiger_staging.%STUPPER%_featnames | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('%STUPPER%_featnames'), lower('%STUPPER%_featnames'));")
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_featnames_snd_name ON tiger_data.%STUPPER%_featnames USING btree (soundex(name));"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_featnames_lname ON tiger_data.%STUPPER%_featnames USING btree (lower(name));"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_featnames_tlid_statefp ON tiger_data.%STUPPER%_featnames USING btree (tlid,statefp);"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_featnames;"

cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/tl_*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\EDGES
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_edges*.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_edges(CONSTRAINT pk_%STUPPER%_edges PRIMARY KEY (gid)) INHERITS(tiger.edges);"
for /r %%z in (*edges*.dbf) do (%SHP2PGSQL% -D -D -s 4269 -g the_geom -W "latin1" %%z tiger_staging.%STUPPER%_edges | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('%STUPPER%_edges'), lower('%STUPPER%_edges'));")

%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_edges_tlid ON tiger_data.%STUPPER%_edges USING btree (tlid);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_edgestfidr ON tiger_data.%STUPPER%_edges USING btree (tfidr);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_edges_tfidl ON tiger_data.%STUPPER%_edges USING btree (tfidl);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_edges_countyfp ON tiger_data.%STUPPER%_edges USING btree (countyfp);"
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_tract_the_geom_gist ON tiger_data.%STUPPER%_tract USING gist(the_geom);"
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_edges_the_geom_gist ON tiger_data.%STUPPER%_edges USING gist(the_geom);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_edges_zipl ON tiger_data.%STUPPER%_edges USING btree (zipl);"
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_zip_state_loc(CONSTRAINT pk_%STUPPER%_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(tiger.zip_state_loc);"
%PSQL% -c "INSERT INTO tiger_data.%STUPPER%_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, '%STUPPER%', '01', p.name FROM tiger_data.%STUPPER%_edges AS e INNER JOIN tiger_data.%STUPPER%_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.%STUPPER%_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_zip_state_loc_place ON tiger_data.%STUPPER%_zip_state_loc USING btree(soundex(place));"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_edges;"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_zip_state_loc;"
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_zip_lookup_base(CONSTRAINT pk_%STUPPER%_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(tiger.zip_lookup_base);"
%PSQL% -c "INSERT INTO tiger_data.%STUPPER%_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, '%STUPPER%', c.name,p.name,'01'  FROM tiger_data.%STUPPER%_edges AS e INNER JOIN tiger.county As c ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '01') INNER JOIN tiger_data.%STUPPER%_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.%STUPPER%_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_zip_lookup_base_citysnd ON tiger_data.%STUPPER%_zip_lookup_base USING btree(soundex(city));"


cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/tl_*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\ADDR
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_addr*.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_addr(CONSTRAINT pk_%STUPPER%_addr PRIMARY KEY (gid)) INHERITS(tiger.addr);ALTER TABLE tiger_data.%STUPPER%_addr ALTER COLUMN statefp SET DEFAULT '01';"
for /r %%z in (*addr*.dbf) do (%SHP2PGSQL% -D -D -s 4269 -g the_geom -W "latin1" %%z tiger_staging.%STUPPER%_addr | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('%STUPPER%_addr'), lower('%STUPPER%_addr'));")

%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_addr_least_address ON tiger_data.%STUPPER%_addr USING btree (least_hn(fromhn,tohn) );"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_addr_tlid_statefp ON tiger_data.%STUPPER%_addr USING btree (tlid, statefp);"
%PSQL% -c "CREATE INDEX idx_tiger_data_%STUPPER%_addr_zip ON tiger_data.%STUPPER%_addr USING btree (zip);"
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_zip_state(CONSTRAINT pk_%STUPPER%_zip_state PRIMARY KEY(zip,stusps)) INHERITS(tiger.zip_state); "
%PSQL% -c "INSERT INTO tiger_data.%STUPPER%_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, '%STUPPER%', '01' FROM tiger_data.%STUPPER%_addr WHERE zip is not null;"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_addr;"


cd /Users/zdiem/Desktop

%WGETTOOL% ftp://ftp2.census.gov/geo/tiger/TIGER2015/TABBLOCK/tl_*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html
cd \Users\zdiem\Desktop\ftp2.census.gov\geo\tiger\TIGER2013\TABBLOCK
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %%z in (tl_*_01*_tabblock*.zip ) do %UNZIPTOOL% e %%z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.%STUPPER%_tabblock(CONSTRAINT pk_%STUPPER%_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);"
for /r %%z in (*tabblock*.dbf) do (%SHP2PGSQL% -D -D -s 4269 -g the_geom -W "latin1" %%z tiger_staging.%STUPPER%_tabblock | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('%STUPPER%_tabblock'), lower('%STUPPER%_tabblock'));")
%PSQL% -c "ALTER TABLE tiger_staging.%STUPPER%_tabblock RENAME geoid10 TO tabblock_id;"
%PSQL% -c "ALTER TABLE tiger_data.%STUPPER%_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
%PSQL% -c "CREATE INDEX tiger_data_%STUPPER%_tabblock_the_geom_gist ON tiger_data.%STUPPER%_tabblock USING gist(the_geom);"
%PSQL% -c "vacuum analyze tiger_data.%STUPPER%_tabblock;"
