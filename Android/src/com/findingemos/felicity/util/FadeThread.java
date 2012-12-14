package com.findingemos.felicity.util;

import android.graphics.Paint;

/**
 * A thread to make it easier to create a fading effect. You can pass any Paint
 * object and this thread will change the alpha value and request an update of
 * this Drawer.
 * 
 * @author Niels
 * @version 0.1
 */
public abstract class FadeThread extends Thread {
	// Flag for aborting the thread
	private boolean abort = false;
	// Flag to check whether the thread is finished.
	private boolean isFinished = false;
	// The paint object which is modified.
	private Paint paintObject;
	// The view which needs to be redrawn.
	private MultiThreadAccesView view;
	// The amount of sleep between two frames.
	private long sleepTime;
	// The number of frames for the animation.
	private int nbOfFrames;
	// The change in alpha between two frames.
	private int alphaChange;

	/**
	 * 
	 * @param paint
	 * @param framesPerSecond
	 */
	public FadeThread(MultiThreadAccesView view, Paint paintObject,
			long timeout, int framesPerSecond) {
		if (view == null)
			throw new IllegalArgumentException("The given view is null!");
		if (paintObject == null)
			throw new IllegalArgumentException(
					"The given paint object is null!");
		if (framesPerSecond < 1)
			throw new IllegalArgumentException(
					"The given number of frames per second is lower than one!");
		this.view = view;
		this.paintObject = paintObject;
		this.sleepTime = (long) Math
				.max(Math.ceil(1000.0 / framesPerSecond), 1);
		this.nbOfFrames = Math.max(1,
				(int) ((double) timeout / (double) sleepTime));
		this.alphaChange = (int) Math.max((510.0 / nbOfFrames), 1);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Thread#run()
	 */
	@Override
	public void run() {
		int alpha = paintObject.getAlpha();
		while (!abort && alpha > 0) {
			alpha = Math.max(alpha - alphaChange, 0);
			paintObject.setAlpha(alpha);
			view.requestSyncUpdate();
			try {
				sleep(sleepTime);
			} catch (InterruptedException e) {
			}
		}

		if (!abort)
			onInvisible();

		while (!abort && alpha < 255) {
			alpha = Math.min(alpha + alphaChange, 255);
			paintObject.setAlpha(alpha);
			view.requestSyncUpdate();
			try {
				sleep(sleepTime);
			} catch (InterruptedException e) {
			}
		}

		isFinished = true;
	}

	/**
	 * Stops this thread and execution of it's run method.
	 */
	public void abort() {
		abort = true;
	}

	/**
	 * Returns whether this thread is finished.
	 * 
	 * @return whether this thread is finished.
	 */
	public boolean isFinished() {
		return isFinished;
	}

	/**
	 * This method will be called when the alpha value of the given paint object
	 * is zero.
	 */
	public abstract void onInvisible();
}
