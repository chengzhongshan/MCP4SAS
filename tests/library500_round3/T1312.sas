/* T1312 sql_like_escape, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1312a; length text $20; text='a_3'; value=3; output; text='aX3'; value=100; output; run;
proc sql; create table t1312o as select sum(value) as actual from t1312a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1312o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1312 rows=' rows;
else do; set t1312o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1312';
else put 'ERROR: ROUND3_FAIL=T1312 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1312:; quit;
