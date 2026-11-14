import asyncio
import importlib.util
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
SDK=importlib.util.find_spec('mcp') is not None

@unittest.skipUnless(SDK,'Install the Python port requirements to exercise the actual MCP SDK')
class MCPServerTests(unittest.IsolatedAsyncioTestCase):
    async def check_session(self,session,directory):
        await session.initialize()
        tools=(await session.list_tools()).tools
        self.assertEqual({tool.name for tool in tools},{'run_sas_codes_or_files_in_ODA','run_sas_codes_or_script_in_ODA','run_local_sas_without_saspy','run_sas_codes_or_script_on_local_Windows'})
        tool=next(t for t in tools if t.name=='run_sas_codes_or_files_in_ODA')
        self.assertIn('sas_codes_or_file',tool.inputSchema['properties'])
        missing=await session.call_tool('run_sas_codes_or_files_in_ODA',dict(pid=99999999))
        self.assertTrue(missing.isError)
        self.assertEqual(missing.structuredContent['status'],'UNKNOWN')
        log=Path(directory)/'source.log'
        log.write_text('NOTE: completed\n',encoding='utf-8')
        result=await session.call_tool('run_sas_codes_or_files_in_ODA',dict(classify_sas_log=str(log),persistent=False))
        self.assertFalse(result.isError,result)
        pid=result.structuredContent['pid']
        for _ in range(100):
            done=await session.call_tool('run_sas_codes_or_files_in_ODA',dict(pid=pid))
            if done.structuredContent['status']!='RUNNING':
                break
            await asyncio.sleep(.1)
        self.assertEqual(done.structuredContent['status'],'COMPLETE',done)
        self.assertFalse(done.isError)
        self.assertIn('"exit_code": 0',done.content[0].text)
        failed=await session.call_tool('run_sas_codes_or_script_in_ODA',dict(sas_codes_or_file="data _null_; x='unclosed;",persistent=False))
        pid=failed.structuredContent['pid']
        for _ in range(100):
            done=await session.call_tool('run_sas_codes_or_script_in_ODA',dict(pid=pid))
            if done.structuredContent['status']!='RUNNING':
                break
            await asyncio.sleep(.1)
        self.assertTrue(done.isError)
        self.assertEqual(done.structuredContent['exit_code'],2)
        self.assertIn('preflight failed',done.content[0].text)

    async def test_stdio_discovery_background_status_and_failure(self):
        from mcp import ClientSession,StdioServerParameters
        from mcp.client.stdio import stdio_client
        with tempfile.TemporaryDirectory(prefix='mcp4sas-python-sdk-') as temp:
            env=dict(os.environ,MCP4SAS_PYTHON_STATE_DIR=str(Path(temp)/'state'))
            params=StdioServerParameters(command=sys.executable,args=[str(ROOT/'server.py')],cwd=temp,env=env)
            async with stdio_client(params) as (read,write):
                async with ClientSession(read,write) as session:
                    await self.check_session(session,temp)

    async def test_streamable_http_discovery_and_completion(self):
        from mcp import ClientSession
        from mcp.client.streamable_http import streamable_http_client
        import httpx
        with tempfile.TemporaryDirectory(prefix='mcp4sas-python-http-') as temp:
            with socket.socket() as probe:
                probe.bind(('127.0.0.1',0))
                port=probe.getsockname()[1]
            env=dict(os.environ,MCP4SAS_PYTHON_STATE_DIR=str(Path(temp)/'state'))
            with (Path(temp)/'http.log').open('wb') as log:
                process=subprocess.Popen([sys.executable,str(ROOT/'server.py'),'daemon','--port',str(port)],cwd=temp,env=env,stdout=log,stderr=log)
            try:
                url=f'http://127.0.0.1:{port}/mcp'
                async with httpx.AsyncClient() as client:
                    for _ in range(100):
                        if process.poll() is not None:
                            self.fail((Path(temp)/'http.log').read_text())
                        try:
                            await client.get(url,timeout=.5)
                            break
                        except httpx.TransportError:
                            await asyncio.sleep(.1)
                async with streamable_http_client(url) as (read,write,_):
                    async with ClientSession(read,write) as session:
                        await self.check_session(session,temp)
            finally:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()

if __name__=='__main__':
    unittest.main()
