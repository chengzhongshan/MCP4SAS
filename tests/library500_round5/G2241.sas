/* G2241 numeric_variable_list, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2241a; length label $20; label='ignore'; array vals[2] v1-v2; do j=1 to 2; vals[j]=2; end; drop j; run;
data g2241o; set g2241a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2241o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2241 rows=' rows;
else do; set g2241o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2241';
else put 'ERROR: ROUND5_FAIL=G2241 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2241:; quit;
