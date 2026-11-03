/* G2042 attrc_dataset_label, N=3; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2042a(label='Dataset 3'); x=3; run;
data g2042o; length text $40; ds=open('g2042a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2042o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2042 rows=' rows;
else do; set g2042o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2042';
else put 'ERROR: ROUND5_FAIL=G2042 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2042:; quit;
