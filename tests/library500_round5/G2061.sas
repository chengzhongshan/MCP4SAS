/* G2061 call_set_bindings, N=2; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2061a; do row=1 to 2; x=3*row; output; end; run;
data g2061o; if 0 then set g2061a; ds=open('g2061a','i'); call set(ds); rc=fetchobs(ds,2); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2061o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2061 rows=' rows;
else do; set g2061o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2061';
else put 'ERROR: ROUND5_FAIL=G2061 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2061:; quit;
