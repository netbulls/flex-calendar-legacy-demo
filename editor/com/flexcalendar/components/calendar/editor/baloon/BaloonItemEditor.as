package com.flexcalendar.components.calendar.editor.baloon
{
import com.flexcalendar.components.calendar.FlexCalendar;
import com.flexcalendar.components.calendar.displayClasses.grids.DayViewGrid;
import com.flexcalendar.components.calendar.editor.baloon.BaloonEditorPanel;
import com.flexcalendar.components.calendar.core.dataModel.CalendarItem;
import com.flexcalendar.components.calendar.editor.IItemEditor;
import com.flexcalendar.components.calendar.editor.ItemEditorVOConverter;
import com.flexcalendar.components.calendar.editor.builders.IntervalVariantsBuilder;
import com.flexcalendar.components.calendar.editor.builders.RepeatVariantsBuilder;
import com.flexcalendar.components.calendar.events.CalendarMouseEvent;
import com.flexcalendar.components.calendar.utils.DateUtils;

import flash.display.DisplayObject;
import flash.geom.Point;

import mx.core.Application;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;

[ResourceBundle("FlexCalendar")]
/**
 * Baloon item editor interface.
 */

public class BaloonItemEditor implements IItemEditor
{
	private var isNew:Boolean = false;
	private var calendarItem:CalendarItem;

	private var calendarMouseEvent:CalendarMouseEvent;

	private var editorPanel:BaloonEditorPanel;
	private var calendar:FlexCalendar;

	private var converter:ItemEditorVOConverter = new ItemEditorVOConverter();

	private var doubleClickOnRenderers:Boolean;
	private var doubleClickOnCalendar:Boolean;

	private var preferedTimeForNewEvents:Number;

	/**
	 * Editor constructor.
	 * @param calendar Flex Calendar instance
	 * @param doubleClickOnRenderers - false if editor should react for single click events on renderers, true for double click
	 * @param doubleClickOnCalendar - false if editor should react for single click events on calendar, true for double click
	 */
	public function BaloonItemEditor(calendar:FlexCalendar, doubleClickOnRenderers:Boolean = false, doubleClickOnCalendar:Boolean = false)
	{
		this.calendar = calendar;
		this.doubleClickOnRenderers = doubleClickOnRenderers;
		this.doubleClickOnCalendar = doubleClickOnCalendar;
	}

	public function calendarClickHandler(event:CalendarMouseEvent):void
	{
		if(!doubleClickOnCalendar)
			addNewItemPopup(event);
	}

	/**
	 * @inheritDoc
	 */
	public function calendarDoubleClickHandler(event:CalendarMouseEvent):void
	{
		if(doubleClickOnCalendar)
			addNewItemPopup(event);
	}

	private function addNewItemPopup(event:CalendarMouseEvent):void
	{
		calendarMouseEvent = event;
		preferedTimeForNewEvents = event.preferredTimeInMills;
		calendarItem =
				new CalendarItem(event.selectedDate, new Date(event.selectedDate.time + preferedTimeForNewEvents),
						ResourceManager.getInstance().getString("FlexCalendar", "editor.newItem"));

		isNew = true;

		var calendarComponentMousePosition:Point = calendarMousePositionFromEvent(event);
		createEditorPopUp(calendarComponentMousePosition.x, calendarComponentMousePosition.y, saveCallbackForCreateHandler);
	}

	/**
	 * @inheritDoc
	 */
	public function rendererClickHandler(event:CalendarMouseEvent):void
	{
		if(!doubleClickOnRenderers)
			editItemPopup(event);
	}

	public function rendererDoubleClickHandler(event:CalendarMouseEvent):void
	{
		if(doubleClickOnRenderers)
			editItemPopup(event);
	}

	public function spaceRendererClickHandler(event:CalendarMouseEvent):void
	{
		if(!doubleClickOnRenderers)
		{
			addNewItemPopup(event);
		}

	}

	public function spaceRendererDoubleClickHandler(event:CalendarMouseEvent):void
	{
		if(doubleClickOnRenderers)
			addNewItemPopup(event);
	}

	private function editItemPopup(event:CalendarMouseEvent):void
	{
		calendarMouseEvent = event;
		this.calendarItem = event.item;
		preferedTimeForNewEvents = event.preferredTimeInMills;
		isNew = false;

		var calendarComponentMousePosition:Point = calendarMousePositionFromEvent(event);
		createEditorPopUp(calendarComponentMousePosition.x, calendarComponentMousePosition.y, saveCallbackForUpdateHandler);		
	}


	private function createEditorPopUp(clickedX:Number, clickedY:Number, saveCallback:Function):void
	{
		editorPanel = new BaloonEditorPanel();
		editorPanel.item = converter.calendarItemToItemEditorVO(calendarItem);
		editorPanel.saveCallback = saveCallback;
		editorPanel.cancelCallback = cancelCallbackHandler;
		editorPanel.deleteCallback = deleteCallback;
		editorPanel.repeatVariants = new RepeatVariantsBuilder().repeatVariants;
		editorPanel.intervalVariants = new IntervalVariantsBuilder().intervalVariants;
		editorPanel.isNew = isNew;

		PopUpManager.addPopUp(editorPanel, calendar, true);
		
		editorPanel.calculatePosition(clickedX,  clickedY);
	}

	/**
	 * Checks item range against space range and adjusts it if necessarry
	 */
	private function fixRange():void
	{
		if ((null != calendarMouseEvent.item) && (null != calendarMouseEvent.item.start) && (null != calendarMouseEvent.item.end))
		{
			if ((calendarItem.start < calendarMouseEvent.item.start) || (calendarItem.end <= calendarMouseEvent.item.start))
			{
				calendarItem.start = calendarMouseEvent.item.start;
				calendarItem.end = new Date(calendarMouseEvent.item.start.time + preferedTimeForNewEvents);
			}
			else if ((calendarItem.start >= calendarMouseEvent.item.end) || (calendarItem.end > calendarMouseEvent.item.end))
			{
				calendarItem.start = new Date(calendarMouseEvent.item.end.time - preferedTimeForNewEvents);
				calendarItem.end = calendarMouseEvent.item.end;  
			}
		}
	}

	private function saveCallbackForUpdateHandler():void
	{
		if ((null != calendarMouseEvent) && (null != calendarMouseEvent.renderersContainer))
		{
			var dayViewGrid: DayViewGrid = calendarMouseEvent.renderersContainer as DayViewGrid;
			if (null != dayViewGrid)
			{
				if (!dayViewGrid.isAvailableSpaceForGivenPeriod(editorPanel.item.start, editorPanel.item.end))
				{
					// don't update if can't be placed in given place
					calendar.refresh();
					removeAndClosePopUp();
					return;
				}
			}
		}

		calendarItem = converter.itemEditorVOToCalendarItem(editorPanel.item, calendarItem);
		fixRange();
		calendar.refresh();
		removeAndClosePopUp();
	}

	private function saveCallbackForCreateHandler():void
	{
		if ((null != calendarMouseEvent) && (null != calendarMouseEvent.renderersContainer))
		{
			var dayViewGrid: DayViewGrid = calendarMouseEvent.renderersContainer as DayViewGrid;
			if (null != dayViewGrid)
			{
				if (!dayViewGrid.isAvailableSpaceForGivenPeriod(editorPanel.item.start, editorPanel.item.end))
				{
					// don't update if can't be placed in given place
					calendar.refresh();
					removeAndClosePopUp();
					return;
				}
			}
		}
		
		calendarItem = converter.itemEditorVOToCalendarItem(editorPanel.item, calendarItem);
		fixRange();
		calendar.dataProvider.itemSets[0].addItem(calendarItem);
		calendar.refresh();
		removeAndClosePopUp();
	}

	private function cancelCallbackHandler():void
	{
		removeAndClosePopUp();
	}

	private function deleteCallback():void
	{
		calendar.dataProvider.itemSets[0].removeItem(calendarItem);
		calendar.refresh();
		removeAndClosePopUp();
	}

	private function removeAndClosePopUp():void
	{
		if (editorPanel)
		{
			PopUpManager.removePopUp(editorPanel);
			editorPanel = null;
			calendarMouseEvent = null;
		}
	}

	private function calendarMousePositionFromEvent(event:CalendarMouseEvent):Point
	{
		return calendar.globalToLocal((event.target as DisplayObject).localToGlobal(new Point(
				event.target.mouseX, event.target.mouseY)));
	}
}
}