package com.findingemos.felicity.emoticon;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.content.ClipData;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.ImageView;

import com.findingemos.felicity.util.ImageScaler;

/**
 * This view represents an Emoticon in the HorizontalScoller.
 * 
 * @author Niels
 * @version 0.1
 */
public class EmotionView extends ImageView implements OnTouchListener {
	// Time of last down touch
	private long lastTouchTime = System.currentTimeMillis();

	// The emoticon for the view.
	private Emotion emoticon;

	// The size of an emoticion
	private final int EMOTICON_SIZE = 56;

	// The padding around the emoticon
	private final int EMOTICON_PADDING = 8;

	// A list of emoticon selection listeners
	private ArrayList<EmotionSelectionListener> listeners = new ArrayList<EmotionSelectionListener>();

	/**
	 * Creates a new EmoticonView without an emoticon in the given context.<br>
	 * <br>
	 * This is method is necessary if we want to use this component as a custom
	 * component in the XML files.
	 * 
	 * @param context
	 *            The context to create the emoticon in.
	 */
	public EmotionView(Context context) {
		this(context, null);
		init();
	}

	/**
	 * Creates a new EmoticonView in the given context with the given emoticon.
	 * 
	 * @param context
	 *            The context to create the emoticon in.
	 * @param emoticon
	 *            The emoticon for the view.
	 */
	public EmotionView(Context context, Emotion emoticon) {
		super(context);
		init();
		setEmoticon(emoticon);
	}

	/**
	 * Initialises this view in order for this view to have the correct size.
	 */
	private void init() {
		setMinimumWidth(EMOTICON_SIZE + 2 * EMOTICON_PADDING);
		setMinimumHeight(EMOTICON_SIZE + 2 * EMOTICON_PADDING);

		setOnTouchListener(this);

		if (EmotionActivity.DRAG_AND_DROP)
			setOnLongClickListener(new OnLongClickListener() {
				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * android.view.View.OnLongClickListener#onLongClick(android
				 * .view .View)
				 */
				@Override
				public boolean onLongClick(View v) {
					startDrag();
					return true;
				}
			});
	}

	/**
	 * Sets the emoticon for this view to the given emoticon.
	 * 
	 * @param emoticon
	 *            The emoticon for this view.
	 * @note this method will just return when the given emoticon is null
	 */
	public void setEmoticon(Emotion emoticon) {
		if (emoticon == null)
			return;
		this.emoticon = emoticon;

		Bitmap fullImage = BitmapFactory.decodeResource(getResources(),
				emoticon.getLowResolutionResourceId());
		this.setImageBitmap(ImageScaler.convert(fullImage, EMOTICON_SIZE,
				EMOTICON_SIZE));
		this.setScaleType(ScaleType.CENTER_INSIDE);
	}

	/**
	 * Returns the emoticon of this view.
	 * 
	 * @return the emoticon of this view.
	 */
	public Emotion getEmoticon() {
		return emoticon;
	}

	/**
	 * 
	 * @param listener
	 */
	public void addSelectionListener(EmotionSelectionListener listener) {
		if (listener != null)
			listeners.add(listener);
	}

	/**
	 * Notifies the listeners when an emotion is selected.
	 */
	public void notifySelection() {
		for (EmotionSelectionListener listener : listeners)
			listener.onEmotionSelected(emoticon);
	}

	/**
	 * Notifies the listeners when an emoticon is deselected.
	 */
	public void notifyDeSelection() {
		for (EmotionSelectionListener listener : listeners)
			listener.onEmotionDeselected(emoticon);
	}

	/**
	 * Notifies the listeners when an emoticon is double tapped.
	 */
	public void notifyDoubleTapped() {
		for(EmotionSelectionListener listener : listeners) 
			listener.onEmotionDoubleTapped(emoticon);
	}
	/**
	 * Starts the drag operation.<br>
	 * <br>
	 * This is only called when drag and drop is enabled! This is only available
	 * since API level 11. Therefore make sure this method is never called on
	 * Android Phones with version less than honeycomb.
	 */
	@SuppressLint("NewApi")
	private void startDrag() {
		if (!EmotionActivity.DRAG_AND_DROP)
			return;
		ClipData data = ClipData.newPlainText("Emoticon", getEmoticon()
				.getName());
		View.DragShadowBuilder shadow = new View.DragShadowBuilder(
				EmotionView.this);
		startDrag(data, shadow, EmotionView.this, 0);
		setVisibility(View.INVISIBLE);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnTouchListener#onTouch(android.view.View,
	 * android.view.MotionEvent)
	 */
	@Override
	public boolean onTouch(View v, MotionEvent event) {
		int action = event.getAction();

		if (EmotionActivity.DRAG_AND_DROP) {
			switch (action) {
			case MotionEvent.ACTION_DOWN:
				notifySelection();
				break;
			case MotionEvent.ACTION_UP:
				notifyDeSelection();
				break;
			}
			return super.onTouchEvent(event);
		} else {
			if (action == MotionEvent.ACTION_DOWN) {
				long currentTime = System.currentTimeMillis();
				if (currentTime - lastTouchTime < 300)
					notifyDoubleTapped();
				else
					notifySelection();
				lastTouchTime = System.currentTimeMillis();
			}
			return super.onTouchEvent(event);
		}
	}
}