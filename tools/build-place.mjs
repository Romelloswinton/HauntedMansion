// Rebuild the native Studio place from source: node tools/build-place.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const project = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const escape = text => String(text).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
let nextId = 0;
const p = (type, name, value) => `<${type} name="${name}">${value}</${type}>`;
const str = (name, value) => p('string', name, escape(value));
const bool = (name, value) => p('bool', name, value ? 'true' : 'false');
const num = (name, value) => p('float', name, value);
const vec = (name, x, y, z) => p('Vector3', name, `<X>${x}</X><Y>${y}</Y><Z>${z}</Z>`);
const rgb = (name, r, g, b) => p('Color3', name, `<R>${r/255}</R><G>${g/255}</G><B>${b/255}</B>`);
const color = (r,g,b) => p('Color3uint8', 'Color3uint8', (255 * 16777216 + r * 65536 + g * 256 + b));
const frame = (x,y,z) => p('CoordinateFrame', 'CFrame', `<X>${x}</X><Y>${y}</Y><Z>${z}</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22>`);
const item = (cls, name, properties='', children='', id=`RBX${++nextId}`) => `<Item class="${cls}" referent="${id}"><Properties>${str('Name',name)}${properties}</Properties>${children}</Item>`;
const solids = [];
function part(name, size, pos, tint=[79,68,63], options={}) {
    if(options.collide !== false && options.track !== false) solids.push({name,size,pos});
    const props = bool('Anchored',true) + bool('CanCollide',options.collide !== false)
        + bool('CanTouch',false) + vec('size',...size) + frame(...pos) + color(...tint)
        + p('token','Material',options.material || 512) + num('Transparency',options.transparency || 0)
        + p('token','TopSurface',0) + p('token','BottomSurface',0) + bool('CastShadow',options.shadow !== false);
    return item(options.className || 'Part',name,props + (options.extra || ''),options.children || '');
}
const textSize = (name,xScale,xOffset,yScale,yOffset) => p('UDim2',name,`<XS>${xScale}</XS><XO>${xOffset}</XO><YS>${yScale}</YS><YO>${yOffset}</YO>`);
function sign(name, text, position, size=[11,2.4,0.4]) {
    const label = item('TextLabel','Label',str('Text',text)+textSize('Size',1,0,1,0)+num('BackgroundTransparency',1)+rgb('TextColor3',224,211,172)+bool('TextScaled',true)+bool('TextWrapped',true)+p('token','Font',19));
    const surface = item('SurfaceGui','Lettering',p('token','Face',2)+num('PixelsPerStud',35)+p('token','SizingMode',1),label);
    return part(name,size,position,[26,28,28],{material:272,children:surface});
}
let mansion = '';
mansion += part('Floor',[122,1,98],[0,-0.5,0],[71,55,44],{material:528});
mansion += part('Ceiling',[122,1,98],[0,14.5,0],[27,29,33],{material:272,transparency:0.8,track:false});
for(const x of [-60,60]) mansion += part('ExteriorWall',[1.5,14,98],[x,7,0],[67,71,65]);
for(const z of [-48,48]) mansion += part('ExteriorWall',[120,14,1.5],[0,7,z],[67,71,65]);
// Door openings along both sides of the central hall.
for(const x of [-10,10]) {
    for(const [start,end] of [[-48,-37],[-27,-5],[5,27],[37,48]]) {
        mansion += part('HallWall',[1,14,end-start],[x,7,(start+end)/2],[81,71,64]);
    }
    for(const z of [-32,0,32]) {
        mansion += part('DoorLintel',[1,4,10],[x,12,z],[62,45,37]);
        for(const edge of [-5,5]) mansion += part('DoorTrim',[1.6,10,0.4],[x,5,z+edge],[43,30,25]);
    }
}
// Side rooms connect to each other as well as the central hall.
for(const side of [-1,1]) for(const z of [-16,16]) {
    for(const [lo,hi] of [[10,30],[40,60]]) {
        mansion += part('RoomPartition',[hi-lo,14,1],[side*(lo+hi)/2,7,z],[68,61,59]);
    }
    mansion += part('SideDoorLintel',[10,4,1],[side*35,12,z],[62,45,37]);
}
mansion += part('HallRunner',[14,0.08,89],[0,0.04,0],[88,30,34],{material:272});
for(const x of [-6.8,6.8]) mansion += part('RunnerBorder',[0.16,0.1,89],[x,0.08,0],[149,110,60],{material:272});
// Furniture breaks line of sight without obstructing both exits.
const rooms = [
    {name:'LIBRARY',x:-35,z:-32,tint:[47,57,52]},
    {name:'DINING ROOM',x:35,z:-32,tint:[64,47,49]},
    {name:'DRAWING ROOM',x:-35,z:0,tint:[48,54,62]},
    {name:'KITCHEN',x:35,z:0,tint:[65,65,55]},
    {name:'STORAGE',x:-35,z:32,tint:[62,50,45]},
    {name:'GUEST ROOM',x:35,z:32,tint:[50,49,62]},
];
for(const room of rooms) {
    mansion += part('RoomRug',[26,0.08,18],[room.x,0.06,room.z],room.tint,{material:272});
    mansion += sign(room.name,room.name,[room.x,11,room.z-14]);
    // Lamps give warm pools of light, windows cast a cold glow.
    const light = item('PointLight','WarmLight',rgb('Color',255,205,145)+num('Brightness',1.8)+num('Range',34)+bool('Shadows',true));
    mansion += part('CeilingLamp',[2.4,0.4,2.4],[room.x,12.5,room.z],[246,203,135],{material:288,collide:false,children:light});
    const side = Math.sign(room.x);
    mansion += part('MoonlitWindow',[0.3,6,9],[side*59.1,8,room.z],[72,105,115],{material:288});
    for(const dz of [-4.7,0,4.7]) mansion += part('WindowFrame',[0.6,6.7,0.35],[side*58.9,8,room.z+dz],[28,27,28]);
}
function shelf(x,z) {
    mansion += part('BookcaseBack',[3,10,12],[x,5,z],[37,29,24]);
    for(const y of [1,4,7,10]) {
        mansion += part('Shelf',[4,0.3,12],[x+1,y,z],[71,44,27]);
        if(y<10) for(let i=0;i<8;i++) mansion += part('Book',[1.4,2.2,0.7],[x+2,y+1.25,z-4.5+i*1.25],[[99,39,37],[47,71,70],[113,88,46]][i%3]);
    }
}
shelf(-51,-32); shelf(-23,-38);
// Dining table and chairs.
mansion += part('DiningTable',[22,1,9],[35,3.5,-32],[66,38,25]);
for(const x of [26,44]) for(const z of [-35,-29]) mansion += part('TableLeg',[1,3,1],[x,1.5,z],[41,29,25]);
for(const x of [26,35,44]) for(const z of [-40,-24]) {
    mansion += part('ChairSeat',[3,0.6,3],[x,2,z],[70,42,29]);
    mansion += part('ChairBack',[3,4,0.5],[x,3,z+(z<-32?-1.3:1.3)],[58,35,27]);
}
// Drawing room: couch, high screens, low table.
mansion += part('SofaSeat',[18,2,6],[-39,1.8,-6],[67,40,45]);
mansion += part('SofaBack',[18,5,1.4],[-39,3,-8.5],[54,31,37]);
for(const x of [-48,-30]) mansion += part('SofaArm',[1,3,6],[x,2,-6],[54,31,37]);
mansion += part('CoffeeTable',[10,2.4,6],[-35,1.2,4],[53,34,23]);
mansion += part('FoldingScreen',[1,8,11],[-21,4,3],[49,53,47]);
// Kitchen counters and pantry screen.
mansion += part('Counter',[24,4,5],[35,2,-11],[101,98,88]);
mansion += part('CounterTop',[25,0.4,6],[35,4.2,-11],[31,32,34],{material:272});
mansion += part('KitchenIsland',[14,4,7],[38,2,3],[75,70,56]);
mansion += part('Pantry',[6,10,8],[53,5,7],[55,50,40]);
// Crates create a simple hiding maze in storage.
for(const [x,z,w,h,d] of [[-49,26,9,7,8],[-25,27,9,9,6],[-40,37,12,6,8],[-22,40,6,5,7]]) {
    mansion += part('StorageCrate',[w,h,d],[x,h/2,z],[78,55,35]);
    mansion += part('CrateBand',[w+0.1,0.35,d+0.1],[x,h*0.7,z],[34,29,26]);
}
mansion += part('BedFrame',[12,2,17],[40,1,34],[46,31,25]);
mansion += part('Mattress',[11,1.4,16],[40,2.5,34],[136,129,113],{material:272});
mansion += part('Headboard',[12,7,1],[40,3.5,42],[53,35,28]);
mansion += part('Wardrobe',[8,11,5],[22,5.5,39],[53,38,30]);
mansion += part('GuestScreen',[1,8,11],[50,4,28],[54,48,60]);
// Hall lamps and portraits.
for(const z of [-42,-16,16,42]) {
    mansion += part('HallLight',[2,0.4,2],[0,12.5,z],[235,190,128],{material:288,collide:false,
        children:item('PointLight','Glow',rgb('Color',255,204,155)+num('Brightness',1.5)+num('Range',26))});
}
mansion += sign('MansionName','MIDNIGHT MANOR',[0,10,-46.8],[16,3,0.4]);
mansion += part('SealedFrontDoor',[9,10,0.8],[0,5,47],[37,24,21]);
let world = item('Model','Mansion','',mansion);
// Invisible spawn markers are editable in Studio's Explorer.
const spawnCoords = [[-48,-41],[-20,-27],[22,-42],[49,-42],[-48,8],[22,8],[-50,41],[22,25],[51,42]];
world += item('Folder','SurvivorSpawns','',spawnCoords.map(([x,z],i)=>part(String(i+1).padStart(2,'0'),[2,0.2,2],[x,0.2,z],[100,200,100],{collide:false,transparency:1})).join(''));
world += part('EntranceSpawn',[2,0.2,2],[0,0.2,40],[180,60,60],{collide:false,transparency:1});
world += part('KillerSpawn',[2,0.2,2],[0,0.2,163],[180,60,60],{collide:false,transparency:1});
let lobby = part('LobbyFloor',[60,1,44],[0,-0.5,150],[40,46,50],{material:816,track:false});
for(const x of [-30,30]) lobby += part('LobbyWall',[1,14,44],[x,7,150],[48,51,55],{track:false});
for(const z of [128,172]) lobby += part('LobbyWall',[60,14,1],[0,7,z],[48,51,55],{track:false});
lobby += sign('LobbyTitle','MIDNIGHT MANOR',[0,10,128.7],[35,4,0.3]);
lobby += sign('LobbyRules','ONE HUNTER. NINE SURVIVORS.\nSURVIVE FIVE MINUTES.\nONE SURVIVOR REMAINING = TEAM VICTORY.',[0,5,128.7],[35,5,0.3]);
world += item('Model','Lobby','',lobby);
world += part('LobbySpawn',[6,0.4,6],[0,0.2,145],[79,114,107],{className:'SpawnLocation',material:272,track:false,
    extra:bool('Neutral',true)+p('int','Duration',0)+bool('AllowTeamChangeOnTouch',false)});
// Camera points down into the cutaway mansion in edit mode.
const camPos=[98,105,125], target=[0,0,0];
const norm=a=>{const length=Math.hypot(...a);return a.map(v=>v/length);};
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
const back=norm(camPos.map((v,i)=>v-target[i])), right=norm(cross([0,1,0],back)), up=cross(back,right);
let cameraFrame=`<X>${camPos[0]}</X><Y>${camPos[1]}</Y><Z>${camPos[2]}</Z>`;
for(let row=0;row<3;row++) for(let col=0;col<3;col++) cameraFrame+=`<R${row}${col}>${[right,up,back][col][row]}</R${row}${col}>`;
world += item('Camera','Camera',p('CoordinateFrame','CFrame',cameraFrame)+p('token','CameraType',5),'','RBXCamera');
const scriptSource = (cls,name,file) => item(cls,name,p('ProtectedString','Source',escape(fs.readFileSync(path.join(project,'src',file),'utf8'))));
const server = scriptSource('ModuleScript','RoundRules','RoundRules.luau') + scriptSource('Script','MansionServer','GameServer.server.luau');
const client = scriptSource('LocalScript','MansionClient','GameClient.client.luau');
const services = item('Workspace','Workspace',p('Ref','CurrentCamera','RBXCamera')+num('Gravity',196.2)+bool('StreamingEnabled',false),world)
    + item('Lighting','Lighting',num('ClockTime',0.5)+num('Brightness',2)+rgb('Ambient',78,83,99)+rgb('OutdoorAmbient',51,61,80)
        +rgb('FogColor',38,47,57)+num('FogStart',60)+num('FogEnd',300)+bool('GlobalShadows',true))
    + item('ReplicatedStorage','ReplicatedStorage','',item('Folder','MansionState'))
    + item('ServerScriptService','ServerScriptService','',server)
    + item('StarterPlayer','StarterPlayer',num('CameraMaxZoomDistance',18)+num('CameraMinZoomDistance',0.5),item('StarterPlayerScripts','StarterPlayerScripts','',client))
    + item('StarterGui','StarterGui') + item('Players','Players',bool('CharacterAutoLoads',true)+num('RespawnTime',3));
const xml=`<?xml version="1.0" encoding="utf-8"?><roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="4"><External>null</External><External>nil</External>${services}</roblox>`;
fs.writeFileSync(path.join(project,'Midnight-Manor.rbxlx'),xml);

// Check 3-stud-wide walking paths through the generated collision geometry.
// This is a map construction check, not a replacement for an engine playtest.
const blockers=solids.filter(s=>s.pos[1]+s.size[1]/2>0.5 && s.pos[1]-s.size[1]/2<5);
function clear(x,z) { return !blockers.some(s=>Math.abs(x-s.pos[0])<s.size[0]/2+1.5 && Math.abs(z-s.pos[2])<s.size[2]/2+1.5); }
const key=(x,z)=>`${x},${z}`;
const queue=[[0,40]], visited=new Set([key(0,40)]);
for(let i=0;i<queue.length;i++) {
    const [x,z]=queue[i];
    for(const [dx,dz] of [[2,0],[-2,0],[0,2],[0,-2]]) {
        const nx=x+dx,nz=z+dz,k=key(nx,nz);
        if(nx<=-59||nx>=59||nz<=-47||nz>=47||visited.has(k)||!clear(nx,nz)) continue;
        visited.add(k);queue.push([nx,nz]);
    }
}
for(const [x,z] of spawnCoords) {
    if(!clear(x,z)) throw Error(`Blocked survivor spawn ${x},${z}`);
    if(!queue.some(([qx,qz])=>Math.abs(qx-x)<=2&&Math.abs(qz-z)<=2)) throw Error(`Unreachable spawn ${x},${z}`);
}
for(const side of [-1,1]) for(const z of [-32,0,32]) {
    if(!visited.has(key(side*10,z))) throw Error(`Unreachable hallway doorway ${side*10},${z}`);
}
console.log(`Built Midnight-Manor.rbxlx: ${nextId} instances. All 9 survivor spawns and 6 hallway doorways reachable.`);
