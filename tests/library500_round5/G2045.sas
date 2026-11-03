/* G2045 attrc_dataset_label, N=6; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2045a(label='Dataset 6'); x=6; run;
data g2045o; length text $40; ds=open('g2045a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2045o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2045 rows=' rows;
else do; set g2045o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2045';
else put 'ERROR: ROUND5_FAIL=G2045 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2045:; quit;
