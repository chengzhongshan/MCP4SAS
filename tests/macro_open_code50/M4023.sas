/* M4023 macro_name_delimiter; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:104 */
%let m4023v=part;
data m4023o; text="&m4023v._suffix"; actual=(text='part_suffix'); run; %symdel m4023v;

data _null_; if 0 then set m4023o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4023 rows=' rows;
else do; set m4023o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND9_PASS=M4023';
else put 'ERROR: ROUND9_FAIL=M4023 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4023:; quit;
