/* R858 set_end_flag, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r858a; do x=1 to 9; output; end; run;
data r858b; do x=1 to 9+1; output; end; run;
data r858o; set r858a r858b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r858o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R858 rows=' rows;
else do; set r858o; if not missing(actual) and abs(actual-(19))<=1e-10*max(1,abs(19)) then put 'ROUND2_PASS=R858';
else put 'ERROR: ROUND2_FAIL=R858 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r858:; quit;
