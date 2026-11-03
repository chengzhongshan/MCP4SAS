/* R645 sql_update, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/draw_gene_track_directly_from_GTF_dsd.sas:165 */

data r645a; do x=1 to 6; value=x; output; end; run;
proc sql; update r645a set value=value+10 where mod(x,2)=0;
create table r645o as select sum(value) as actual from r645a; quit;

data _null_; if 0 then set r645o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R645 rows=' rows;
else do; set r645o; if not missing(actual) and abs(actual-(51))<=1e-10*max(1,abs(51)) then put 'ROUND2_PASS=R645';
else put 'ERROR: ROUND2_FAIL=R645 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r645:; quit;
