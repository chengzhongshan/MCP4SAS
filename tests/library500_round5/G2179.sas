/* G2179 sort_noduprecs, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data g2179a; do k=1 to 10; value=1; output; output; value=2; output; end; run;
proc sort data=g2179a out=g2179b noduprecs; by _all_; run;
proc sql; create table g2179o as select count(*) as actual from g2179b; quit;

data _null_; if 0 then set g2179o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2179 rows=' rows;
else do; set g2179o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND5_PASS=G2179';
else put 'ERROR: ROUND5_FAIL=G2179 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2179:; quit;
