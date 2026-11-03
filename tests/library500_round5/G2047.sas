/* G2047 attrc_dataset_label, N=8; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2047a(label='Dataset 8'); x=8; run;
data g2047o; length text $40; ds=open('g2047a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2047o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2047 rows=' rows;
else do; set g2047o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2047';
else put 'ERROR: ROUND5_FAIL=G2047 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2047:; quit;
