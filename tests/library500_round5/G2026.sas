/* G2026 getvarc_record, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:55 */

data g2026a; length text $20; do row=1 to 7; text=cats('row_',row); output; end; run;
data g2026o; length text $20; ds=open('g2026a','i'); rc=fetchobs(ds,7); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2026o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2026 rows=' rows;
else do; set g2026o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2026';
else put 'ERROR: ROUND5_FAIL=G2026 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2026:; quit;
