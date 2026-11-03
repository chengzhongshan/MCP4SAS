/* G2243 numeric_variable_list, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2243a; length label $20; label='ignore'; array vals[4] v1-v4; do j=1 to 4; vals[j]=4; end; drop j; run;
data g2243o; set g2243a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2243o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2243 rows=' rows;
else do; set g2243o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND5_PASS=G2243';
else put 'ERROR: ROUND5_FAIL=G2243 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2243:; quit;
