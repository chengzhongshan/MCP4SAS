/* T1318 sql_like_escape, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1318a; length text $20; text='a_9'; value=9; output; text='aX9'; value=100; output; run;
proc sql; create table t1318o as select sum(value) as actual from t1318a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1318o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1318 rows=' rows;
else do; set t1318o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1318';
else put 'ERROR: ROUND3_FAIL=T1318 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1318:; quit;
