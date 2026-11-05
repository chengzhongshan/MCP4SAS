/* K4540 failure_invalid_sysevalf_conversion, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1495 */

%let k4540v=%sysevalf(11+0.5,not_a_conversion); %symdel k4540v / nowarn;

proc datasets library=work nolist; delete k4540:; quit;
