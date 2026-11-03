/* T1066 open_varlabel_quote, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1066a; value=7; label value="Owner's field 7"; run;
data t1066o; length label $80; ds=open('t1066a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1066o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1066 rows=' rows;
else do; set t1066o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1066';
else put 'ERROR: ROUND3_FAIL=T1066 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1066:; quit;
