/* M4016 macro_comment_controls; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%* %local hidden;
%* %goto nowhere;
data m4016o; actual=26; run;

data _null_; if 0 then set m4016o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4016 rows=' rows;
else do; set m4016o; if not missing(actual) and abs(actual-(26))<=1e-9*max(1,abs(26)) then put 'ROUND9_PASS=M4016';
else put 'ERROR: ROUND9_FAIL=M4016 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4016:; quit;
