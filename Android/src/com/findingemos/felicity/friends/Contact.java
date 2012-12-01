package com.findingemos.felicity.friends;

import android.graphics.Bitmap;

public class Contact {
	
	private String name;
	private Bitmap photo;
	private boolean selected = false;
	
	public Contact (String name, Bitmap photo) {
		this.setName(name);
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
		if(!other.getName().equals(this.getName())) {
			return false;
		}

		return true;
	}

}
