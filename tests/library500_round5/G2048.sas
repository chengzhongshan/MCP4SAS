/* G2048 attrc_dataset_label, N=9; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2048a(label='Dataset 9'); x=9; run;
data g2048o; length text $40; ds=open('g2048a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2048o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2048 rows=' rows;
else do; set g2048o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2048';
else put 'ERROR: ROUND5_FAIL=G2048 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2048:; quit;
