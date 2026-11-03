/* T1371 leap_day_interval, N=2; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1371o; actual=intck('day','28FEB1980'd,'01MAR1980'd); run;

data _null_; if 0 then set t1371o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1371 rows=' rows;
else do; set t1371o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1371';
else put 'ERROR: ROUND3_FAIL=T1371 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1371:; quit;
