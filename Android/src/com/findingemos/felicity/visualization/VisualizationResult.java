package com.findingemos.felicity.visualization;

public class VisualizationResult {

	private String location;
	private String doing;
	private String who;
	private String time;
	private int emotionId;

	public VisualizationResult(String location, String doing, String who,
			String time, int emotionId) {
		this.location = location;
		this.doing = doing;
		this.who = who;
		this.time = time;
		this.setEmotionId(emotionId);
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getDoing() {
		return doing;
	}

	public void setDoing(String doing) {
		this.doing = doing;
	}

	public String getWho() {
		return who;
	}

	public void setWho(String who) {
		this.who = who;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	/**
	 * @return the emotionId
	 */
	public int getEmotionId() {
		return emotionId;
	}

	/**
	 * @param emotionId
	 *            the emotionId to set
	 */
	public void setEmotionId(int emotionId) {
		this.emotionId = emotionId;
	}
}
