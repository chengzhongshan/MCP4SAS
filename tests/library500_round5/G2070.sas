/* G2070 call_set_bindings, N=11; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2070a; do row=1 to 11; x=3*row; output; end; run;
data g2070o; if 0 then set g2070a; ds=open('g2070a','i'); call set(ds); rc=fetchobs(ds,11); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2070o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2070 rows=' rows;
else do; set g2070o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND5_PASS=G2070';
else put 'ERROR: ROUND5_FAIL=G2070 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2070:; quit;
