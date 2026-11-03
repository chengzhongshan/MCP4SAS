/* G2246 numeric_variable_list, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2246a; length label $20; label='ignore'; array vals[7] v1-v7; do j=1 to 7; vals[j]=7; end; drop j; run;
data g2246o; set g2246a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2246o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2246 rows=' rows;
else do; set g2246o; if not missing(actual) and abs(actual-(49))<=1e-9*max(1,abs(49)) then put 'ROUND5_PASS=G2246';
else put 'ERROR: ROUND5_FAIL=G2246 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2246:; quit;
