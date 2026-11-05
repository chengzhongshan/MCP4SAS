/* K4535 failure_invalid_sysevalf_conversion, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4535v=%sysevalf(6+0.5,not_a_conversion); %symdel k4535v / nowarn;

proc datasets library=work nolist; delete k4535:; quit;
