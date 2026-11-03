/* G2049 attrc_dataset_label, N=10; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2049a(label='Dataset 10'); x=10; run;
data g2049o; length text $40; ds=open('g2049a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2049o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2049 rows=' rows;
else do; set g2049o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2049';
else put 'ERROR: ROUND5_FAIL=G2049 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2049:; quit;
