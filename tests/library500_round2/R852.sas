/* R852 set_end_flag, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r852a; do x=1 to 3; output; end; run;
data r852b; do x=1 to 3+1; output; end; run;
data r852o; set r852a r852b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r852o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R852 rows=' rows;
else do; set r852o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R852';
else put 'ERROR: ROUND2_FAIL=R852 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r852:; quit;
