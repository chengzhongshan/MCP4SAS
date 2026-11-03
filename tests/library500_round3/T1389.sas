/* T1389 weekend_date_filter, N=10; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1389a; do day=0 to 28*10-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1389o as select count(*) as actual from t1389a; quit;

data _null_; if 0 then set t1389o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1389 rows=' rows;
else do; set t1389o; if not missing(actual) and abs(actual-(80))<=1e-10*max(1,abs(80)) then put 'ROUND3_PASS=T1389';
else put 'ERROR: ROUND3_FAIL=T1389 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1389:; quit;
