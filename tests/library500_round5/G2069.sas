/* G2069 call_set_bindings, N=10; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2069a; do row=1 to 10; x=3*row; output; end; run;
data g2069o; if 0 then set g2069a; ds=open('g2069a','i'); call set(ds); rc=fetchobs(ds,10); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2069o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2069 rows=' rows;
else do; set g2069o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND5_PASS=G2069';
else put 'ERROR: ROUND5_FAIL=G2069 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2069:; quit;
