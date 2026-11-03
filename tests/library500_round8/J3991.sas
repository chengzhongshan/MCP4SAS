/* J3991 failure_format_reversed_range, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3991fmt 3-2='reversed'; run;
proc catalog catalog=work.formats; delete j3991fmt.format; quit;

proc datasets library=work nolist; delete j3991:; quit;
