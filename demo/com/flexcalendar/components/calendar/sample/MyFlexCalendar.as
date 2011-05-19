package com.flexcalendar.components.calendar.sample
{
import com.flexcalendar.components.calendar.FlexCalendar;

public class MyFlexCalendar extends FlexCalendar
{
	public function MyFlexCalendar()
	{
		super();
	}

	override protected function createHeader():void
	{
		//do not call super
		this.header = new MyCalendarHeader(this); 
	}
}
}