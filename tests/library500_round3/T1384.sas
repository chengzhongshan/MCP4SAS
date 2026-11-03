/* T1384 weekend_date_filter, N=5; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1384a; do day=0 to 28*5-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1384o as select count(*) as actual from t1384a; quit;

data _null_; if 0 then set t1384o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1384 rows=' rows;
else do; set t1384o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND3_PASS=T1384';
else put 'ERROR: ROUND3_FAIL=T1384 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1384:; quit;
