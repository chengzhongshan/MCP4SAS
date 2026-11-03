/* G2068 call_set_bindings, N=9; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2068a; do row=1 to 9; x=3*row; output; end; run;
data g2068o; if 0 then set g2068a; ds=open('g2068a','i'); call set(ds); rc=fetchobs(ds,9); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2068o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2068 rows=' rows;
else do; set g2068o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND5_PASS=G2068';
else put 'ERROR: ROUND5_FAIL=G2068 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2068:; quit;
