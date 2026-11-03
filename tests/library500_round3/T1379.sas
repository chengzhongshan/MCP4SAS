/* T1379 leap_day_interval, N=10; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1379o; actual=intck('day','28FEB2012'd,'01MAR2012'd); run;

data _null_; if 0 then set t1379o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1379 rows=' rows;
else do; set t1379o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1379';
else put 'ERROR: ROUND3_FAIL=T1379 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1379:; quit;
