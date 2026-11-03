/* G2064 call_set_bindings, N=5; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2064a; do row=1 to 5; x=3*row; output; end; run;
data g2064o; if 0 then set g2064a; ds=open('g2064a','i'); call set(ds); rc=fetchobs(ds,5); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2064o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2064 rows=' rows;
else do; set g2064o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND5_PASS=G2064';
else put 'ERROR: ROUND5_FAIL=G2064 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2064:; quit;
