/* R856 set_end_flag, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r856a; do x=1 to 7; output; end; run;
data r856b; do x=1 to 7+1; output; end; run;
data r856o; set r856a r856b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r856o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R856 rows=' rows;
else do; set r856o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R856';
else put 'ERROR: ROUND2_FAIL=R856 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r856:; quit;
