/* H2852 frewind_read_again, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename rtemp temp;
data _null_; file rtemp; put '3'; put '4'; run;
data h2852o; length line $40; fid=fopen('rtemp','i'); rc=fread(fid); rc=fread(fid); rc=frewind(fid); rc=fread(fid); rc=fget(fid,line); actual=input(line,best32.); rc=fclose(fid); run;
filename rtemp clear;

data _null_; if 0 then set h2852o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2852 rows=' rows;
else do; set h2852o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2852';
else put 'ERROR: ROUND6_FAIL=H2852 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2852:; quit;
