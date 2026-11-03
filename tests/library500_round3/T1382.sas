/* T1382 weekend_date_filter, N=3; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1382a; do day=0 to 28*3-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1382o as select count(*) as actual from t1382a; quit;

data _null_; if 0 then set t1382o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1382 rows=' rows;
else do; set t1382o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND3_PASS=T1382';
else put 'ERROR: ROUND3_FAIL=T1382 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1382:; quit;
