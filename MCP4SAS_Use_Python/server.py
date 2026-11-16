"""MCP server using the official Python SDK; stdio or loopback Streamable HTTP."""
import argparse
from urllib.parse import urlparse
from mcp.server.fastmcp import FastMCP
from mcp.types import CallToolResult,TextContent
from .jobs import Jobs

def create_server(host='127.0.0.1',port=8081,job_root=None):
    app=FastMCP('MCP4SAS-Python',host=host,port=port,json_response=True,log_level='WARNING')
    jobs=Jobs(job_root)
    def outcome(args,direct=False):
        seconds=args.pop('wait_seconds',0 if direct else 20)
        limit=args.pop('max_log_chars',16000)
        # Validate before creating a worker or submitting SAS.
        import math
        if isinstance(seconds,bool) or not isinstance(seconds,(int,float)) or not math.isfinite(seconds) or not 0<=seconds<=30:
            raise ValueError('wait_seconds must be a number between 0 and 30')
        if isinstance(limit,bool) or not isinstance(limit,int) or not 0<=limit<=1000000:
            raise ValueError('max_log_chars must be an integer between 0 and 1000000')
        result=jobs.wait(args['pid'],seconds,limit) if args.get('pid') is not None else jobs.submit({key:value for key,value in args.items() if value is not None},direct=direct)
        if result['status']=='RUNNING' and args.get('pid') is None and seconds>0:
            result=jobs.wait(result['pid'],seconds,limit)
        if result['status']=='RUNNING':
            result['poll_after_seconds']=5
        status=result['status']
        text=f"STATUS: {status}\nPID: {result.get('pid')}\n"
        if result.get('log_path'):
            text+='SAS log: '+result['log_path']+'\n'
        if status=='RUNNING':
            text+='Poll with the returned PID after about 5 seconds; use 30 seconds for known long analyses.\n'
        text+=result.get('text',result.get('message',''))
        return CallToolResult(content=[TextContent(type='text',text=text)],isError=status in ('FAILED','UNKNOWN'),structuredContent={key:value for key,value in result.items() if key!='text'})

    def run_sas_codes_or_files_in_ODA(
        sas_codes_or_file:str|None=None,output_file:str|None=None,
        upload_file:str|list[str]|None=None,download_file:str|list[str]|None=None,
        download_local_path:str|list[str]|None=None,delete_file:str|list[str]|None=None,
        delete_file_rgx:str|list[str]|None=None,delete_dir:str='~',
        delete_directory_rgx:str|list[str]|None=None,delete_directory_dry_run:bool=False,
        file_info:str|list[str]|None=None,classify_sas_log:str|None=None,
        dir4listing:str|None=None,archive_transfers:bool|str=True,skip_upload_if_same:bool|str=True,
        cleanup_empty_output_dir:bool|str=True,persistent:bool|str=True,session_id:str='mysession',
        saspy_cfgname:str|None=None,saspy_cfgfile:str|None=None,macro_dir:str|None=None,
        dir4local_sas_home:str|None=None,check_saspy_connection_only:bool=False,
        run_timeout_seconds:int=3600,no_run_timeout:bool=False,kill_saspy_sessions:bool=False,
        pid:int|None=None,wait_seconds:float=20,max_log_chars:int=16000,
    )->CallToolResult:
        """Run SAS with native Python/SASPy, local macro/file discovery and ZIP batching.

        Waits up to 20 seconds for verified completion; longer jobs return a PID.
        Set wait_seconds=0 for immediate background delivery. Full logs are saved;
        max_log_chars limits the returned excerpt (0 requests the full log).
        Credentials belong in a private terminal/config,
        never in AI chat. SAS-supplied macro functions do not trigger uploads.
        """
        arguments=locals().copy()
        arguments.pop('outcome',None)
        return outcome(arguments)

    def run_local_sas_without_saspy(sas_codes_or_file:str|None=None,sas_executable:str|None=None,output_file:str|None=None,run_timeout_seconds:int=3600,pid:int|None=None)->CallToolResult:
        """Execute a fresh local SAS batch process, without SASPy or session reuse."""
        arguments=locals().copy()
        arguments.pop('outcome',None)
        return outcome(arguments,direct=True)

    app.add_tool(run_sas_codes_or_files_in_ODA)
    app.add_tool(run_sas_codes_or_files_in_ODA,name='run_sas_codes_or_script_in_ODA',description='Compatibility alias for the native Python SASPy runner.')
    app.add_tool(run_local_sas_without_saspy)
    app.add_tool(run_local_sas_without_saspy,name='run_sas_codes_or_script_on_local_Windows',description='Compatibility alias for fresh local SAS batch execution on Windows/Linux.')
    return app

def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode',nargs='?',choices=['stdio','daemon'],default='stdio')
    parser.add_argument('--transport',choices=['stdio','streamable-http'])
    parser.add_argument('--host',default='127.0.0.1')
    parser.add_argument('--port',type=int,default=8081)
    parser.add_argument('-l','--listen')
    parser.add_argument('-m',dest='legacy_mode',help=argparse.SUPPRESS)
    args=parser.parse_args(argv)
    if args.listen:
        url=urlparse(args.listen)
        if url.scheme!='http' or url.path not in ('','/'):
            parser.error('Use a loopback HTTP listen URL; the MCP endpoint is /mcp')
        args.host,args.port=url.hostname,url.port or 8081
    if args.host not in ('127.0.0.1','localhost','::1'):
        parser.error('This local code-execution server binds only to loopback')
    app=create_server(args.host,args.port)
    app.run(transport=args.transport or ('streamable-http' if args.mode=='daemon' else 'stdio'))

if __name__=='__main__':
    main()
