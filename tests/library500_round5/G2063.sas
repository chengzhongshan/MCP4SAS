/* G2063 call_set_bindings, N=4; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2063a; do row=1 to 4; x=3*row; output; end; run;
data g2063o; if 0 then set g2063a; ds=open('g2063a','i'); call set(ds); rc=fetchobs(ds,4); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2063o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2063 rows=' rows;
else do; set g2063o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2063';
else put 'ERROR: ROUND5_FAIL=G2063 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2063:; quit;
