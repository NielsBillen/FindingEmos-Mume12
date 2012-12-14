package com.findingemos.felicity.backend;

import android.database.sqlite.SQLiteDatabase;

/**
 * This class contains version codes for the database and which version is
 * currently in used.<br>
 * <br>
 * When new data is needed in the database, or when the schemas are changed, you
 * need to change the code.<br>
 * <br>
 * Furthermore you can implement methods here to perform an update of your sql
 * database to a new version (when this is not implemented, the old database
 * will be cleared).
 * 
 * @author Niels
 * @version 0.1
 */
public class DatabaseVersionCodes {
	// First version of the database (contains count history and history of
	// emoticon)
	public static final int EMOTION_V1_NIELS_14_10_2012 = 1;
	public static final int EMOTION_V2_STIJN_12_11_2012 = 2;
	public static final int EMOTION_V3_STIJN_15_11_2012 = 3;
	public static final int EMOTION_V4_STIJN_16_11_2012 = 4;
	public static final int EMOTION_V5_STIJN_18_11_2012 = 5;
	// Settings tabel toegevoegd
	public static final int EMOTION_V6_ROBIN_06_12_2012 = 6;
	// De database een echte naam gegeven, nodig om te kunnen resetten
	public static final int EMOTION_V7_ROBIN_06_12_2012 = 7;
	// Friends tabel verwijderd.
	public static final int EMOTION_V8_ROBIN_08_12_2012 = 8;
	// The current version of the emoticon database.
	public static final int EMOTION_CURRENT = EMOTION_V8_ROBIN_08_12_2012;

	/**
	 * Performs an update for the given sql database from the given version to
	 * the next version
	 * 
	 * @param database
	 *            The database which you want to update.
	 * @param oldVersion
	 *            The version of the given database.
	 * @param newVersion
	 *            The version to upgrade to.
	 * @throws IllegalArgumentException
	 *             When the database could not be updated.
	 * @return the updated database.
	 */
	public static SQLiteDatabase performUpdate(SQLiteDatabase database,
			int oldVersion, int newVersion) throws IllegalArgumentException {
		if (oldVersion == newVersion)
			return database;
		else
			throw new IllegalArgumentException(
					"The database could not be recovered");
	}
}
