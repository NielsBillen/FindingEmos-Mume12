package com.findingemos.felicity.util;

import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

/**
 * A specialized listener that will notify the passed swipeable that there is a
 * swipe.
 * 
 * @author Niels
 * @version 0.1
 */
public class SimpleSwipeListener implements View.OnTouchListener {
	// The swipeable that needs to be notified.
	private Swipeable swipeable;
	// The x position when there was a down push.
	private float downX;
	// The y position when there was a down push.
	private float downY;
	// The x position when there the touch was released.
	private float upX;
	// The y position when there the touch was released.
	private float upY;

	/**
	 * Creates a new simple swipe listener that notifies the given swipeable
	 * when a swipe is detected.
	 * 
	 * @param swipeable
	 *            The swipeable to notify.
	 * @throws IllegalArgumentException
	 *             When the given swipeable is null.
	 */
	public SimpleSwipeListener(Swipeable swipeable) {
		if (swipeable == null)
			throw new IllegalArgumentException("The given swipeable is null!");
		this.swipeable = swipeable;
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

		/**
		 * In this piece of code we will store the position of a touch event.
		 * When the touch is released, a check is performed to test whether
		 * there is a swipe.<br>
		 * <br>
		 * Remember to return true on each event that you want to listen to,
		 * because if you return false, it will not listen anymore!
		 */
		switch (action) {
		case MotionEvent.ACTION_DOWN:
			downX = event.getX();
			downY = event.getY();
			Log.i("D&D", "Down");
			return true;
		case MotionEvent.ACTION_UP:
			upX = event.getX();
			upY = event.getY();
			Log.i("D&D", "Up");
			float deltaX = downX - upX;
			float deltaY = downY - upY;

			if (deltaX < -50)
				swipeable.onSwipeLeft();
			else if (deltaX > 50)
				swipeable.onSwipeRight();

			if (deltaY < -50)
				swipeable.onSwipeUp();
			else if (deltaY > 50)
				swipeable.onSwipeDown();
			return true;
		}
		return false;
	}
}
