// Public-domain texts. Exact editions and locations are recorded in SOURCES.md.
var collection = {
  Spirit: [
    {text:'Blessed are the peacemakers: for they shall be called the children of God.',author:'Jesus'},
    {text:'Nothing can bring you peace but yourself.',author:'Ralph Waldo Emerson'}
  ],
  Soul: [
    {text:'Be ye kind one to another, tenderhearted, forgiving one another.',author:'Paul'},
    {text:'The only way to have a friend is to be one.',author:'Ralph Waldo Emerson'}
  ],
  Mind: [
    {text:'Be not overcome of evil, but overcome evil with good.',author:'Paul'},
    {text:'Reading maketh a full man; conference a ready man; and writing an exact man.',author:'Francis Bacon'}
  ],
  Body: [
    {text:'Therefore glorify God in your body, and in your spirit, which are God’s.',author:'Paul'},
    {text:'Early to bed, and early to rise, makes a man healthy, wealthy, and wise.',author:'Benjamin Franklin'}
  ]
};
function forDay(year,month,day,theme) {
    var list=collection[theme];
    if(!list) return null;
    // Alternate across occurrences and years; reopening never shuffles a day's quote.
    return list[(year+month*4+Math.floor((day-1)/10))%list.length];
}
