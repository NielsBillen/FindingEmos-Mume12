package com.findingemos.felicity.emoticon;

import java.util.Comparator;

import android.util.Log;

import com.findingemos.felicity.R;

/**
 * An enumeration that sums up all of the available emoticons.<br>
 * <br>
 * Each of the emoticons has a name, a small drawable id, a large drawable id
 * and they have the ability to return the number of times they were selected.<br>
 * <br>
 * The small drawable id is used since large images require a lot of processing
 * and load time.
 * 
 * @author Niels
 * @version 0.1
 */
public enum Emotion {
	// The enumeration
	ANGRY("Angry", R.drawable.angry_small, R.drawable.angry_big, 0, "angry"), ASHAMED(
			"Ashamed", R.drawable.ashamed_small, R.drawable.ashamed_big, 1,
			"ashamed"), BORED("Bored", R.drawable.bored_small,
			R.drawable.bored_large, 2, "bored"), HAPPY("Happy",
			R.drawable.happy_small, R.drawable.happy_big, 3, "happy"), HUNGRY(
			"Hungry", R.drawable.hungry_small, R.drawable.hungry_big, 4,
			"hungry"), INLOVE("In Love", R.drawable.inlove_small,
			R.drawable.inlove_big, 5, "love"), IRRITATED("Irritated",
			R.drawable.irritated_small, R.drawable.irritated_big, 6,
			"irritated"), SAD("Sad", R.drawable.sad_small, R.drawable.sad_big,
			7, "sad"), SCARED("Scared", R.drawable.scared_small,
			R.drawable.scared_big, 8, "big"), SICK("Sick",
			R.drawable.sick_small, R.drawable.sick_big, 9, "sick"), TIRED(
			"Tired", R.drawable.tired_small, R.drawable.tired_big, 10, "tired"), VERYHAPPY(
			"Very Happy", R.drawable.very_happy_small,
			R.drawable.very_happy_big, 11, "veryhappy"), VERYSAD("Very Sad",
			R.drawable.very_sad_small, R.drawable.very_sad_big, 12, "verysad"), VERYVERYHAPPY(
			"Very very happy", R.drawable.very_very_happy_small,
			R.drawable.very_very_happy_big, 13, "veryveryhappy");

	// A static comparator to compare two emoticons
	private static final Comparator<Emotion> COMPARATOR = new Comparator<Emotion>() {
		/**
		 * Compares the two given emotions on the number of selections to sort
		 * the emotions from large to small.
		 * 
		 * @param left
		 *            The first emotion.
		 * @param right
		 *            The second emotion.
		 * @return a negative number when the left has less selections as the
		 *         right emoticon, zero when they are equal and a positive
		 *         number when the left has more selections.
		 */
		@Override
		public int compare(Emotion left, Emotion right) {
			return right.getSelectionCount() - left.getSelectionCount();
		}
	};
	// The id of the resource of the emoticon.
	private final int lowResolutionResourceId;
	// The id of the high resolution resource of the emoticon.
	private final int highResolutionResourceId;
	// The name of the emoticon
	private final String name;
	// The amount of times the emoticon was selected (to order the emoticons)
	private int selectionCount = 0;
	// The unique database name
	private final String databaseName;
	/*
	 * I included this field instead of using the index in the array "values()".
	 * This will prevent errors when an emotion is added in the middle of the
	 * enumeration.
	 */
	private final int id;
	/*
	 * Whether the emotion is depricated. I already included this field for the
	 * case when an emotion is in the database but is not used anymore. This
	 * will avoid errors when the database is read out and the selection count
	 * of a non-existing emoticon is being set.
	 */
	private final boolean depricated = false;

	/**
	 * Creates a new emotion. The emotion will have a name (for display reasons)
	 * an id of a low resolution representation and one for a high resolution
	 * image. Furthermore it will get a unique id and a unique name for storing
	 * in the database.
	 * 
	 * @param name
	 *            Display name for the emoticon.
	 * @param lowResId
	 *            Low resolution image resource id.
	 * @param highResId
	 *            High resolution image resource id.
	 * @param id
	 *            Unique id for storing in the database.
	 * @param databaseName
	 *            The name to store inside the database.
	 */
	Emotion(String name, int lowResId, int highResId, int id,
			String databaseName) {
		this.name = name;
		this.lowResolutionResourceId = lowResId;
		this.highResolutionResourceId = highResId;
		this.id = id;
		this.databaseName = databaseName;
	}

	/**
	 * Returns the name of the emoticon.
	 * 
	 * @return the name of the emoticon.
	 */
	public String getName() {
		return name;
	}

	/**
	 * The resource id of the image of the emoticon.
	 * 
	 * @return the resource id of the image of the emoticon.
	 */
	public int getLowResolutionResourceId() {
		return lowResolutionResourceId;
	}

	/**
	 * The resource id of the image of the emoticon.
	 * 
	 * @return the resource id of the image of the emoticon.
	 */
	public int getHighResolutionResourceId() {
		return highResolutionResourceId;
	}

	/**
	 * Sets the number of times the emoticon was selected.
	 * 
	 * @param selectionCount
	 *            the number of times the emoticon was selected.
	 * @throws IllegalArgumentException
	 *             When the selection count is lower than zero.
	 */
	public void setSelectionCount(int selectionCount)
			throws IllegalArgumentException {
		if (selectionCount < 0) {
			Log.e("Emoticon",
					"Emoticon@selectionCount: the selectionCount was lower than zero!");
			throw new IllegalArgumentException(
					"The selectioncoun was lower than zero!");
		}
		this.selectionCount = selectionCount;
	}

	/**
	 * Increases the selection count of this emoticon by one.
	 */
	public void incrementSelectionCount() {
		++selectionCount;
		EmotionActivity.DATABASE.updateEmotionCount(this);
	}

	/**
	 * The number of times the emoticon was selected.
	 * 
	 * @return the number of times the emoticon was selected.
	 */
	public int getSelectionCount() {
		return selectionCount;
	}

	/**
	 * Returns the unique id for storage purposes in the database.
	 * 
	 * @return the unique id for storage purposes in the database.
	 */
	public int getUniqueId() {
		return id;
	}

	/**
	 * Returns a unique name for storage purposes in the database.
	 * 
	 * @return a unique name for storage purposes in the database.
	 */
	public String databaseName() {
		return databaseName;
	}

	/**
	 * Return whether this emotion is depricated.
	 * 
	 * @return whether this emotion is depricated.
	 */
	public boolean isDepricated() {
		return depricated;
	}

	/**
	 * Returns a comparator that compares emoticons on the number of selections.
	 * 
	 * @return a comparator that compares emoticons on the number of selections.
	 */
	public static Comparator<Emotion> getComparator() {
		return COMPARATOR;
	}

	/**
	 * Returns the emotion by the unique id.
	 * 
	 * @param id
	 *            The id for lookup.
	 * @throws IllegalArgumentException
	 *             When no emoticon exists with the given id.
	 * @return the emoticon with the given id.
	 */
	public static Emotion getEmoticonByUniqueId(int id)
			throws IllegalArgumentException {
		for (Emotion emoticon : values())
			if (emoticon.getUniqueId() == id)
				return emoticon;
		throw new IllegalArgumentException("Illegal unique id!");
	}
}
