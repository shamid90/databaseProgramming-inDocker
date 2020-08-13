package javaolp;

import java.sql.*;
import java.util.*;

public class DBCourseContent {

	@Override
	public String toString() {
		return "DBCourseContent [course_content_id=" + course_content_id + ", content_link=" + content_link +
				", durationk=" + duration + ", last_updated=" + last_updated
				+ ", is_persisted=" + is_persisted + "]";
	}
	final Optional<Integer> course_content_id;
	final String content_link;
	final Double duration;
	final Optional<Timestamp> last_updated;
	final Integer course_id;
	final boolean is_persisted;
	//constructor 1 (course_content, last_updated: empty)
	DBCourseContent (String content_link, Double duration, Integer course_id) {
		this.course_content_id = Optional.empty();
		this.content_link = content_link;
		this.duration = duration;
		this.last_updated = Optional.empty();
		this.course_id = course_id;
		this.is_persisted = false;
	}
	//constructor 2
	private DBCourseContent (Integer course_content_id, String content_link , Double duration, Timestamp last_updated, Integer course_id, boolean is_persisted) {
		this.course_content_id = Optional.of(course_content_id);
		this.content_link = content_link;
		this.duration = duration;
		this.last_updated = Optional.of(last_updated);
		this.course_id = course_id;
		this.is_persisted = is_persisted;
	}

	static List<DBCourseContent> all(Connection c, String sch) throws SQLException {
		// returns All Course Contents
		List<DBCourseContent> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".course_content;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBCourseContent(rs.getInt(1),rs.getString(2),rs.getDouble(3),rs.getTimestamp(4),rs.getInt(5),true));
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
