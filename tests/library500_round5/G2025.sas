/* G2025 getvarc_record, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:55 */

data g2025a; length text $20; do row=1 to 6; text=cats('row_',row); output; end; run;
data g2025o; length text $20; ds=open('g2025a','i'); rc=fetchobs(ds,6); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2025o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2025 rows=' rows;
else do; set g2025o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2025';
else put 'ERROR: ROUND5_FAIL=G2025 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2025:; quit;
