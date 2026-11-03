/* T1319 sql_like_escape, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1319a; length text $20; text='a_10'; value=10; output; text='aX10'; value=100; output; run;
proc sql; create table t1319o as select sum(value) as actual from t1319a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1319o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1319 rows=' rows;
else do; set t1319o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1319';
else put 'ERROR: ROUND3_FAIL=T1319 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1319:; quit;
