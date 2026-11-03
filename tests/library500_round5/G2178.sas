/* G2178 sort_noduprecs, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2178a; do k=1 to 9; value=1; output; output; value=2; output; end; run;
proc sort data=g2178a out=g2178b noduprecs; by _all_; run;
proc sql; create table g2178o as select count(*) as actual from g2178b; quit;

data _null_; if 0 then set g2178o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2178 rows=' rows;
else do; set g2178o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND5_PASS=G2178';
else put 'ERROR: ROUND5_FAIL=G2178 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2178:; quit;
