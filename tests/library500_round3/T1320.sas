/* T1320 sql_like_escape, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1320a; length text $20; text='a_11'; value=11; output; text='aX11'; value=100; output; run;
proc sql; create table t1320o as select sum(value) as actual from t1320a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1320o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1320 rows=' rows;
else do; set t1320o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1320';
else put 'ERROR: ROUND3_FAIL=T1320 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1320:; quit;
