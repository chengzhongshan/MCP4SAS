/* New workflow V6267; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6267i;
length gene $80;
gene='allele01';ref=9;alt=36;output;
gene='allele02';ref=11;alt=39;output;
gene='allele03';ref=1;alt=20;output;
run;
%n26_calculate_binomial_P(dsdin=v6267i,dsdout=v6267o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=9);
data v6267m(keep=metric value);set v6267o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6267m;set v6267m;format value best32.;run;
proc export data=v6267m outfile="%sysfunc(pathname(work))/V6267.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6267;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6267:;quit;
