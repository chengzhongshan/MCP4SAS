/* G2066 call_set_bindings, N=7; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data g2066a; do row=1 to 7; x=3*row; output; end; run;
data g2066o; if 0 then set g2066a; ds=open('g2066a','i'); call set(ds); rc=fetchobs(ds,7); actual=x; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2066o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2066 rows=' rows;
else do; set g2066o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2066';
else put 'ERROR: ROUND5_FAIL=G2066 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2066:; quit;
