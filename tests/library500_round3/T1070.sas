/* T1070 open_varlabel_quote, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1070a; value=11; label value="Owner's field 11"; run;
data t1070o; length label $80; ds=open('t1070a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1070o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1070 rows=' rows;
else do; set t1070o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1070';
else put 'ERROR: ROUND3_FAIL=T1070 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1070:; quit;
