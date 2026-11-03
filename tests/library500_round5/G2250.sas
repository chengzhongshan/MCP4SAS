/* G2250 numeric_variable_list, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2250a; length label $20; label='ignore'; array vals[11] v1-v11; do j=1 to 11; vals[j]=11; end; drop j; run;
data g2250o; set g2250a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2250o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2250 rows=' rows;
else do; set g2250o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND5_PASS=G2250';
else put 'ERROR: ROUND5_FAIL=G2250 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2250:; quit;
