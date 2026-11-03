/* G2027 getvarc_record, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:55 */

data g2027a; length text $20; do row=1 to 8; text=cats('row_',row); output; end; run;
data g2027o; length text $20; ds=open('g2027a','i'); rc=fetchobs(ds,8); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2027o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2027 rows=' rows;
else do; set g2027o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2027';
else put 'ERROR: ROUND5_FAIL=G2027 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2027:; quit;
