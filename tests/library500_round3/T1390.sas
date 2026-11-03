/* T1390 weekend_date_filter, N=11; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */

data t1390a; do day=0 to 28*11-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table t1390o as select count(*) as actual from t1390a; quit;

data _null_; if 0 then set t1390o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1390 rows=' rows;
else do; set t1390o; if not missing(actual) and abs(actual-(88))<=1e-10*max(1,abs(88)) then put 'ROUND3_PASS=T1390';
else put 'ERROR: ROUND3_FAIL=T1390 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1390:; quit;
