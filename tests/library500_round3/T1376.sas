/* T1376 leap_day_interval, N=7; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1376o; actual=intck('day','28FEB2000'd,'01MAR2000'd); run;

data _null_; if 0 then set t1376o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1376 rows=' rows;
else do; set t1376o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1376';
else put 'ERROR: ROUND3_FAIL=T1376 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1376:; quit;
