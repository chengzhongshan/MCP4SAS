/* J3996 failure_format_reversed_range, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3996fmt 8-7='reversed'; run;
proc catalog catalog=work.formats; delete j3996fmt.format; quit;

proc datasets library=work nolist; delete j3996:; quit;
