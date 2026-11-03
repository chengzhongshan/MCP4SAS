/* G2044 attrc_dataset_label, N=5; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:313 */

data g2044a(label='Dataset 5'); x=5; run;
data g2044o; length text $40; ds=open('g2044a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;

data _null_; if 0 then set g2044o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2044 rows=' rows;
else do; set g2044o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2044';
else put 'ERROR: ROUND5_FAIL=G2044 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2044:; quit;
