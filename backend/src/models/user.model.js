import pool from "../config/pool.js";

export class UserModel {
    static async createUser({ email, password_hash, role }) {
        const q = `
            INSERT INTO users (email, password_hash, role)
            VALUES ($1, $2, $3)
            RETURNING user_id, email, role, created_at
        `;
        const { rows } = await pool.query(q, [email, password_hash, role]);
        return rows[0];
    }

    static async getUserByEmail(email) {
        const q = "SELECT * FROM users WHERE email = $1 LIMIT 1";
        const { rows } = await pool.query(q, [email]);
        return rows[0];
    }

    static async getUserById(user_id) {
        const q = "SELECT * FROM users WHERE user_id = $1";
        const { rows } = await pool.query(q, [user_id]);
        return rows[0];
    }

    static async updateUserPassword(user_id, new_password_hash) {
        const q = `
            UPDATE users
            SET password_hash = $1
            WHERE user_id = $2
            RETURNING user_id, email, role, created_at
        `;
        const { rows } = await pool.query(q, [new_password_hash, user_id]);
        return rows[0];
    }

    static async updateUser(user_id, updates) {
        const fields = [];
        const values = []; 
        let paramIndex = 1;

        if (updates.email !== undefined) {
            fields.push(`email = $${paramIndex++}`);
            values.push(updates.email);
        }
        if (updates.role !== undefined) {
            fields.push(`role = $${paramIndex++}`);
            values.push(updates.role);
        }

        if (fields.length === 0) {
            throw new Error("No fields to update");
        }

        const q = `
            UPDATE users
            SET ${fields.join(', ')}
            WHERE user_id = $${paramIndex}
            RETURNING user_id, email, role, created_at
        `;
        values.push(user_id);
        const { rows } = await pool.query(q, values);
        return rows[0];
    }

    static async deleteUser(user_id) {
        const q = "DELETE FROM users WHERE user_id = $1";
        await pool.query(q, [user_id]);
        return true;
    }

    static async getAllUsers() {
        const q = "SELECT user_id, email, role, created_at FROM users";
        const { rows } = await pool.query(q);
        return rows;
    }
}

// Usage example of object UserModel:
// import { UserModel } from '../models/user.model.js';
//
// const example = async () => {
//   try {
//     const newUser = await UserModel.createUser({
//       email: 'user@example.com',
//       password_hash: 'hashed_password_here',
//       role: 'student'
//     });
//     console.log(newUser);
//   } catch (error) {
//     console.error('Error:', error);
//   }
// };



// Usage example of class StudentModel:
// import { StudentModel } from '../models/student.model.js';
// const newStudent = await StudentModel.createStudent({
//   user_id: 'uuid-here',
//   roll_no: '12345',
//   sname: 'John Doe',
//   semester: 1,
//   programme: 'B.Tech',
//   batch: 2023,
//   photo_url: 'http://example.com/photo.jpg'
// });

// // Get all students
// const students = await StudentModel.getAllStudents();

// // Get student by ID
// const student = await StudentModel.getStudentById('user-uuid');

// // Update student
// const updated = await StudentModel.updateStudent('user-uuid', { sname: 'Jane Doe', semester: 2 });

// // Delete student
// await StudentModel.deleteStudent('user-uuid');

// // Get students by programme
// const Students = await StudentModel.getStudentsByProgramme('MCA');