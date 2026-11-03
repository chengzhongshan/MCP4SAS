/* G2062 call_set_bindings, N=3; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2062a; do row=1 to 3; x=3*row; output; end; run;
data g2062o; if 0 then set g2062a; ds=open('g2062a','i'); call set(ds); rc=fetchobs(ds,3); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2062o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2062 rows=' rows;
else do; set g2062o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2062';
else put 'ERROR: ROUND5_FAIL=G2062 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2062:; quit;
