package com.findingemos.felicity.util;

/**
 * A class which extends this interface will be able to recognise simple swipe
 * gestures.<br>
 * <br>
 * To use this class do the following:<br>
 * 1. Let your View class implement this interface.<br>
 * 2. Add a field "detector" of the clas SimpleSwipeDetector.<br>
 * 3. In the constructor, create a SimpleSwipeDetector and pass along your View
 * class.<br>
 * 4. Overwrite the onTouchEvent(MotionEvent event) method of your view and let
 * it call the onTouchEvent(MotionEvent event) method of the
 * SimpleSwipeDetector.<br>
 * <br>
 * For an example of the implementation, check the EmoticonActivity class.
 * 
 * @author Niels
 * @version 0.1
 */
public interface Swipeable {
	/**
	 * This method is called when a swipe to the left is detected.
	 */
	public void onSwipeLeft();

	/**
	 * This method is called when a swipe to the right is detected.
	 */
	public void onSwipeRight();

	/**
	 * This method is called when a swipe to the top is detected.
	 */
	public void onSwipeUp();

	/**
	 * This method is called when a swipe to the bottom is detected
	 */
	public void onSwipeDown();
}
