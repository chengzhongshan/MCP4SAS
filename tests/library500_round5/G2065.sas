/* G2065 call_set_bindings, N=6; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2065a; do row=1 to 6; x=3*row; output; end; run;
data g2065o; if 0 then set g2065a; ds=open('g2065a','i'); call set(ds); rc=fetchobs(ds,6); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2065o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2065 rows=' rows;
else do; set g2065o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND5_PASS=G2065';
else put 'ERROR: ROUND5_FAIL=G2065 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2065:; quit;
