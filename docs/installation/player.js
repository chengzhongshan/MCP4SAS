'use strict';
const video=document.getElementById('movie'),cover=document.getElementById('start'),status=document.getElementById('player-status');
window.firstFramePresented=false;
function reveal(){window.firstFramePresented=true;requestAnimationFrame(()=>requestAnimationFrame(()=>{cover.hidden=true}));}
async function start(seconds){
  cover.disabled=true;cover.querySelector('span').textContent='Loading video...';
  if(typeof seconds==='number'){
    if(video.readyState>=1)video.currentTime=seconds;
    else video.addEventListener('loadedmetadata',()=>{video.currentTime=seconds},{once:true});
  }
  if(!cover.hidden){
    if(video.requestVideoFrameCallback)video.requestVideoFrameCallback(reveal);
    else if(video.readyState>=2)reveal();
    else video.addEventListener('loadeddata',reveal,{once:true});
  }
  try{await video.play();status.textContent='Captions are included in the video. Use the chapter links to jump to another step.';}
  catch{cover.disabled=false;cover.querySelector('span').textContent='Play installation video';status.textContent='If playback is unavailable, use Download MP4 or Watch offline below.';}
}
cover.addEventListener('click',()=>start());
document.querySelectorAll('.chapters a[data-time]').forEach(link=>link.addEventListener('click',event=>{
  event.preventDefault();start(Number(link.dataset.time));video.scrollIntoView({behavior:'smooth',block:'center'});
}));
video.addEventListener('error',()=>{cover.disabled=false;status.textContent='The video could not be loaded. Use Download MP4 or Watch offline below.';});
