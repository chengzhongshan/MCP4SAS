/* G2172 sort_noduprecs, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2172a; do k=1 to 3; value=1; output; output; value=2; output; end; run;
proc sort data=g2172a out=g2172b noduprecs; by _all_; run;
proc sql; create table g2172o as select count(*) as actual from g2172b; quit;

data _null_; if 0 then set g2172o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2172 rows=' rows;
else do; set g2172o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2172';
else put 'ERROR: ROUND5_FAIL=G2172 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2172:; quit;
