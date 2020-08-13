package javaolp;

import java.sql.*;
import java.util.*;

public class DBProgress {

	@Override
	public String toString() {
		return "DBProgress [student_id=" + student_id + ", course_content_id=" + course_content_id + ", has_done=" + has_done
				+ ", is_persisted=" + is_persisted + "]";
	}
	final Integer student_id;
	final Integer course_content_id;
	final Optional<Boolean> has_done;
	final boolean is_persisted;
	//constructor 1 (has_done: empty)
	DBProgress (Integer student_id, Integer course_content_id) {
		this.student_id = student_id;
		this.course_content_id = course_content_id;
		this.has_done = Optional.empty();
		this.is_persisted = false;
	}
	//constructor 2
	private DBProgress (Integer student_id, Integer course_content_id, Boolean has_done, boolean is_persisted) {
		this.student_id = student_id;
		this.course_content_id = course_content_id;
		this.has_done = Optional.of(has_done);
		this.is_persisted = is_persisted;
	}

	static List<DBProgress> all(Connection c, String sch) throws SQLException {
		// returns All Progresses
		List<DBProgress> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".progress;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBProgress(rs.getInt(1),rs.getInt(2),rs.getBoolean(3),true));
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
