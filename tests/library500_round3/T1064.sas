/* T1064 open_varlabel_quote, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:78 */

data t1064a; value=5; label value="Owner's field 5"; run;
data t1064o; length label $80; ds=open('t1064a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;

data _null_; if 0 then set t1064o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1064 rows=' rows;
else do; set t1064o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1064';
else put 'ERROR: ROUND3_FAIL=T1064 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1064:; quit;
