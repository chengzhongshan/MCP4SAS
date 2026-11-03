/* T1314 sql_like_escape, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1314a; length text $20; text='a_5'; value=5; output; text='aX5'; value=100; output; run;
proc sql; create table t1314o as select sum(value) as actual from t1314a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1314o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1314 rows=' rows;
else do; set t1314o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1314';
else put 'ERROR: ROUND3_FAIL=T1314 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1314:; quit;
