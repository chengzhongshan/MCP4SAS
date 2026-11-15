/* Test-only namespaced definition from numargs.sas; original SHA256 043af703dfcf0981c0a11099c9136a77387ba968a2ecb320992aec735bdc78e4. */
%macro n26_numargs(arg);
   %if &arg= %then %do;
        0
      %end;
    %else %do;
       %let n=1;
       %do %until (%qscan(&arg,%eval(&n),%str( ))=%str()); 
         %let n=%eval(&n+1);
       %end;
       %eval(&n-1)
    %end;
%mend n26_numargs;
