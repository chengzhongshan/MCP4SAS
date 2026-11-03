/* T1378 leap_day_interval, N=9; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1378o; actual=intck('day','28FEB2008'd,'01MAR2008'd); run;

data _null_; if 0 then set t1378o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1378 rows=' rows;
else do; set t1378o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1378';
else put 'ERROR: ROUND3_FAIL=T1378 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1378:; quit;
