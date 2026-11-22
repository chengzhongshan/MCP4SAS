/* Submit in a dedicated persistent test session. This deliberately compiles
   a legacy failing definition before the next runner submission. */
data work.mcp_macroparas_sentinel;
 sentinel=42;
run;
%macro macroparas(macrorgx=);
 %put ERROR: MCP4SAS_OLD_MACROPARAS_MUST_BE_REPLACED;
%mend;
/* Next submission (separate CLI call, same session):
   %macroparas(macrorgx=GTEx);proc print;run;
   Must use the bundled fallback, leave the sentinel intact and produce HTML.
   Third submission: check WORK.MCP_MACROPARAS_SENTINEL and WORK.MACRO_PARAS;
   matched count depends on the actual configured macro library. */
