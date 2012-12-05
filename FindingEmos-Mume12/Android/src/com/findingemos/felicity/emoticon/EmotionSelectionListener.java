package com.findingemos.felicity.emoticon;

/**
 * A listener that is notified when an emoticon is selected or deselected.
 * 
 * @author Niels
 * @version 0.1
 */
public interface EmotionSelectionListener {
	/**
	 * Called when an emotion is selected as in dragged, or tapped one time.
	 * 
	 * @param emoticon
	 *            The emotion which is selected.
	 */
	public void onEmotionSelected(Emotion emoticon);

	/**
	 * Called when an emotion is double tapped.
	 * 
	 * @param emoticon
	 *            The emotion which is double tapped.
	 */
	public void onEmotionDoubleTapped(Emotion emoticon);

	/**
	 * Called when an emotion is deselected.
	 * 
	 * @param emoticon
	 *            The emotion which is deselected.
	 */
	public void onEmotionDeselected(Emotion emoticon);
}
