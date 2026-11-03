/* M4013 nrstr_protects_open_controls; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1419 */
%let m4013v=%nrstr(%local hidden; %do i=1 %to 2; %end;);
data m4013o; actual=index(symget('m4013v'),'%local'); run; %symdel m4013v;

data _null_; if 0 then set m4013o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4013 rows=' rows;
else do; set m4013o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND9_PASS=M4013';
else put 'ERROR: ROUND9_FAIL=M4013 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4013:; quit;
