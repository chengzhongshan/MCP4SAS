/* G2491 failure_format_overlap, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2491f 1-4='first' 2-4='second'; run;
data _null_; if cexist('work.formats.g2491f.format') then call execute('proc catalog catalog=work.formats; delete g2491f.format; quit;'); run;

proc datasets library=work nolist; delete g2491:; quit;
