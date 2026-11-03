/* H2858 frewind_read_again, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename rtemp temp;
data _null_; file rtemp; put '9'; put '10'; run;
data h2858o; length line $40; fid=fopen('rtemp','i'); rc=fread(fid); rc=fread(fid); rc=frewind(fid); rc=fread(fid); rc=fget(fid,line); actual=input(line,best32.); rc=fclose(fid); run;
filename rtemp clear;

data _null_; if 0 then set h2858o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2858 rows=' rows;
else do; set h2858o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2858';
else put 'ERROR: ROUND6_FAIL=H2858 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2858:; quit;
