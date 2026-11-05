// Civil date arithmetic uses UTC ordinals so daylight saving cannot shift dates.
var months = ['Petras','Jacobus','Ionus','Andreas','Philippos','Bartholomeus','Matteus','Judas','Simonus','Thomas'];
function isLeapYear(year) { return year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0); }
function yearStart(year) { return Date.UTC(year - 1, 11, isLeapYear(year) ? 27 : 26); }
function parts(date) {
    var civil = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
    var year = date.getFullYear();
    if (civil >= yearStart(year + 1)) year++;
    var offset = Math.floor((civil - yearStart(year)) / 86400000);
    return {year: year, monthIndex: Math.floor(offset / 40), day: offset % 40 + 1};
}
function daysInMonth(year, month) { return month === 9 ? (isLeapYear(year + 1) ? 6 : 5) : 40; }
function gregorian(year, month, day) {
    var utc = new Date(yearStart(year) + (month * 40 + day - 1) * 86400000);
    return new Date(utc.getUTCFullYear(), utc.getUTCMonth(), utc.getUTCDate(), 12);
}
function time(date) {
    var seconds = Math.floor((date.getHours()*3600000 + date.getMinutes()*60000 + date.getSeconds()*1000 + date.getMilliseconds()) / 864);
    function pad(n) { return ('0' + n).slice(-2); }
    return Math.floor(seconds/10000) + ':' + pad(Math.floor(seconds/100)%100) + ':' + pad(seconds%100);
}
var weekdays = ['Primeday','Biday','Triday','Quartaday','Pentaday','Hexaday','Septeday','Octoday','Noveday','Deceday'];
var headings = ['Prime','Bi','Tri','Quarta','Penta','Hexa','Septe','Octo','Nove','Dece'];
var formats = ['date-time','date-seconds','weekday-time','weekday-seconds','time','date-week-year','numeric','date-percent','percent'];
function formatIndex(value) { var i = formats.indexOf(value); return i < 0 ? 0 : i; }
function nextFormat(value) { return formats[(formatIndex(value)+1)%formats.length]; }
function dayFraction(date) { return (date.getHours()*3600000+date.getMinutes()*60000+date.getSeconds()*1000+date.getMilliseconds())/86400000; }
function percent(date) { return Math.min(99.9,Math.round(dayFraction(date)*1000)/10).toFixed(1)+'%'; }
var monthSystems = {
 disciple: months,
 numerical: ['Primember','Biember','Triember','Quartember','Pentember','Hexember','September','Octember','November','December'],
 seasonal: ['Winterma','Frostma','Springma','Bloomma','Greemma','Summama','Heatma','Harvestma','Autumnma','Coldma']
};
function monthName(index,system) { return (monthSystems[system] || months)[index]; }
function themeColor(theme) { return ({Spirit:'#6B8E23',Soul:'#4682B4',Mind:'#663399',Body:'#CD853F'})[theme] || 'transparent'; }
function label(date, format, system) {
    var p=parts(date), t=time(date), shortTime=t.slice(0,-3), name=monthName(p.monthIndex,system);
    var w=p.monthIndex===9 ? ['Feast','Soul','Mind','Body','Christmas','Leap Day'][p.day-1] : weekdays[(p.day-1)%10];
    var shortDay=p.monthIndex===9 ? w : headings[(p.day-1)%10];
    var d=name+' '+p.day;
    switch(format) {
    case 'date-seconds':return d+' '+t;
    case 'weekday-time':return w+' '+shortTime;
    case 'weekday-seconds':return w+' '+t;
    case 'time':return shortTime;
    case 'date-week-year':return p.day+' '+name+' '+(p.monthIndex===9?'':('W'+('0'+(p.monthIndex*4+Math.floor((p.day-1)/10)+1)).slice(-2)+' '))+p.year;
    case 'numeric':return p.year+'-'+('0'+(p.monthIndex+1)).slice(-2)+'-'+('0'+p.day).slice(-2)+' '+shortTime;
    case 'date-percent':return d+' '+percent(date);
    case 'percent':return percent(date);
    default:return d+' '+shortTime;
    }
}
function theme(month, day) {
    if(month===9) return ['Spirit','Soul','Mind','Body','',''][day-1] || '';
    return ({0:'Spirit',4:'Soul',5:'Mind',9:'Body'})[(day-1)%10] || '';
}
// Fixed Augustan observances follow the supplied 2024 pocket calendar.
function holidays(month,day) {
    var names=[];
    if(month<9 && day===1) names.push('High Holy Day');
    var fixed={'0:11':'Epiphany','2:40':'Crucifixion Remembered','3:1':'Easter and Passover','4:11':'Pentecost','9:1':'Feast of the Christ','9:4':'Christmas Eve','9:5':'Christmas','9:6':'Leap Day'};
    if(fixed[month+':'+day]) names.push(fixed[month+':'+day]);
    return names;
}
function yearProgress(date) {
    var p=parts(date);
    return (p.monthIndex*40+p.day-1+dayFraction(date))/(isLeapYear(p.year+1)?366:365);
}
function stepMonth(year,month,delta) {
    var total=year*10+month+delta;
    return {year:Math.floor(total/10),month:((total%10)+10)%10};
}
// Shared UI tooltips can be rich text, so neutralize markup before crossing that boundary.
function plain(value) { return String(value).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
