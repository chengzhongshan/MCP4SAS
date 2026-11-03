/* G2023 getvarc_record, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:55 */

data g2023a; length text $20; do row=1 to 4; text=cats('row_',row); output; end; run;
data g2023o; length text $20; ds=open('g2023a','i'); rc=fetchobs(ds,4); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2023o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2023 rows=' rows;
else do; set g2023o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2023';
else put 'ERROR: ROUND5_FAIL=G2023 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2023:; quit;
