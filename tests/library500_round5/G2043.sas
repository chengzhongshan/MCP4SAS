/* G2043 attrc_dataset_label, N=4; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2043a(label='Dataset 4'); x=4; run;
data g2043o; length text $40; ds=open('g2043a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2043o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2043 rows=' rows;
else do; set g2043o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2043';
else put 'ERROR: ROUND5_FAIL=G2043 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2043:; quit;
