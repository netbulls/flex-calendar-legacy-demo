package com.flexcalendar.components.calendar.sample
{
import com.flexcalendar.components.calendar.FlexCalendar;
import com.flexcalendar.components.calendar.displayClasses.headers.CalendarHeader;

public class MyCalendarHeader extends CalendarHeader
{
	public function MyCalendarHeader(calendar:FlexCalendar)
	{
		super(calendar);
	}

	override protected function createChildren():void
	{
		super.createChildren();


		//We want to hide some parts of this component
		todayButton.visible = false;
		dayButton.visible = false;
	}
}
}