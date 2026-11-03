/* R853 set_end_flag, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r853a; do x=1 to 4; output; end; run;
data r853b; do x=1 to 4+1; output; end; run;
data r853o; set r853a r853b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r853o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R853 rows=' rows;
else do; set r853o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R853';
else put 'ERROR: ROUND2_FAIL=R853 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r853:; quit;
