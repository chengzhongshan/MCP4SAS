/* K4537 failure_invalid_sysevalf_conversion, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4537v=%sysevalf(8+0.5,not_a_conversion); %symdel k4537v / nowarn;

proc datasets library=work nolist; delete k4537:; quit;
