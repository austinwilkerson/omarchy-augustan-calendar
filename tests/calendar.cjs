const fs = require('node:fs'), vm = require('node:vm'), assert = require('node:assert/strict');
const c = vm.createContext({Date}); vm.runInContext(fs.readFileSync('Model.js','utf8'),c);
for (const [date, expected] of [['2023-12-25',[2023,9,5]],['2023-12-26',[2023,9,6]],['2023-12-27',[2024,0,1]],['2024-12-25',[2024,9,5]],['2024-12-26',[2025,0,1]]]) {
 const p=c.parts(new Date(date+'T12:00:00')); assert.deepEqual([p.year,p.monthIndex,p.day],expected);
}
for(let y=1999;y<=2401;y++) for(let m=0;m<10;m++) for(let d=1;d<=c.daysInMonth(y,m);d++) {
 const p=c.parts(c.gregorian(y,m,d));assert.deepEqual([p.year,p.monthIndex,p.day],[y,m,d]);
}
assert.equal(c.time(new Date(2024,0,1,12)), '05:00:00');
assert.equal(c.time(new Date(2024,0,1,23,59,59,999)), '09:99:99');
console.log('Calendar round trips, leap boundaries, and decimal time passed.');
vm.runInContext(fs.readFileSync('Quotes.js','utf8'),c);
assert.equal(c.plain('<img src="https://example.invalid">&'), '&lt;img src="https://example.invalid"&gt;&amp;');
let mode='date-time', seen=new Set();
for(let i=0;i<8;i++){seen.add(mode);mode=c.nextFormat(mode)}
assert.equal(seen.size,8); assert.equal(mode,'date-time');
assert.equal(c.label(new Date(2026,0,1,12),'percent'),'50.0%');
assert.equal(c.label(new Date(2026,0,1,12),'time'),'05:00');
assert.equal(c.theme(0,1),'Spirit');assert.equal(c.theme(0,5),'Soul');assert.equal(c.theme(0,6),'Mind');assert.equal(c.theme(0,10),'Body');assert.equal(c.theme(0,4),'');
assert.equal(c.theme(9,5),''); assert.equal(c.theme(9,6),'');
for(let m=0;m<10;m++)for(let d=1;d<=40;d++){
 const theme=c.theme(m,d),quote=c.forDay(2026,m,d,theme);
 if(!theme)assert.equal(quote,null);else assert.ok(quote.text && quote.author);
}
assert.equal(c.holidays(3,1).includes('Easter and Passover'),true);
assert.equal(c.holidays(9,6).includes('Leap Day'),true);
assert.equal(c.yearProgress(new Date(2023,11,26,0)),365/366);
assert.equal(c.yearProgress(new Date(2023,11,27,0)),0);
assert.equal(c.stepMonth(2026,9,1).year,2027); assert.equal(c.stepMonth(2026,0,-1).month,9);
console.log('Formats, themes, quote visibility, observances, navigation and safe text passed.');
