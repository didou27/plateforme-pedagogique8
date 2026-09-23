const http=require('http');
const fs=require('fs');
const path=require('path');
const os=require('os');
const appDir=path.join(__dirname,'app');
const storageDir=path.join(__dirname,'storage');
const uploadsDir=path.join(storageDir,'uploads');
const stateFile=path.join(storageDir,'platform-data.json');
fs.mkdirSync(uploadsDir,{recursive:true});
const mime={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.json':'application/json; charset=utf-8','.png':'image/png','.jpg':'image/jpeg','.jpeg':'image/jpeg','.gif':'image/gif','.webp':'image/webp','.svg':'image/svg+xml','.ico':'image/x-icon','.pdf':'application/pdf','.xls':'application/vnd.ms-excel','.xlsx':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','.zip':'application/zip'};
function send(res,status,body,type='application/json; charset=utf-8'){res.writeHead(status,{'Content-Type':type,'Cache-Control':'no-store'});res.end(body)}
function readBody(req,max=25*1024*1024){return new Promise((resolve,reject)=>{const chunks=[];let size=0;req.on('data',c=>{size+=c.length;if(size>max){reject(new Error('Request too large'));req.destroy()}else chunks.push(c)});req.on('end',()=>resolve(Buffer.concat(chunks)));req.on('error',reject)})}
function safeKey(raw){return decodeURIComponent(raw||'').replace(/[^a-zA-Z0-9._-]/g,'_').slice(0,180)}
function safeAppPath(pathname){
 const relative=decodeURIComponent(pathname).replace(/^[/\\]+/,'');
 const target=path.resolve(appDir,relative);
 return target===appDir||target.startsWith(appDir+path.sep)?target:null;
}
function serveFile(req,res,target){
 res.writeHead(200,{'Content-Type':mime[path.extname(target).toLowerCase()]||'application/octet-stream'});
 if(req.method==='HEAD')return res.end();
 fs.createReadStream(target).pipe(res);
}
const server=http.createServer(async(req,res)=>{try{
 const url=new URL(req.url,'http://server.local');
 if(url.pathname==='/api/health')return send(res,200,JSON.stringify({ok:true,storage:stateFile}));
 if(url.pathname==='/api/state'&&req.method==='GET'){const data=fs.existsSync(stateFile)?fs.readFileSync(stateFile):Buffer.from('{}');return send(res,200,data)}
 if(url.pathname==='/api/state'&&req.method==='PUT'){const body=await readBody(req,5*1024*1024);JSON.parse(body.toString('utf8'));const tmp=stateFile+'.tmp';fs.writeFileSync(tmp,body);fs.renameSync(tmp,stateFile);return send(res,200,JSON.stringify({saved:true}))}
 if(url.pathname.startsWith('/api/files/')){const key=safeKey(url.pathname.slice('/api/files/'.length));if(!key)return send(res,400,JSON.stringify({error:'Missing file key'}));const target=path.join(uploadsDir,key);if(req.method==='PUT'){const body=await readBody(req,100*1024*1024);fs.writeFileSync(target,body);return send(res,200,JSON.stringify({saved:true,size:body.length}))}if(req.method==='GET'){if(!fs.existsSync(target))return send(res,404,JSON.stringify({error:'File not found'}));res.writeHead(200,{'Content-Type':'application/octet-stream','Content-Length':fs.statSync(target).size,'Cache-Control':'no-store'});return fs.createReadStream(target).pipe(res)}}
 if(url.pathname.startsWith('/api/'))return send(res,404,JSON.stringify({error:'API route not found'}));
 if(req.method!=='GET'&&req.method!=='HEAD')return send(res,405,'Method not allowed','text/plain');
 const requested=url.pathname==='/'?'/index.html':url.pathname;
 const target=safeAppPath(requested);
 if(!target)return send(res,403,'Forbidden','text/plain');
 if(fs.existsSync(target)&&fs.statSync(target).isFile())return serveFile(req,res,target);
 // Client-side routing fallback: deep links such as /teaching-hours or
 // /shared/:token are handled by the browser application.
 const indexFile=path.join(appDir,'index.html');
 if(fs.existsSync(indexFile))return serveFile(req,res,indexFile);
 return send(res,404,'Application not found: app/index.html is missing','text/plain');
 }catch(e){console.error(e);if(!res.headersSent)send(res,500,JSON.stringify({error:e.message}))}});
const port=Number(process.env.PORT||3000);
const host=process.env.HOST||'0.0.0.0';
server.listen(port,host,()=>{
 console.log(`\nPedagogical platform: http://localhost:${port}`);
 for(const entries of Object.values(os.networkInterfaces())){
  for(const entry of entries||[]){
   if(entry.family==='IPv4'&&!entry.internal)console.log(`Network access:       http://${entry.address}:${port}`);
  }
 }
 console.log(`Persistent data file: ${stateFile}`);
 console.log('Keep this terminal open while using the platform.\n');
});
