/* G2248 numeric_variable_list, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2248a; length label $20; label='ignore'; array vals[9] v1-v9; do j=1 to 9; vals[j]=9; end; drop j; run;
data g2248o; set g2248a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2248o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2248 rows=' rows;
else do; set g2248o; if not missing(actual) and abs(actual-(81))<=1e-9*max(1,abs(81)) then put 'ROUND5_PASS=G2248';
else put 'ERROR: ROUND5_FAIL=G2248 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2248:; quit;
