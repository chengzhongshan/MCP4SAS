/* J3998 failure_format_reversed_range, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3998fmt 10-9='reversed'; run;
proc catalog catalog=work.formats; delete j3998fmt.format; quit;

proc datasets library=work nolist; delete j3998:; quit;
