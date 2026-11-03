/* J3993 failure_format_reversed_range, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:295 */

proc format; value j3993fmt 5-4='reversed'; run;
proc catalog catalog=work.formats; delete j3993fmt.format; quit;

proc datasets library=work nolist; delete j3993:; quit;
