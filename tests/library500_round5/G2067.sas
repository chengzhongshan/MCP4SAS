/* G2067 call_set_bindings, N=8; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2067a; do row=1 to 8; x=3*row; output; end; run;
data g2067o; if 0 then set g2067a; ds=open('g2067a','i'); call set(ds); rc=fetchobs(ds,8); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2067o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2067 rows=' rows;
else do; set g2067o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND5_PASS=G2067';
else put 'ERROR: ROUND5_FAIL=G2067 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2067:; quit;
