/* G2493 failure_format_overlap, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2493f 1-6='first' 4-8='second'; run;
data _null_; if cexist('work.formats.g2493f.format') then call execute('proc catalog catalog=work.formats; delete g2493f.format; quit;'); run;

proc datasets library=work nolist; delete g2493:; quit;
