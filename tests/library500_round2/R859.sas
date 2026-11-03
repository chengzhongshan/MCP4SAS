/* R859 set_end_flag, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r859a; do x=1 to 10; output; end; run;
data r859b; do x=1 to 10+1; output; end; run;
data r859o; set r859a r859b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r859o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R859 rows=' rows;
else do; set r859o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R859';
else put 'ERROR: ROUND2_FAIL=R859 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r859:; quit;
