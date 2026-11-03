/* T1383 weekend_date_filter, N=4; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1383a; do day=0 to 28*4-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1383o as select count(*) as actual from t1383a; quit;

data _null_; if 0 then set t1383o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1383 rows=' rows;
else do; set t1383o; if not missing(actual) and abs(actual-(32))<=1e-10*max(1,abs(32)) then put 'ROUND3_PASS=T1383';
else put 'ERROR: ROUND3_FAIL=T1383 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1383:; quit;
