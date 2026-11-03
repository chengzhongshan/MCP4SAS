/* G2029 getvarc_record, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:55 */

data g2029a; length text $20; do row=1 to 10; text=cats('row_',row); output; end; run;
data g2029o; length text $20; ds=open('g2029a','i'); rc=fetchobs(ds,10); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2029o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2029 rows=' rows;
else do; set g2029o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2029';
else put 'ERROR: ROUND5_FAIL=G2029 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2029:; quit;
