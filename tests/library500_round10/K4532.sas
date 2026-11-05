/* K4532 failure_invalid_sysevalf_conversion, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4532v=%sysevalf(3+0.5,not_a_conversion); %symdel k4532v / nowarn;

proc datasets library=work nolist; delete k4532:; quit;
