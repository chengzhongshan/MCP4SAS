/* T1385 weekend_date_filter, N=6; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1385a; do day=0 to 28*6-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1385o as select count(*) as actual from t1385a; quit;

data _null_; if 0 then set t1385o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1385 rows=' rows;
else do; set t1385o; if not missing(actual) and abs(actual-(48))<=1e-10*max(1,abs(48)) then put 'ROUND3_PASS=T1385';
else put 'ERROR: ROUND3_FAIL=T1385 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1385:; quit;
