/* G2177 sort_noduprecs, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2177a; do k=1 to 8; value=1; output; output; value=2; output; end; run;
proc sort data=g2177a out=g2177b noduprecs; by _all_; run;
proc sql; create table g2177o as select count(*) as actual from g2177b; quit;

data _null_; if 0 then set g2177o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2177 rows=' rows;
else do; set g2177o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND5_PASS=G2177';
else put 'ERROR: ROUND5_FAIL=G2177 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2177:; quit;
