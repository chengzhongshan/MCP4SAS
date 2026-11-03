/* T1061 open_varlabel_quote, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1061a; value=2; label value="Owner's field 2"; run;
data t1061o; length label $80; ds=open('t1061a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1061o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1061 rows=' rows;
else do; set t1061o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1061';
else put 'ERROR: ROUND3_FAIL=T1061 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1061:; quit;
