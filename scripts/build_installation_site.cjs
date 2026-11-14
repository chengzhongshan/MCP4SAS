'use strict';
// The video stays in release assets rather than being duplicated in Git history.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),source=path.join(root,'docs','installation');
const value=flag=>{const i=process.argv.indexOf(flag);return i<0?undefined:process.argv[i+1];};
const out=path.resolve(value('--out')||path.join(root,'_site'));
const manifest=JSON.parse(fs.readFileSync(path.join(source,'video.json'),'utf8'));
if(!/^[A-Za-z0-9_.-]+\.mp4$/.test(manifest.file)||!/^[a-f0-9]{64}$/.test(manifest.sha256))throw Error('Invalid video manifest');
fs.mkdirSync(out,{recursive:true});
let video=value('--video-file');
if(!video){
  const staging=path.join(out,'release-source');fs.mkdirSync(staging,{recursive:true});
  cp.execFileSync('gh',['release','download',manifest.release_tag,'--repo','chengzhongshan/MCP4SAS','--pattern',manifest.file,'--dir',staging,'--clobber'],{stdio:'inherit'});
  video=path.join(staging,manifest.file);
}
const bytes=fs.readFileSync(video),sha=crypto.createHash('sha256').update(bytes).digest('hex');
if(sha!==manifest.sha256||bytes.length!==manifest.bytes)throw Error('Release video does not match the approved manifest');
fs.copyFileSync(video,path.join(out,'installation.mp4'));
for(const name of ['index.html','style.css','player.js','homepage.jpg','preview.png','video.json'])fs.copyFileSync(path.join(source,name),path.join(out,name));
// Leave release-source out of the published artifact: it is a transient duplicate.
// Only the exact file created by this build is unlinked; no recursive deletion.
const downloaded=path.join(out,'release-source',manifest.file);
if(!value('--video-file')&&fs.existsSync(downloaded)){fs.unlinkSync(downloaded);fs.rmdirSync(path.dirname(downloaded));}
fs.writeFileSync(path.join(out,'.nojekyll'),'');
console.log(JSON.stringify({output:out,video_bytes:bytes.length,sha256:sha,validation:'passed'},null,2));
