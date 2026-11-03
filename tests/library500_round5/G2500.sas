/* G2500 failure_format_overlap, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value g2500f 1-13='first' 11-22='second'; run;
data _null_; if cexist('work.formats.g2500f.format') then call execute('proc catalog catalog=work.formats; delete g2500f.format; quit;'); run;

proc datasets library=work nolist; delete g2500:; quit;
