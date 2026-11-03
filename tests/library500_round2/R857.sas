/* R857 set_end_flag, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data r857a; do x=1 to 8; output; end; run;
data r857b; do x=1 to 8+1; output; end; run;
data r857o; set r857a r857b end=last; if last; actual=_n_; run;

data _null_; if 0 then set r857o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R857 rows=' rows;
else do; set r857o; if not missing(actual) and abs(actual-(17))<=1e-10*max(1,abs(17)) then put 'ROUND2_PASS=R857';
else put 'ERROR: ROUND2_FAIL=R857 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r857:; quit;
