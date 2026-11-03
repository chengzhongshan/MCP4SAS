/* R851 set_end_flag, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r851a; do x=1 to 2; output; end; run;
data r851b; do x=1 to 2+1; output; end; run;
data r851o; set r851a r851b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r851o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R851 rows=' rows;
else do; set r851o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R851';
else put 'ERROR: ROUND2_FAIL=R851 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r851:; quit;
