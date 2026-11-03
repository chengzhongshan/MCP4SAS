/* G2046 attrc_dataset_label, N=7; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2046a(label='Dataset 7'); x=7; run;
data g2046o; length text $40; ds=open('g2046a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2046o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2046 rows=' rows;
else do; set g2046o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2046';
else put 'ERROR: ROUND5_FAIL=G2046 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2046:; quit;
