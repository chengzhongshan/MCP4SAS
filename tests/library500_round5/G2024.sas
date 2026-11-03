/* G2024 getvarc_record, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:55 */

data g2024a; length text $20; do row=1 to 5; text=cats('row_',row); output; end; run;
data g2024o; length text $20; ds=open('g2024a','i'); rc=fetchobs(ds,5); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2024o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2024 rows=' rows;
else do; set g2024o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2024';
else put 'ERROR: ROUND5_FAIL=G2024 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2024:; quit;
