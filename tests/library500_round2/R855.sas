/* R855 set_end_flag, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r855a; do x=1 to 6; output; end; run;
data r855b; do x=1 to 6+1; output; end; run;
data r855o; set r855a r855b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r855o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R855 rows=' rows;
else do; set r855o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND2_PASS=R855';
else put 'ERROR: ROUND2_FAIL=R855 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r855:; quit;
