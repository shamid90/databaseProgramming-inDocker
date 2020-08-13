package javaolp;

import java.sql.*;
import java.util.*;

public class DBFeedback {

	@Override
	public String toString() {
		return "DBFeedback [feedback_id=" + feedback_id + ", student_id=" + student_id  + ", course_id=" + course_id
							+ ", rate=" + rate + ", last_updated=" + last_updated
							+ ", comment=" + comment + ", is_persisted=" + is_persisted + "]";
	}
	final Optional<Integer> feedback_id;
	final Integer student_id;
	final Integer course_id;
	final Double rate;
	final Optional<String> comment;
	final Optional<Timestamp> last_updated;
	final boolean is_persisted;
	//constructor 1 (feedback_id, comment, last_updated: empty)
	DBFeedback (Integer student_id, Integer course_id, Double rate) {
		this.feedback_id = Optional.empty();
		this.student_id = student_id;
		this.course_id = course_id;
		this.rate = rate;
		this.comment = Optional.empty();
		this.last_updated = Optional.empty();
		this.is_persisted = false;
	}
	//constructor 2
	private DBFeedback (Integer feedback_id, Integer student_id, Integer course_id, Double rate, String comment, Timestamp last_updated, boolean is_persisted) {
		this.feedback_id = Optional.of(feedback_id);
		this.student_id = student_id;
		this.course_id = course_id;
		this.rate = rate;
		this.comment = Optional.ofNullable(comment); // for string we must use Optional.OfNullable, otherwise possibility of NullPointerException
		this.last_updated = Optional.of(last_updated);
		this.is_persisted = is_persisted;
	}

	static List<DBFeedback> all(Connection c, String sch) throws SQLException {
		// returns All Feedbacks
		List<DBFeedback> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".feedback;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBFeedback(rs.getInt(1),rs.getInt(2),rs.getInt(3),rs.getDouble(4),rs.getString(5),rs.getTimestamp(6),true));
			}
		} catch(SQLException e){
			System.out.println(e.getMessage());
		} finally {
			try {
				if(rs != null)
					rs.close();
			}catch(SQLException e) {
				System.out.println(e.getMessage());
			}
		}
		return li;
	}

}
