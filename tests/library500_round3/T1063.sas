/* T1063 open_varlabel_quote, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1063a; value=4; label value="Owner's field 4"; run;
data t1063o; length label $80; ds=open('t1063a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1063o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1063 rows=' rows;
else do; set t1063o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1063';
else put 'ERROR: ROUND3_FAIL=T1063 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1063:; quit;
