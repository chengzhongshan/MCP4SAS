/* J3994 failure_format_reversed_range, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3994fmt 6-5='reversed'; run;
proc catalog catalog=work.formats; delete j3994fmt.format; quit;

proc datasets library=work nolist; delete j3994:; quit;
