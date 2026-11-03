/* T1388 weekend_date_filter, N=9; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1388a; do day=0 to 28*9-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1388o as select count(*) as actual from t1388a; quit;

data _null_; if 0 then set t1388o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1388 rows=' rows;
else do; set t1388o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND3_PASS=T1388';
else put 'ERROR: ROUND3_FAIL=T1388 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1388:; quit;
