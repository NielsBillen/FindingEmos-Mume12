package com.findingemos.felicity.friends;

import android.graphics.Bitmap;

public class Contact {

	private String name;
	private String firstName;
	private String lastName;
	private Bitmap photo;
	private boolean selected = false;

	public Contact(String name, Bitmap photo) {
		this.setName(name);
		String[] subNames = name.split("\\s+");
		this.setFirstName(subNames[0]);
		String lastName = "";
		for (int i = 1; i < subNames.length; i++) {
			lastName += " " + subNames[i];
		}
		this.setLastName(lastName);

		this.setPhoto(photo);
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Bitmap getPhoto() {
		return photo;
	}

	public void setPhoto(Bitmap photo) {
		this.photo = photo;
	}

	public Boolean isSelected() {
		return selected;
	}

	public void setSelected(Boolean selected) {
		this.selected = selected;
	}

	public boolean equals(Contact other) {
		return other.getName().equals(this.getName());
	}

	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}

	/**
	 * @param firstName
	 *            the firstName to set
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}

	/**
	 * @param lastName
	 *            the lastName to set
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

}