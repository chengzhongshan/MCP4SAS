/* T1381 weekend_date_filter, N=2; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1381a; do day=0 to 28*2-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1381o as select count(*) as actual from t1381a; quit;

data _null_; if 0 then set t1381o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1381 rows=' rows;
else do; set t1381o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1381';
else put 'ERROR: ROUND3_FAIL=T1381 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1381:; quit;
