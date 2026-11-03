/* T1386 weekend_date_filter, N=7; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1386a; do day=0 to 28*7-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1386o as select count(*) as actual from t1386a; quit;

data _null_; if 0 then set t1386o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1386 rows=' rows;
else do; set t1386o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND3_PASS=T1386';
else put 'ERROR: ROUND3_FAIL=T1386 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1386:; quit;
