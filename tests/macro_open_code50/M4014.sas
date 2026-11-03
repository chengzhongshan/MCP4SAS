/* M4014 single_quoted_controls_are_data; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
data m4014o; text='%local hidden; %goto missing; %mend;'; actual=index(text,'%goto'); run;

data _null_; if 0 then set m4014o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4014 rows=' rows;
else do; set m4014o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND9_PASS=M4014';
else put 'ERROR: ROUND9_FAIL=M4014 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4014:; quit;
