package com.flexcalendar.components.calendar.editor
{
import com.flexcalendar.components.calendar.events.CalendarMouseEvent;

/**
 * Item editor interface.
 */

public interface IItemEditor
{

	/**
	 * Click on calendar free space handler.
	 * @param event CalendarMouseEvent for click handler
	 */
	function calendarClickHandler(event:CalendarMouseEvent):void;

	/**
	 * Double click on calendar free space handler.
	 * @param event CalendarMouseEvent for click handler
	 */
	function calendarDoubleClickHandler(event:CalendarMouseEvent):void;

	/**
	 * Click on calendar item renderer handler.
	 * @param event CalendarMouseEvent
	 */
	function rendererClickHandler(event:CalendarMouseEvent):void;	

	/**
	 * Double click on calendar item renderer handler.
	 * @param event CalendarMouseEvent
	 */
	function rendererDoubleClickHandler(event:CalendarMouseEvent):void;

	/**
	 * Click on calendar space renderer handler.
	 * @param event CalendarMouseEvent
	 */
	function spaceRendererClickHandler(event:CalendarMouseEvent):void;

	/**
	 * Double click on calendar space renderer handler.
	 * @param event CalendarMouseEvent
	 */
	function spaceRendererDoubleClickHandler(event:CalendarMouseEvent):void;
}
}