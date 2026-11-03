/* R860 set_end_flag, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r860a; do x=1 to 11; output; end; run;
data r860b; do x=1 to 11+1; output; end; run;
data r860o; set r860a r860b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r860o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R860 rows=' rows;
else do; set r860o; if not missing(actual) and abs(actual-(23))<=1e-10*max(1,abs(23)) then put 'ROUND2_PASS=R860';
else put 'ERROR: ROUND2_FAIL=R860 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r860:; quit;
