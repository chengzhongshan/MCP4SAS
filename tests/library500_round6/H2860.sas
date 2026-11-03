/* H2860 frewind_read_again, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename rtemp temp;
data _null_; file rtemp; put '11'; put '12'; run;
data h2860o; length line $40; fid=fopen('rtemp','i'); rc=fread(fid); rc=fread(fid); rc=frewind(fid); rc=fread(fid); rc=fget(fid,line); actual=input(line,best32.); rc=fclose(fid); run;
filename rtemp clear;

data _null_; if 0 then set h2860o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2860 rows=' rows;
else do; set h2860o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2860';
else put 'ERROR: ROUND6_FAIL=H2860 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2860:; quit;
