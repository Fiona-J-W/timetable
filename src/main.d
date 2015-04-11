import std.datetime, std.exception, std.getopt, std.stdio, std.process;

import lesson;
import query;


int main(string[] args){
	try{
		auto configFileName = environment["XDG_CONFIG_HOME"];
		if( !configFileName || !configFileName.length ){
			stderr.writeln("ERROR: $XDG_CONFIG_HOME is not set.");
			return 1;
		}
		configFileName ~= "/timetable/current";
		Lesson[] lessons;
		
		lessons = readLessons( configFileName );
		debug writeln("read all lessons...");
		
		string formatstring = "%d:\t%t - %T:\t%s\t(%p)";
		QueryType type = QueryType.day;
		DayOfWeek day = Clock.currTime().dayOfWeek;
		
		getopt(args, std.getopt.config.caseSensitive, std.getopt.config.noPassThrough,
			"f|format",  &formatstring,
			"w|when",    &type,
			//explicit specifications of -w:
			"t|today",   delegate(){type = QueryType.today;},
			"T|tomorow", delegate(){type = QueryType.tomorow;},
			"n|next",    delegate(){type = QueryType.next;},
			"N|now",     delegate(){type = QueryType.now;},
			"W|week",    delegate(){type = QueryType.week;},
			"d|day",     &day
		);
		
		
		debug writefln("formatstring = “%s”", formatstring);
		debug writefln("type         = “%s”", type);
		
		printQuery(lessons, type, formatstring, day);
	}
	catch(InvalidConfigFileError e){
		stderr.writefln("ERROR: %s", e.msg);
		return 1;
	}
	catch(InvalidArgumentError e){
		stderr.writefln("ERROR: Invalid formatstring: %s", e.msg);
		return 1;
	}
	catch(Exception e){
		stderr.writefln("ERROR: %s", e);
		return 1;
	}
	
	return 0;
}
