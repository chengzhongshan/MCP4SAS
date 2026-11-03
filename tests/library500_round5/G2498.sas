/* G2498 failure_format_overlap, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2498f 1-11='first' 9-18='second'; run;
data _null_; if cexist('work.formats.g2498f.format') then call execute('proc catalog catalog=work.formats; delete g2498f.format; quit;'); run;

proc datasets library=work nolist; delete g2498:; quit;
