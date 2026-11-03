/* T1316 sql_like_escape, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1316a; length text $20; text='a_7'; value=7; output; text='aX7'; value=100; output; run;
proc sql; create table t1316o as select sum(value) as actual from t1316a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1316o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1316 rows=' rows;
else do; set t1316o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1316';
else put 'ERROR: ROUND3_FAIL=T1316 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1316:; quit;
