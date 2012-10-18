/**
 * This module provides a class representing a lesson
 */
module lesson;

import
	std.algorithm,
	std.array, 
	std.conv, 
	std.datetime, 
	std.exception, 
	std.stdio, 
	std.string;

/**
 * Error that indicates an invalid formatstring
 */
class InvalidArgumentError : Exception{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null){
		super(msg, file, line, next);
	}
	
	this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__){
		super(msg, file, line, next);
	}
};

/**
 * A lesson
 */
class Lesson{
	public:
		
		/**
		 * ctor
		 */
		this(string subject, string place, DayOfWeek day, Interval!TimeOfDay dailyDuration){
			this.subject = subject;
			this.place = place;
			this.day = day;
			this.dailyDuration = dailyDuration;
		}
		
		/**
		 * returns a formated string that represents the lesson
		 * 
		 * Params:
		 *  format = the formatstring
		 * 
		 * Throws: 
		 *  InvalidArgumentError if the formatstring is invalid
		 */
		string toFormatedString(string format){
			string returnstr;
			for(int i = 0; i < format.length; ++i){
				if( format[i] == '\\'){
					++i;
					if( i == format.length ){
						throw new InvalidArgumentError("invalid backslash-specifier");
					}
					switch(format[i]){
						case 't' : returnstr ~= '\t'; break;
						case 'n' : returnstr ~= '\n'; break;
						case '\\': returnstr ~= '\\'; break;
						default: throw new InvalidArgumentError( "invalid backslash-specifier"
								~ "(‘" ~ format[i] ~ "’); allowed are: ‘t’, ‘n’ "
								~ "and ‘\\’" );
					}
				}
				else if( format[i] == '%'){
					++i;
					if( i == format.length ){
						throw new InvalidArgumentError("invalid percent-specifier");
					}
					switch(format[i]){
						case '%': returnstr ~= '%'; break;
						case 's': returnstr ~= subject; break;
						case 'p': returnstr ~= place ; break;
						case 'd': returnstr ~= to!string(day); break;
						case 't': returnstr ~= dailyDuration.begin().toString(); break;
						case 'T': returnstr ~= dailyDuration.end().toString(); break;
						default: throw new InvalidArgumentError("invalid percent-specifier (‘"
							~ format[i] ~ 
							"’); allowed are: ‘%’, ‘s’, ‘p’, ‘d’, ‘t’ and ‘T’");
					}
				}
				else{
					returnstr ~= format[i];
				}
			}
			return returnstr;
		}
		
		/**
		 * get the weekday of the lesson.
		 */
		DayOfWeek getDay(){
			return day;
		}
		
		auto getStart(){
			return dailyDuration.begin();
		}
		
		auto getEnd(){
			return dailyDuration.end();
		}
		
		auto getDailyDuration(){
			return dailyDuration;
		}
		
		
		
	private:
		string subject;
		string place;
		DayOfWeek day;
		Interval!TimeOfDay dailyDuration;
		Interval!Date dateDuration;
	
};

/**
 * returns whether this Lesson  earlier than another lesson l2
 */
bool isEarlier(in Lesson l1, in Lesson l2){
	if(l1.day < l2.day){
		return true;
	}
	if(l1.day > l2.day){
		return false;
	}
	assert(l1.day ==  l2.day);
	
	if(l1.dailyDuration.isBefore(l2.dailyDuration)){
		return true;
	}
	if(l1.dailyDuration.isAfter(l2.dailyDuration)){
		return false;
	}
	assert(l1.dailyDuration.intersects(l2.dailyDuration));
	
	if(l1.dailyDuration.begin() < l2.dailyDuration.begin()){
		return true;
	}
	else{
		return false;
	}
}


/**
 * Error that indicates an invalid configfile
 */
class InvalidConfigFileError : Exception{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null){
		super(msg, file, line, next);
	}
	
	this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__){
		super(msg, file, line, next);
	}
};

/**
 * reads in lessons from a configfile.
 * 
 * Params:
 *   filename = name of the configfile
 * 
 * Throws:
 *   InvalidConfigFileError if the configfile contains invalid lines
 * 
 * Returns:
 *   An unsorted list of all Lessons defined in the configfile
 */
Lesson[] readLessons(string filename)
out(result){
	assert(isSorted!(isEarlier)(result));
}
body{
	auto file = File(filename,"r");
	Lesson[] returnlist;
	uint lineNumber = 0;
	bool inside_definition = false;
	
	//tmpvals:
	string subject;
	string place;
	DayOfWeek day;
	TimeOfDay startTime, endTime;
	
	foreach( buffer; file.byLine() ){
		++lineNumber;
		if( ! buffer.length ){
			continue;
		}
		string line = strip( to!string(buffer) );
		if( !line.length || line[0] == '#' ){
			continue;
		}
		
		if( ! inside_definition ){
			if( line == "{" ){
				inside_definition = true;
				continue;
			}
			else{
				throw new InvalidConfigFileError(format(
					"Invalid line in configfile (“%s”, %s): "
					~ "Unexpected text outside definition-area (“%s”)",
					filename, lineNumber, line));
			}
		}
		
		auto tmp = findSplit(line, "=");
		
		assert(tmp.length == 3);
		
		if( tmp[1].length == 0 ){
			if( tmp[0] == "}" ){
				returnlist ~= new Lesson( subject, place, day, 
					Interval!TimeOfDay(startTime, endTime) );
				inside_definition = false;
				continue;
			}
			else{
				throw new InvalidConfigFileError(format(
					"Invalid line in configfile (“%s”, %s): No delimiter („%s“)", 
					filename, lineNumber, line));
			}
		}
		
		auto key = stripRight( tmp[0]);
		auto val = stripLeft( tmp[2] );
		
		switch(key){
			case "subject": 
				subject = val;
				break;
			case "place":
				place = val;
				break;
			case "day":
				day = to!DayOfWeek(val);
				break;
			case "start":
				startTime = TimeOfDay.fromISOExtString(val);
				break;
			case "end":
				endTime = TimeOfDay.fromISOExtString(val);
				break;
			default:
				stderr.writefln("WARNING: Unknown key in configfile (“%s”, %s): “%s” (with value “%s”)",
					filename, lineNumber, key, val);
		}
	}
	sort!(isEarlier)(returnlist);
	return returnlist;
}

unittest{
	auto testinstance = new Lesson(
		"testsubject", 
		"someplace", 
		DayOfWeek.mon, 
		Interval!TimeOfDay(
			TimeOfDay(8,0), 
			TimeOfDay(9,30)
		)
	);
	assert( testinstance.toFormatedString("%t - %T:\\t%s\\t(%p)")
		== "08:00:00 - 09:30:00:\ttestsubject\t(someplace)"
	);
	assert( testinstance.toFormatedString("%t - %T\\t")
		== "08:00:00 - 09:30:00\t"
	);
	try{
		testinstance.toFormatedString("\\f");
		assert(false);
	}
	catch(InvalidArgumentError e){
		assert(true);
	}
	catch(Throwable e){
		assert(false);
	}
}
