package com.flexcalendar.components.calendar.editor
{
import com.flexcalendar.components.calendar.FlexCalendar;
import com.flexcalendar.components.calendar.core.dataModel.CalendarItem;
import com.flexcalendar.components.calendar.editor.builders.IntervalVariantsBuilder;
import com.flexcalendar.components.calendar.editor.builders.RepeatVariantsBuilder;
import com.flexcalendar.components.calendar.events.CalendarMouseEvent;
import com.flexcalendar.components.calendar.utils.DateUtils;

import mx.managers.PopUpManager;
import mx.resources.ResourceManager;

[ResourceBundle("FlexCalendar")]
/**
 * Default item editor interface.
 */

public class DefaultItemEditor implements IItemEditor
{
	private var isNew:Boolean = false;
	private var calendarItem:CalendarItem;

	private var editorPanel:DefaultEditorPanel;
	private var calendar:FlexCalendar;

	private var converter:ItemEditorVOConverter = new ItemEditorVOConverter();

	/**
	 * Editor constructor.
	 * @param calendar
	 */
	public function DefaultItemEditor(calendar:FlexCalendar)
	{
		this.calendar = calendar;
	}

	/**
	 * @inheritDoc
	 */
	public function calendarClickHandler(event:CalendarMouseEvent):void
	{
		calendarItem =
				new CalendarItem(event.selectedDate, new Date(event.selectedDate.time + event.preferredTimeInMills),
						ResourceManager.getInstance().getString("FlexCalendar", "editor.newItem"));
		isNew = true;
		createEditorPopUp(saveCallbackForCreateHandler);
	}

	/**
	 * @inheritDoc
	 */	
	public function rendererClickHandler(event:CalendarMouseEvent):void
	{
		this.calendarItem = event.item;
		isNew = false;
		createEditorPopUp(saveCallbackForUpdateHandler);
	}

	private function createEditorPopUp(saveCallback:Function):void
	{
		editorPanel = new DefaultEditorPanel();
		editorPanel.item = converter.calendarItemToItemEditorVO(calendarItem);
		editorPanel.saveCallback = saveCallback;
		editorPanel.cancelCallback = cancelCallbackHandler;
		editorPanel.deleteCallback = deleteCallback;
		editorPanel.repeatVariants = new RepeatVariantsBuilder().repeatVariants;
		editorPanel.intervalVariants = new IntervalVariantsBuilder().intervalVariants;
		editorPanel.isNew = isNew;

		PopUpManager.addPopUp(editorPanel, calendar, true);
		PopUpManager.centerPopUp(editorPanel)
	}


	private function saveCallbackForUpdateHandler():void
	{
		calendarItem = converter.itemEditorVOToCalendarItem(editorPanel.item, calendarItem);
		calendar.refresh();
		removeAndClosePopUp();
	}

	private function saveCallbackForCreateHandler():void
	{
		calendarItem = converter.itemEditorVOToCalendarItem(editorPanel.item, calendarItem);
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
		}
	}

	public function calendarDoubleClickHandler(event:CalendarMouseEvent):void
	{
		//does nothing
	}

	public function rendererDoubleClickHandler(event:CalendarMouseEvent):void
	{
		//does nothing
	}

	public function spaceRendererClickHandler(event:CalendarMouseEvent):void
	{
		//does nothing
	}

	public function spaceRendererDoubleClickHandler(event:CalendarMouseEvent):void
	{
		//does nothing
	}
}
}