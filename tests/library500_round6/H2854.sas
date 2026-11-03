/* H2854 frewind_read_again, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename rtemp temp;
data _null_; file rtemp; put '5'; put '6'; run;
data h2854o; length line $40; fid=fopen('rtemp','i'); rc=fread(fid); rc=fread(fid); rc=frewind(fid); rc=fread(fid); rc=fget(fid,line); actual=input(line,best32.); rc=fclose(fid); run;
filename rtemp clear;

data _null_; if 0 then set h2854o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2854 rows=' rows;
else do; set h2854o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2854';
else put 'ERROR: ROUND6_FAIL=H2854 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2854:; quit;
