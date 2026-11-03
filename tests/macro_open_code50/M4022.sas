/* M4022 superq_protects_mnemonic; source: SAS Macro Programming Made Easy, Second Edition.txt:1686 */
%let m4022v=AND; %let m4022same=%eval(%superq(m4022v)=%str(AND));
data m4022o; actual=&m4022same; run; %symdel m4022v m4022same;

data _null_; if 0 then set m4022o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4022 rows=' rows;
else do; set m4022o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND9_PASS=M4022';
else put 'ERROR: ROUND9_FAIL=M4022 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4022:; quit;
