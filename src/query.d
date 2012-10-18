
/**
 *
 */
module query;

import std.algorithm;
import std.conv;
import std.datetime;
import std.stdio;

import lesson;

/**
 * The type of the query.
 * 
 */
enum QueryType{
	today,
	tomorow,
	week,
	next,
	now,
	nowOrNext,
	day
};

/**
 * print a query to stdout
 */
void printQuery(Lesson[] lessons, QueryType type, string formatstring, DayOfWeek day){
	if(!lessons.length){
		return;
	}
	Lesson[] filteredLessons;
	auto time = Clock.currTime();
	auto weekday = time.dayOfWeek;
	switch(type){
		case QueryType.today:
			foreach(l; lessons){
				if ( weekday == l.getDay ){
					filteredLessons ~= l;
				}
			}
			break;
		case QueryType.tomorow:
			weekday = cast(DayOfWeek)((weekday + 1) % 6);
			foreach(l; lessons){
				if ( weekday == l.getDay ){
					filteredLessons ~= l;
				}
			}
			break;
		case QueryType.week:
			filteredLessons = lessons;
			break;
		case QueryType.next:
			for(int i=0; i<lessons.length; ++i){
				if(lessons[i].getStart() >= to!TimeOfDay(time)
					&& !lessons[i].getDay() < weekday
				){
					filteredLessons ~= lessons[i];
					break;
				}
			}
			if( !filteredLessons.length ){
				filteredLessons ~= lessons[0];
			}
			break;
		case QueryType.now:
			foreach(l; lessons){
				if( l.getDailyDuration.contains( to!TimeOfDay(time) ) 
					&& l.getDay() == weekday
				){
					filteredLessons ~= l;
				}
			}
			break;
		case QueryType.nowOrNext:
			for(int i=0; i<lessons.length; ++i){
				if( lessons[i].getEnd() >= to!TimeOfDay(time) ){
					filteredLessons ~= lessons[i];
					break;
				}
			}
			if( !filteredLessons.length ){
				filteredLessons ~= lessons[0];
			}
			break;
		case QueryType.day:
			foreach(l; lessons){
				if( l.getDay() == day ){
					filteredLessons ~= l;
				}
			}
			break;
		default:
			assert(false);
	}
	foreach(l; filteredLessons){
		writeln( l.toFormatedString(formatstring) );
	}
}
