/* T1067 open_varlabel_quote, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1067a; value=8; label value="Owner's field 8"; run;
data t1067o; length label $80; ds=open('t1067a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1067o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1067 rows=' rows;
else do; set t1067o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1067';
else put 'ERROR: ROUND3_FAIL=T1067 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1067:; quit;
