import fs from 'fs';
import moment from 'moment-timezone';
import 'moment-timezone/moment-timezone-utils';

const timeZones = [
    {
        id: 'tzData1',
        name: 'Etc/GMT-12'
    },
    {
        id:'tzData2',
        name:'US/Samoa'
    },
    {
        id:'tzData3',
        name: 'US/Hawaii'
    },
    {
        id: 'tzData4',
        name: 'Pacific/Marquesas'
    },
    {
        id: 'tzData5',
        name: 'US/Alaska'
    },
    {
        id: 'tzData6',
        name: 'America/Los_Angeles'
    },
    {
        id: 'tzData7',
        name: 'US/Arizona'
    },
    {
        id: 'tzData8',
        name: 'America/Denver'
    },
    {
        id: 'tzData9',
        name: 'America/Chicago'
    },
    {
        id: 'tzData10',
        name: 'America/New_York'
    },
    {
        id: 'tzData11',
        name: 'America/Port_of_Spain'
    },
    {
        id: 'tzData12',
        name: 'Canada/Newfoundland'
    },
    {
        id: 'tzData13',
        name: 'America/Buenos_Aires'
    },
    {
        id: 'tzData14',
        name: 'Atlantic/South_Georgia'
    },
    {
        id: 'tzData15',
        name: 'Atlantic/Azores'
    },
    {
        id: 'tzData16',
        name: 'UTC'
    },
    {
        id: 'tzData17',
        name: 'Europe/London'
    },
    {
        id: 'tzData18',
        name: 'Europe/Berlin'
    },
    {
        id: 'tzData19',
        name: 'Europe/Athens'
    },
    {
        id: 'tzData20',
        name: 'Europe/Moscow'
    },
    {
        id: 'tzData21',
        name: 'Iran'
    },
    {
        id: 'tzData22',
        name: 'Asia/Dubai'
    },
    {
        id: 'tzData23',
        name: 'Asia/Kabul'
    },
    {
        id: 'tzData24',
        name: 'Asia/Tashkent'
    },
    {
        id: 'tzData25',
        name: 'Asia/Kolkata'
    },
    {
        id: 'tzData26',
        name: 'Asia/Kathmandu'
    },
    {
        id: 'tzData27',
        name: 'Asia/Thimphu'
    },
    {
        id: 'tzData28',
        name: 'Asia/Rangoon'
    },
    {
        id: 'tzData29',
        name: 'Asia/Bangkok'
    },
    {
        id: 'tzData30',
        name: 'Asia/Singapore'
    },
    {
        id: 'tzData31',
        name: 'Australia/Eucla'
    },
    {
        id: 'tzData32',
        name: 'Japan'
    },
    {
        id: 'tzData33',
        name: 'Australia/Adelaide'
    },
    {
        id: 'tzData34',
        name: 'Australia/Sydney'
    },
    {
        id: 'tzData35',
        name: 'Australia/Lord_Howe'
    },
    {
        id: 'tzData36',
        name: 'Pacific/Pohnpei'
    },
    {
        id: 'tzData37',
        name: 'Pacific/Auckland'
    },
    {
        id: 'tzData38',
        name: 'Pacific/Chatham'
    },
    {
        id: 'tzData39',
        name: 'Pacific/Tongatapu'
    },
    {
        id: 'tzData40',
        name: 'Pacific/Kiritimati'
    },    
]

let json = '';
timeZones.forEach(timeZone => {
    const timeZoneInfo = moment.tz.zone(timeZone.name);
    const filteredTimeZoneInfo = moment.tz.filterYears(timeZoneInfo!, 2022, 2026);
    const untils = filteredTimeZoneInfo.untils.map(u => u ? u / 1000 : 'null');
    const abbrs = filteredTimeZoneInfo.abbrs.map(a => `"${a}"`);
    json += `<jsonData id="${timeZone.id}">{"Offsets":[${filteredTimeZoneInfo.offsets}],"Abbrs":[${abbrs}],"Untils":[${untils}]}</jsonData>\n`;
})

fs.writeFileSync('timeZones.json', json);
console.log('done');