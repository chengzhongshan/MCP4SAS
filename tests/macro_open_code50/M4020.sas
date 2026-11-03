/* M4020 integer_eval_open_code; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:481 */
%let m4020v=%eval((7+3)*2);
data m4020o; actual=&m4020v; run; %symdel m4020v;

data _null_; if 0 then set m4020o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4020 rows=' rows;
else do; set m4020o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND9_PASS=M4020';
else put 'ERROR: ROUND9_FAIL=M4020 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4020:; quit;
