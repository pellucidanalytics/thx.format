package thx.format;

import haxe.Utf8;
import thx.culture.Culture;
import thx.culture.DateFormatInfo;
using thx.core.Nulls;
using StringTools;

class DateFormat {
/**
Custom date format.
*/
  public static function customFormat(d : Date, pattern : String, ?culture : Culture) : String {
    culture = (culture).or(Culture.invariant);
    var escape = false,
        buf = [];
    while(pattern.length > 0) {
      if(escape) {
        escape = false;
        buf.push(pattern.substring(0, 1));
        pattern = pattern.substring(1);
      } else if(PATTERN.match(pattern)) {
        var left = PATTERN.matchedLeft();
        if(left.substring(-1) == "\\") {
          escape = true;
          pattern = pattern.substring(left.length);
          buf.push(left.substring(0, left.length - 1));
          continue;
        }
        buf.push(left);
        buf.push(formatTerm(d, PATTERN.matched(0), culture));
        pattern = PATTERN.matchedRight();
      } else {
        buf.push(pattern);
        pattern = '';
      }
    }
    if(escape)
      buf.push('\\');
    return buf.join('');
  }

//O, o    |
/**
Formats the date using a one letter formatting option or using a custom pattern.

pattern   | description
--------- | ------------------------------------
`d`       | short date pattern
`D`       | long date pattern
`f`       | long date + short time pattern
`F`       | long date + long time pattern
`g`       | short date + short time pattern
`G`       | short date + long time pattern
`M`, `m`  | month/day pattern
`R`, `r`  | RFC1123 pattern
`s`       | sortable date/time pattern
`t`       | short time pattern
`T`       | long time pattern
`u`       | universal sortable date/time pattern
`U`       | universal full date/time pattern
`Y`, `y`  | year/month pattern
...       | custom pattern. It splits the pattern into pattern terms and apply them individually

See `formatTerm` for all the possible formatting options to use for custom patterns.
*/
  public static function format(d : Date, pattern : String, ?culture : Culture) : String
    return switch pattern {
      case "d": dateShort(d, culture);
      case "D": dateLong(d, culture);
      case "f": dateLong(d, culture) + ' ' + timeShort(d, culture);
      case "F": dateLong(d, culture) + ' ' + timeLong(d, culture);
      case "g": dateShort(d, culture) + ' ' + timeShort(d, culture);
      case "G": dateShort(d, culture) + ' ' + timeLong(d, culture);
      case "M",
           "m": monthDay(d, culture);
      case "R",
           "r": rfc1123(d, culture);
      case "s": dateTimeSortable(d, culture);
      case "t": timeShort(d, culture);
      case "T": timeLong(d, culture);
      case "u": universalSortable(d, culture);
      case "U": dateTimeFull(d, culture);
      case "y",
           "Y": yearMonth(d, culture);
      case pattern:
                customFormat(d, pattern, culture);
    };

// NOT SUPPORTED
// f, ff, fff, ffff, fffff, ffffff, fffffff, F, FF, FFF, FFFF, FFFFF, FFFFFF, FFFFFFF, g, gg, K, yyyyy, z, zz, zzz
//      | %z | The time-zone as hour offset from GMT. Required to emit RFC822-conformant dates (using "%a, %d %b %Y %H:%M:%S %z"). | -2
//      | %Z | The time zone or name or abbreviation.                             | GMT
//      | %G | The ISO 8601 year with century as a decimal number. The 4-digit year corresponding to the ISO week number (see %V). This has the same format and value as %y, except that if the ISO week number belongs to the previous or next year, that year is used instead. | 2004
//      | %g | Like %G, but without century, i.e., with a 2-digit year (00-99).   | 04
//      | %j | The day of the year as a decimal number (range 001 to 366).        | 008
//      | %U | The week number of the current year as a decimal number, range 00 to 53, starting with the first Sunday as the first day of week 01. See also %V and %W. | 26
//      | %V | The ISO 8601:1988 week number of the current year as a decimal number, range 01 to 53, where week 1 is the first week that has at least 4 days in the current year, and with Monday as the first day of the week. See also %U and %W. | 26
//      | %W | The week number of the current year as a decimal number, range 00 to 53, starting with the first Monday as the first day of week 01. |
/**
Returns a formatted date according to the passed term and culture. The pattern
parameter accepts the following modifiers in either Microsoft format or strftime format.

format   | description                                                          | example
:------- | -------------------------------------------------------------------- | ------------:
ddd      | The abbreviated weekday name according to the current locale.        | Wed
dddd     | The full weekday name according to the current locale.               | Wednesday
MMM      | The abbreviated month name according to the current locale.          | Jan
MMMM     | The full month name according to the current locale.                 | January
dd       | The day of the month as a decimal number (range 01 to 31).           | 07
MMM      | Equivalent to %b.                                                    | Jan
HH       | The hour as a decimal number using a 24-hour clock (range 00 to 23). | 22
hh       | The hour as a decimal number using a 12-hour clock (range 01 to 12). | 07
MM       | The month as a decimal number (range 01 to 12).                      | 04
mm       | The minute as a decimal number (range 00 to 59).                     | 08
tt       | Either 'AM' or 'PM' according to the given time value, or the corresponding strings for the current locale. Noon is treated as 'pm' and midnight as 'am'. | AM
ss       | The second as a decimal number (range 00 to 61). the upper level of the range 61 rather than 59 to allow for the occasional leap second and even more occasional double leap second. | 07
y        | The year as a decimal number without a century (range 00 to 99).     | 04
d        | The day of the month (1 to 31).                                      | 7
h        | The hour on a 12-hour clock (1 to 12).                               | 11
H        | Same as `h` but `0` padded (01 to 12).                               | 07
m        | Minute (0 to 59).                                                    | 7
M        | Same as `m` but `0` padded (00 to 59).                               | 07
s        | Seconds (0 to 59).                                                   | 7
t        | Same as `s` but `0` padded (00 to 59).                               | 07
yy       | Year from 00 to 99.                                                  | 99
yyy      | Year with at least 3 digits.                                         | 1999
yyyy     | Four digits year.                                                    | 1999
:        | Time separator.                                                      | %
/        | Date separator.                                                      | /
'...'    | Single quoted text is not processed (except for removing the quotes) | ...
"..."    | Double quoted text is not processed (except for removing the quotes) | ...
%?       | Delegates to `strftime`                                              | %d

*/
  public static function formatTerm(d : Date, pattern : String, ?culture : Culture) : String
    return switch pattern {
      case "d":     '${d.getDate()}';
      case "dd":    '${d.getDate()}'.lpad('0', 2);
      case "ddd":   var dt = dateTime(culture);
                    dt.nameDaysAbbreviated[d.getDay()];
      case "dddd":  var dt = dateTime(culture);
                    dt.nameDays[d.getDay()];
      case "h":     switch d.getHours() {
                      case 0:             "12";
                      case d if(d <= 12): '$d';
                      case d:             '${d - 12}';
                    };
      case "hh":    formatTerm(d, 'h', culture).lpad('0', 2);
      case "H":     '${d.getHours()}';
      case "HH":    '${d.getHours()}'.lpad('0', 2);
      case "m":     '${d.getMinutes()}';
      case "mm":    '${d.getMinutes()}'.lpad('0', 2);
      case "M":     '${d.getMonth()+1}';
      case "MM":    '${d.getMonth()+1}'.lpad('0', 2);
      case "MMM":   var dt = dateTime(culture);
                    dt.nameMonthsAbbreviated[d.getMonth()];
      case "MMMM":  var dt = dateTime(culture);
                    dt.nameMonths[d.getMonth()];
      case "s":     '${d.getSeconds()}';
      case "ss":    '${d.getSeconds()}'.lpad('0', 2);
      case "t":     var dt = dateTime(culture);
                    Utf8.sub(d.getHours() < 12 ? dt.designatorAm : dt.designatorPm, 0, 1);
      case "tt":    var dt = dateTime(culture);
                    d.getHours() < 12 ? dt.designatorAm : dt.designatorPm;
      case "y":     '${d.getFullYear()%100}';
      case "yy":    '${d.getFullYear()%100}'.lpad('0', 2);
      case "yyy":   '${d.getFullYear()}'.lpad('0', 3);
      case "yyyy":  '${d.getFullYear()}'.lpad('0', 4);
      case ":":     dateTime(culture).separatorTime;
      case "/":     dateTime(culture).separatorDate;
      case q if(q.substring(0, 1) == "%"):
                    strftime(d, pattern, culture);
      case q if(q != null && q.length > 1 &&
        (q.substring(0, 1) == "'" && q.substring(q.length - 1) == "'") ||
        (q.substring(0, 1) == '"' && q.substring(q.length - 1) == '"')):
                    q.substring(1, q.length - 1);
      case rest:    rest;
    };

/**
Format a date using a `strftime` term.

strftime | description                                                        | example
:------: | -------------------------------------------------------------------| ------------:
%a       | The abbreviated weekday name according to the current locale.      | Wed
%A       | The full weekday name according to the current locale.             | Wednesday
%b       | The abbreviated month name according to the current locale.        | Jan
%B       | The full month name according to the current locale.               | January
%c       | The preferred date and time representation for the current locale. |
%C       | The century number (year/100) as a 2-digit integer.                | 19
%d       | The day of the month as a decimal number (range 01 to 31).         | 07
%D       | Equivalent to %m/%d/%y. (This is the USA date format. In many countries %d/%m/%y is the standard date format. Thus, in an international context, both of these formats are ambiguous and should be avoided). | 06/25/04
%e       | Like %d, the day of the month as a decimal number, but a leading zero may be replaced by a leadingspace. | " 7"
%f       | The month. Single-digit months may be prefixed by leadingspace.*   | " 6"
%h       | Equivalent to %b.                                                  | Jan
%H       | The hour as a decimal number using a 24-hour clock (range 00 to 23). | 22
%i       | The minute. Single-digit minutes may be prefixed by leadingspace.* | " 8"
%I       | The hour as a decimal number using a 12-hour clock (range 01 to 12).| 07
%k       | The hour (24-hour clock) as a decimal number (range 0 to 23); single-digits are optionally prefixed by leadingspace. (See also %H). | 7
%l       | The hour (12-hour clock) as a decimal number (range 1 to 12); single-digits are optionally prefixed by leadingspace. (See also %I). | 7
%m       | The month as a decimal number (range 01 to 12).                    | 04
%M       | The minute as a decimal number (range 00 to 59).                   | 08
%n       | A newline character.                                               |
%p       | Either 'AM' or 'PM' according to the given time value, or the corresponding strings for the current locale. Noon is treated as 'pm' and midnight as 'am'. | AM
%P       | Like %p but in lowercase: 'am' or 'pm' or a corresponding string for the current locale. | AM
%q       | The second. Single-digit seconds may be prefixed by leadingspace.* | " 9"
%r       | The time in a.m. or p.m. notation. In the POSIX locale this is equivalent to '%I:%M:%S %p'. | 07:08:09 am
%R       | The time in 24-hour notation (%H:%M). For a version including the seconds, see %T below. | 07:08
%s       | The number of seconds since the Epoch, i.e., since 1970-01-01 00:00:00 UTC. | 1099928130
%S       | The second as a decimal number (range 00 to 61). the upper level of the range 61 rather than 59 to allow for the occasional leap second and even more occasional double leap second. | 07
%t       | A tab character.                                                   |
%T       | The time in 24-hour notation (%H:%M:%S).                           | 17:08:09
%u       | The day of the week as a decimal, range 1 to 7, Monday being 1. See also %w. |
%w       | The day of the week as a decimal, range 0 to 6, Sunday being 0. See also %u. |
%x       | The preferred date representation for the current locale without the time. |
%X       | The preferred time representation for the current locale without the date. |
%y       | The year as a decimal number without a century (range 00 to 99).   | 04
%Y       | The year as a decimal number including the century.                | 2004
%%       | A literal '%' character.                                           | %

*customs for missing features
*/
  public static function strftime(d : Date, pattern : String, ?culture : Culture) : String
    return switch pattern {
      case "%d":    formatTerm(d, "dd", culture);
      case "%a":    formatTerm(d, "ddd", culture);
      case "%A":    formatTerm(d, "dddd", culture);
      case "%I":    formatTerm(d, "hh", culture);
      case "%H":    formatTerm(d, "HH", culture);
      case "%M":    formatTerm(d, "mm", culture);
      case "%m":    formatTerm(d, "MM", culture);
      case "%b",
           "%h":    formatTerm(d, "MMM", culture);
      case "%B":    formatTerm(d, "MMMM", culture);
      case "%S":    formatTerm(d, "ss", culture);
      case "%p":    formatTerm(d, "tt", culture);
      case "%y":    formatTerm(d, "y", culture);
      case "%c":    dateTimeFull(d, culture);
      case "%C":    '${Math.floor(d.getFullYear()/100)}';
      case "%e":    '${d.getDate()}'.lpad(' ', 2);
      case "%D":    format(d, "%m/%d/%y", culture);
      case "%f":    '${d.getMonth()+1}'.lpad(' ', 2);
      case "%i":    '${d.getMinutes()}'.lpad(' ', 2);
      case "%k":    '${d.getHours()}'.lpad(' ', 2);
      case "%l":    formatTerm(d, 'h', culture).lpad(' ', 2);
      case "%n":    "\n";
      case "%P":    var dt = dateTime(culture);
                    (d.getHours() < 12 ? dt.designatorAm : dt.designatorPm).toLowerCase();
      case "%q":    '${d.getSeconds()}'.lpad(' ', 2);
      case "%r":    format(d, "%I:%M:%S %p", culture);
      case "%R":    format(d, "%H:%M", culture);
      case "%s":    '${Std.int(d.getTime()/1000)}';
      case "%t":    "\t";
      case "%T":    format(d, "%H:%M:%S", culture);
      case "%u":    var day = d.getDay();
                    day == 0 ? '7' : '$day';
      case "%Y":    '${d.getFullYear()}';
      case "%x":    dateLong(d, culture);
      case "%X":    timeLong(d, culture);
      case "%w":    '${d.getDay()}';
      case "%%":    "%";
      case rest:    rest;
    };

/**
Long Date/Time format.
*/
  public static function dateLong(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternDateLong, culture);

/**
Short Date/Time format.
*/
  public static function dateShort(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternDateShort, culture);

/**
Full Date/Time format.
*/
  public static function dateTimeFull(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternDateTimeFull, culture);

/**
Sortable Date/Time format.
*/
  public static function dateTimeSortable(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternDateTimeSortable, culture);

/**
Month/Day format.
*/
  public static function monthDay(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternMonthDay, culture);

/**
Rfc1123 date/time format.
*/
  public static function rfc1123(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternRfc1123, culture);

/**
Long time format.
*/
  public static function timeLong(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternTimeLong, culture);

/**
Sort time format.
*/
  public static function timeShort(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternTimeShort, culture);

/**
Format a date in way that it can be correctly ordered alphabetically.
*/
  public static function universalSortable(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternUniversalSortable, culture);

/**
Format for year and month.
*/
  public static function yearMonth(d : Date, ?culture : Culture)
    return customFormat(d, dateTime(culture).patternYearMonth, culture);

// PRIVATE

  static function dateTime(?culture : Culture)
    return null != culture && null != culture.dateTime ? culture.dateTime : Culture.invariant.dateTime;

  static var PATTERN = ~/(d|M|y){1,4}|(h|H|m|s|t){1,2}|[:]|[\/]|'[^']*'|"[^"]*"|[%][daAIHMmbhBSpycCeDfiklnPqrRstTuYxXw%]/;
}