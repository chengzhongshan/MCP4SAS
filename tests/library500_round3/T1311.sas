/* T1311 sql_like_escape, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1311a; length text $20; text='a_2'; value=2; output; text='aX2'; value=100; output; run;
proc sql; create table t1311o as select sum(value) as actual from t1311a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1311o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1311 rows=' rows;
else do; set t1311o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1311';
else put 'ERROR: ROUND3_FAIL=T1311 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1311:; quit;
