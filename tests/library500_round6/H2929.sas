/* H2929 syscall_dataset_binding, N=10; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2929a; h2929x=10; h2929y=11; run;
%let h2929ds=%sysfunc(open(h2929a,i)); %syscall set(h2929ds);
%let h2929rc=%sysfunc(fetchobs(&h2929ds,1));
data h2929o; actual=&h2929x+&h2929y; run;
%let h2929rc=%sysfunc(close(&h2929ds)); %symdel h2929ds h2929rc h2929x h2929y;

data _null_; if 0 then set h2929o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2929 rows=' rows;
else do; set h2929o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND6_PASS=H2929';
else put 'ERROR: ROUND6_FAIL=H2929 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2929:; quit;
