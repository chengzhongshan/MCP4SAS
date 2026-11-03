/* T1069 open_varlabel_quote, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1069a; value=10; label value="Owner's field 10"; run;
data t1069o; length label $80; ds=open('t1069a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1069o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1069 rows=' rows;
else do; set t1069o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1069';
else put 'ERROR: ROUND3_FAIL=T1069 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1069:; quit;
