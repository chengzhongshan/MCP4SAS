/* G2050 attrc_dataset_label, N=11; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2050a(label='Dataset 11'); x=11; run;
data g2050o; length text $40; ds=open('g2050a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2050o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2050 rows=' rows;
else do; set g2050o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2050';
else put 'ERROR: ROUND5_FAIL=G2050 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2050:; quit;
