/* M4015 block_comment_controls; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
/* %local hidden; %do i=1 %to 2; %end; %if 1 %then %put bad; */
data m4015o; actual=25; run;

data _null_; if 0 then set m4015o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4015 rows=' rows;
else do; set m4015o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND9_PASS=M4015';
else put 'ERROR: ROUND9_FAIL=M4015 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4015:; quit;
