/* T1317 sql_like_escape, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1317a; length text $20; text='a_8'; value=8; output; text='aX8'; value=100; output; run;
proc sql; create table t1317o as select sum(value) as actual from t1317a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1317o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1317 rows=' rows;
else do; set t1317o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1317';
else put 'ERROR: ROUND3_FAIL=T1317 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1317:; quit;
