/* G2041 attrc_dataset_label, N=2; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2041a(label='Dataset 2'); x=2; run;
data g2041o; length text $40; ds=open('g2041a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2041o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2041 rows=' rows;
else do; set g2041o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2041';
else put 'ERROR: ROUND5_FAIL=G2041 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2041:; quit;
