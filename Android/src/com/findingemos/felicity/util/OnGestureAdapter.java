package com.findingemos.felicity.util;

import android.view.MotionEvent;

/**
 * An adapter that just implements default methods from the OnGestureListener.
 * This avoids overwriting lots of useless methods in other classes and makes
 * the code more compact.
 * 
 * @author Niels
 * @version 0.1
 */
public abstract class OnGestureAdapter implements
		android.view.GestureDetector.OnGestureListener {
	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.GestureDetector.OnGestureListener#onDown(android.view.
	 * MotionEvent)
	 */
	@Override
	public boolean onDown(MotionEvent e) {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.GestureDetector.OnGestureListener#onFling(android.view.
	 * MotionEvent, android.view.MotionEvent, float, float)
	 */
	@Override
	public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
			float velocityY) {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * android.view.GestureDetector.OnGestureListener#onLongPress(android.view
	 * .MotionEvent)
	 */
	@Override
	public void onLongPress(MotionEvent e) {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * android.view.GestureDetector.OnGestureListener#onScroll(android.view.
	 * MotionEvent, android.view.MotionEvent, float, float)
	 */
	@Override
	public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX,
			float distanceY) {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * android.view.GestureDetector.OnGestureListener#onShowPress(android.view
	 * .MotionEvent)
	 */
	@Override
	public void onShowPress(MotionEvent e) {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * android.view.GestureDetector.OnGestureListener#onSingleTapUp(android.
	 * view.MotionEvent)
	 */
	@Override
	public boolean onSingleTapUp(MotionEvent e) {
		return false;
	}
}
