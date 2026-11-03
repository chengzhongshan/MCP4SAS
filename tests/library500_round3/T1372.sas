/* T1372 leap_day_interval, N=3; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1372o; actual=intck('day','28FEB1984'd,'01MAR1984'd); run;

data _null_; if 0 then set t1372o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1372 rows=' rows;
else do; set t1372o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1372';
else put 'ERROR: ROUND3_FAIL=T1372 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1372:; quit;
