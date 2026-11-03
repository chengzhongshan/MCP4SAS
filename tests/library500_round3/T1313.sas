/* T1313 sql_like_escape, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_for_heatmap_section.sas:106 */

data t1313a; length text $20; text='a_4'; value=4; output; text='aX4'; value=100; output; run;
proc sql; create table t1313o as select sum(value) as actual from t1313a where text like 'a^_%' escape '^'; quit;

data _null_; if 0 then set t1313o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1313 rows=' rows;
else do; set t1313o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1313';
else put 'ERROR: ROUND3_FAIL=T1313 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1313:; quit;
