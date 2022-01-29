import moment from 'moment-timezone';
import 'moment-timezone/moment-timezone-utils';

const allLa = moment.tz.zone('America/Los_Angeles');


console.log(moment.tz.filterYears(allLa!, 2021, 2026));