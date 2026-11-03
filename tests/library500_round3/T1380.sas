/* T1380 leap_day_interval, N=11; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data t1380o; actual=intck('day','28FEB2016'd,'01MAR2016'd); run;

data _null_; if 0 then set t1380o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1380 rows=' rows;
else do; set t1380o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1380';
else put 'ERROR: ROUND3_FAIL=T1380 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1380:; quit;
