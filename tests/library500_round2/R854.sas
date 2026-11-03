/* R854 set_end_flag, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r854a; do x=1 to 5; output; end; run;
data r854b; do x=1 to 5+1; output; end; run;
data r854o; set r854a r854b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r854o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R854 rows=' rows;
else do; set r854o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R854';
else put 'ERROR: ROUND2_FAIL=R854 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r854:; quit;
