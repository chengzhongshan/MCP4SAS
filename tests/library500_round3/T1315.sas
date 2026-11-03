/* T1315 sql_like_escape, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1315a; length text $20; text='a_6'; value=6; output; text='aX6'; value=100; output; run;
proc sql; create table t1315o as select sum(value) as actual from t1315a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1315o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1315 rows=' rows;
else do; set t1315o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1315';
else put 'ERROR: ROUND3_FAIL=T1315 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1315:; quit;
