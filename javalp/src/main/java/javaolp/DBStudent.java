package javaolp;

import java.sql.*;
import java.util.*;

public class DBStudent {

	@Override
	public String toString() {
		return "DBStudent [student_id=" + student_id + ", user_name=" + user_name + ", email=" + email
							+ ", password=" + password + ", is_persisted=" + is_persisted + "]";
	}
	final Optional<Integer> student_id;
	final String user_name;
	final String email;
	final String password;
	final boolean is_persisted;
	//constructor 1 (student_id: empty)
	DBStudent (String user_name, String email, String password) {
		this.student_id = Optional.empty();
		this.user_name = user_name;
		this.email = email;
		this.password = password;
		this.is_persisted = false;
	}
	//constructor 2
	private DBStudent (Integer student_id, String user_name, String email, String password, boolean is_persisted) {
		this.student_id = Optional.of(student_id);
		this.user_name = user_name;
		this.email = email;
		this.password = password;
		this.is_persisted = is_persisted;
	}

	static List<DBStudent> all(Connection c, String sch) throws SQLException {
		// returns All Students
		List<DBStudent> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".student;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBStudent(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getString(4),true));
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
	
	//changing the email
	DBStudent changeEmail(String email) {
		if (this.student_id.isPresent())
			return new DBStudent(this.student_id.get(), this.user_name, email, this.password, false);
		else
			return new DBStudent(this.user_name, email, this.password);		
	}
	//changing the password
	DBStudent changePassword(String password) {
		if (this.student_id.isPresent())
			return new DBStudent(this.student_id.get(), this.user_name, this.email, password, false);
		else
			return new DBStudent(this.user_name, this.email, password);
	}
	
	
	//UPDATE or INSERT new row
	DBStudent persist(Connection c, String sch) throws SQLException {
		// UPDATEs user with ID
		if (this.student_id.isPresent()) {
			String query = "UPDATE "+ sch +".student SET (username, email, password) = (?,?,?) WHERE sid= ?;";
			try (PreparedStatement stm = c.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)){
				stm.setString(1, this.user_name);
				stm.setString(2, this.email);
				stm.setString(3, this.password);
				stm.setInt(4, this.student_id.get());
				stm.execute();
				ResultSet res = stm.getGeneratedKeys();
				//if(res != null && res.next()){
				if(res != null){
					return new DBStudent(this.student_id.get(), this.user_name, this.email, this.password, true);
	     		}
				else
					return new DBStudent(this.user_name, this.email, this.password);
			}
		}
		else {
			String query = "INSERT INTO " + sch + ".student (username, email, password) VALUES (?,?,?);";
			try (PreparedStatement stm = c.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)){
				stm.setString(1, this.user_name);
				stm.setString(2, this.email);
				stm.setString(3, this.password);
				stm.execute();
				ResultSet res = stm.getGeneratedKeys();

				if(res != null && res.next()){
					return new DBStudent(res.getInt(1), this.user_name, this.email, this.password, true);
	     		}
				else {
					return new DBStudent(this.user_name, this.email, this.password);
				}
			}
		}
		//persisted Student
	}

}
