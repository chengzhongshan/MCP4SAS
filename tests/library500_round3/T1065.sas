/* T1065 open_varlabel_quote, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1065a; value=6; label value="Owner's field 6"; run;
data t1065o; length label $80; ds=open('t1065a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1065o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1065 rows=' rows;
else do; set t1065o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1065';
else put 'ERROR: ROUND3_FAIL=T1065 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1065:; quit;
