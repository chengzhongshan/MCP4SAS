/* T1375 leap_day_interval, N=6; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1375o; actual=intck('day','28FEB1996'd,'01MAR1996'd); run;

data _null_; if 0 then set t1375o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1375 rows=' rows;
else do; set t1375o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1375';
else put 'ERROR: ROUND3_FAIL=T1375 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1375:; quit;
