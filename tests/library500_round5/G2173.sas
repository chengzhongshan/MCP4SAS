/* G2173 sort_noduprecs, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2173a; do k=1 to 4; value=1; output; output; value=2; output; end; run;
proc sort data=g2173a out=g2173b noduprecs; by _all_; run;
proc sql; create table g2173o as select count(*) as actual from g2173b; quit;

data _null_; if 0 then set g2173o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2173 rows=' rows;
else do; set g2173o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2173';
else put 'ERROR: ROUND5_FAIL=G2173 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2173:; quit;
