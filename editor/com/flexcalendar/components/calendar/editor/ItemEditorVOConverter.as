package com.flexcalendar.components.calendar.editor
{
import com.flexcalendar.components.calendar.core.dataModel.CalendarItem;
import com.flexcalendar.components.calendar.core.dataModel.formatICalendar.Recur;
import com.flexcalendar.components.calendar.core.dataModel.formatICalendar.WeekDay;
import com.flexcalendar.components.calendar.utils.DateUtils;

/**
 * Converter for ItemEditorVO.
 * Can convert CalendarItem to ItemEditorVO.
 * Can create new CalendarItem from ItemEditorVO
 * Can update fields of CalendarItem based on new ItemEditorVO values
 */

public class ItemEditorVOConverter
{
	public function ItemEditorVOConverter()
	{
	}

	public function calendarItemToItemEditorVO(calendarItem:CalendarItem):ItemEditorVO
	{
		var itemEditorVO:ItemEditorVO = new ItemEditorVO();
		itemEditorVO.summary = calendarItem.summary;
		itemEditorVO.description = calendarItem.description;
		itemEditorVO.start = calendarItem.start;
		itemEditorVO.end = calendarItem.end;
		itemEditorVO.recurring = calendarItem.isRecurring();
		if (itemEditorVO.recurring)
		{
			itemEditorVO.repeatRuleId = getRepeatRuleId(calendarItem.recur);

			if (itemEditorVO.repeatRuleId == ItemEditorVO.WEEKLY)
			{
				markWeekDays(itemEditorVO, calendarItem.recur);
			}

			itemEditorVO.interval = calendarItem.recur.interval > 0 ? calendarItem.recur.interval - 1 : 0;
			itemEditorVO.endDateSpecified = calendarItem.recur.until != null;
			if (itemEditorVO.endDateSpecified)
			{
				itemEditorVO.endDate = calendarItem.recur.until;
			}
		}

		return itemEditorVO;
	}

	private function getRepeatRuleId(recur:Recur):int
	{
		if (recur.freq == Recur.DAILY)
			return ItemEditorVO.DAILY;
		if (recur.freq == Recur.MONTHLY)
			return ItemEditorVO.MONTHLY;
		if (recur.freq == Recur.YEARLY)
			return ItemEditorVO.YEARLY;
		if (recur.freq == Recur.WEEKLY)
			return ItemEditorVO.WEEKLY;

		return -1;
	}

	private function markWeekDays(itemEditorVO:ItemEditorVO, recur:Recur):void
	{
		itemEditorVO.MO = markDay(DateUtils.MO, recur.byDay);
		itemEditorVO.TU = markDay(DateUtils.TU, recur.byDay);
		itemEditorVO.WE = markDay(DateUtils.WE, recur.byDay);
		itemEditorVO.TH = markDay(DateUtils.TH, recur.byDay);
		itemEditorVO.FR = markDay(DateUtils.FR, recur.byDay);
		itemEditorVO.SA = markDay(DateUtils.SA, recur.byDay);
		itemEditorVO.SU = markDay(DateUtils.SU, recur.byDay);
	}

	private function markDay(day:String, byDay:Array):Boolean
	{
		if (byDay == null || byDay.length == 0)
			return false;
		for each(var weekDay:WeekDay in byDay)
		{
			if (weekDay.day == day)
				return true;
		}
		return false;
	}

	public function itemEditorVOToCalendarItem(itemEditorVO:ItemEditorVO, calendarItem:CalendarItem = null):CalendarItem
	{
		if(calendarItem == null)
		{
			calendarItem = new CalendarItem(itemEditorVO.start, itemEditorVO.end, itemEditorVO.summary, itemEditorVO.description);
		}
		calendarItem.setRange(itemEditorVO.start, itemEditorVO.end);
		calendarItem.summary = itemEditorVO.summary;
		calendarItem.description = itemEditorVO.description;

		if(itemEditorVO.recurring)
		{
			var recurString:String = new String();
			recurString += getFreqType(itemEditorVO.repeatRuleId);
			recurString += getEndDay(itemEditorVO);
			recurString += getInterval(itemEditorVO.interval);
			recurString += getByDay(itemEditorVO);


			calendarItem.recur = new Recur(recurString);
		}

		return calendarItem;
	}


	private function getFreqType(repeatRuleId:int):String
	{
		var recurString:String = "FREQ=";
		switch(repeatRuleId)
		{
			case ItemEditorVO.DAILY:
				recurString += Recur.DAILY;
				break;

			case ItemEditorVO.EVERY_WEEKDAY:
			case ItemEditorVO.EVERY_MO_WED_FRI:
			case ItemEditorVO.EVERY_THUES_THURS:
			case ItemEditorVO.WEEKLY:
				recurString += Recur.WEEKLY;
				break;

			case ItemEditorVO.MONTHLY:
				recurString += Recur.MONTHLY;
				break;

			case ItemEditorVO.YEARLY:
				recurString += Recur.YEARLY;
				break;

			default:
				throw new Error("Unable to create recurrence instance");
		}

		return recurString;
	}

	private function getInterval(interval:int):String
	{
		if(interval != 0)
		{
			return ";INTERVAL=" + (interval + 1);
		}
		else
		{
			return "";			
		}
	}

	private function getByDay(itemEditorVO:ItemEditorVO):String
	{
		if(itemEditorVO.repeatRuleId == ItemEditorVO.EVERY_MO_WED_FRI)
		{
			return ";BYDAY=MO,WE,FR";
		}
		else if(itemEditorVO.repeatRuleId == ItemEditorVO.EVERY_THUES_THURS)
		{
			return ";BYDAY=TU,TH";
		}
		else if(itemEditorVO.repeatRuleId == ItemEditorVO.EVERY_WEEKDAY)
			{
				return ";BYDAY=MO,TU,WE,TH,FR"
			}
		else if(itemEditorVO.repeatRuleId == ItemEditorVO.WEEKLY)
				{
					var byDayString:String = ";BYDAY=";
					var days:Array = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];
					var anyDaySelected:Boolean = false;
					for(var i:int = 0; i < days.length; i++)
					{
						var dayAbbr:String = days[i];
						if(itemEditorVO[dayAbbr])
						{
							byDayString += (anyDaySelected ? "," : "") + dayAbbr; 
							anyDaySelected = true;
						}
					}
					if(anyDaySelected)
						return byDayString;
					else
						return "";
					
				}
		
		return "";
	}

	private function getEndDay(itemEditorVO:ItemEditorVO):String
	{
		if(!itemEditorVO.endDateSpecified)
		{
			return "";
		}
		else
		{
			var untilString:String = ";UNTIL=";
			untilString += itemEditorVO.endDate.fullYear;
            untilString += itemEditorVO.endDate.month < 9 ? "0" + (itemEditorVO.endDate.month + 1) :
                    "" + itemEditorVO.endDate.month + 1;
			untilString += itemEditorVO.endDate.date < 10 ? "0" + itemEditorVO.endDate.date :
                    "" + itemEditorVO.endDate.date;

			return untilString;
		}
	}

}
}